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

public class WindowManager {
    private var recognizer: Recognizer?
    internal var sessionTap: EventTap?

    public weak var delegate: WindowManagerDelegate?

    public init() throws {
        self.sessionTap = try EventTap(eventMask: [ .keyDown, .flagsChanged ],
                                      listenOnly: false) {
            [weak self] (event) -> NSEvent? in
            guard let session = self?.session else { return event }

            if session.process(event: event) {
                // Well done!
                return nil
            } else {
                return event
            }
        }
        try self.sessionTap?.stop()
    }

    /**
     * This is a reference to the currently running session (if any).
     */
    internal var session: Session?

    public func start() throws {
        // First we check if Hoverboard is authorized to manage windows of other
        // applications. If not, Hoverboard should ask for authorization.
        if !AuthorizationManager().isAuthorized {
            throw Error.unauthorized
        }

        self.recognizer = try Recognizer(closure: {
            [unowned self]  in
            if let delegate = self.delegate,
               delegate.windowManagerShouldStartSession(self) == false {
                return
            }

            let session  = Session(manager: self)
            self.session = session

            self.delegate?.windowManager(self, didStartTracking: session)

            assert(session.delegate != nil)

            try? self.sessionTap?.start()
        })
        self.recognizer?.manager = self
    }
}

extension WindowManager : SessionDelegate {
    public func session(_ session: Session, didUpdate grid: Grid) {
        Application.active?.keyWindow?.grid = grid
    }

    public func sessionDidEnd(_ session: Session) {
        try? self.sessionTap?.start()

        if let current = self.session, current === session {
            self.session = nil
        }

        self.delegate?.windowManager(self, didEndTracking: session)
    }
}
