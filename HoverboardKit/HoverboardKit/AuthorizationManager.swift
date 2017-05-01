/*
 * Copyright (c) 2017 Tim van Elsloo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

/**
 * The authorization manager can be used to check if Hoverboard has proper
 * authorization to manage windows of other applications.
 */
public class AuthorizationManager {
    /**
     * This property can be set to receive updates of the authorization state.
     */
    public weak var delegate: AuthorizationManagerDelegate? {
        didSet {
            // Immediately send an initial event to update the delegate of our
            // current authorization state. For this, we need to remove the
            // 'cached' variable.
            self.lastAuthorized = nil
            self.sendEvent()
        }
    }

    /**
     * We use an FSEventStream because it does not require read permission.
     * Since macOS 10.12.0 we don't have write permission and occasionally also
     * no read permission (according bug reports from our testers). This means
     * that we cannot use any method that requires `open(..., O_EVTONLY)`.
     */
    private var stream: FSEventStreamRef?

    /**
     * This function initializes the authentication manager and starts listening
     * for changes made to the privacy database directory. Note that it cannot
     * actually read from the database. Instead, it uses it as a trigger to
     * refresh its own authorization state.
     */
    public init() {
        let path    = "/Library/Application Support/com.apple.TCC/"
        let paths   = [path as CFString] as CFArray
        let info    = Unmanaged.passUnretained(self).toOpaque()
        var context = FSEventStreamContext(version: 0, info: info, retain: nil,
                                           release: nil, copyDescription: nil)

        guard let stream = withUnsafeMutablePointer(to: &context, {
            (context) -> FSEventStreamRef? in

            let id   = UInt64(kFSEventStreamEventIdSinceNow)
            let flag = UInt32(kFSEventStreamCreateFlagWatchRoot)

            let callback: FSEventStreamCallback = {
                (_, info, _, _, _, _) in
                guard let info = info else {
                    return
                }

                let manager = Unmanaged<AuthorizationManager>.fromOpaque(info)
                manager.takeUnretainedValue().sendEvent()
            }

            return FSEventStreamCreate(nil, callback, context,
                                       paths, id, 0, flag)
        }) else {
            return
        }

        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),
                                         CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(stream)

        self.stream = stream
    }

    /**
     * We need to manually stop the event stream when the authorization manager
     * is deallocated.
     */
    deinit {
        guard let stream = self.stream else {
            return
        }

        FSEventStreamStop(stream)
    }

    /**
     * This property returns a boolean that indicates if Hoverboard is
     * authorized to manage windows of other applications.
     */
    public var isAuthorized: Bool {
        let options: [String : Any] = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as String : false
        ]

        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    /**
     * We maintain a variable that holds the last authorization state so that we
     * do not repeatedly send an event for the same state.
     */
    private var lastAuthorized: Bool?

    /**
     * This function evaluates the new authorization state and sends an event to
     * the delegate if necessary.
     */
    private func sendEvent() {
        let isAuthorized = self.isAuthorized

        if self.lastAuthorized == isAuthorized { return }

        self.lastAuthorized = isAuthorized

        if isAuthorized {
            self.delegate?.authorizationManagerDidGrantAccess(self)
        } else {
            self.delegate?.authorizationManagerDidRevokeAccess(self)
        }
    }
}
