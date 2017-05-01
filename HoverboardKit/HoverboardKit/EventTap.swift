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
 * We can't use NSEventTap because it does not offer enough functionality and we
 * don't want to use CGEventTap directly because its API isn't very elegant.
 * Instead we wrap the functionality that we need in our own EventTap class that
 * we can use from multiple places in our codebase with minor configuration.
 */
internal class EventTap {
    /**
     * This contains the events that this tap needs to listen for.
     */
    public let eventMask: NSEventMask

    /**
     * This is a reference to the event tap itself.
     */
    private var port:   CFMachPort?

    /**
     * This is a reference to the run loop source.
     */
    private var source: CFRunLoopSource?

    /**
     * Event taps can a) listen only to events or b) also send or replace events
     * on their own. We use b once a session starts because we want the system
     * to ignore arrow keys that we already process in Hoverboard.
     */
    public let isListenOnly: Bool

    /**
     * This boolean reflects if the event tap is actually enabled. You can
     * compute this property after calling start() to see if it had the intended
     * result.
     */
    public var isEnabled: Bool {
        guard let port = self.port else { return false }
        guard self.source != nil   else { return false }

        return CGEvent.tapIsEnabled(tap: port)
    }

    /**
     * This is the callback that is passed to the initializer. We call this
     * function when the underlying CGEventTap reports an event.
     */
    private let closure: (NSEvent) -> NSEvent?

    /**
     * This function initializes a new event tap that listens for the given
     * event mask and optionally can also manipulate events when listenOnly is
     * set to false. Events retrieved from the underlying CGEventTap are
     * forwarded to the given closure.
     */
    public init(eventMask: NSEventMask, listenOnly: Bool,
                closure: @escaping (NSEvent) -> NSEvent?) throws {
        self.eventMask    = eventMask
        self.isListenOnly = listenOnly
        self.closure      = closure

        try self.setupPort()
        try self.setupSource()
    }

    // MARK: - Port & Source

    /**
     * This function configures the event port.
     */
    private func setupPort() throws {
        let callback: CGEventTapCallBack = { (proxy, type, cgEvent, info) in
            guard let info = info else {
                return nil
            }

            let object = Unmanaged<AnyObject>.fromOpaque(info)

            guard let tap = object.takeUnretainedValue() as? EventTap else {
                return nil
            }

            // If the tap is disabled for some reason (this happens
            // infrequently), attempt to restart it. Also, we need to do this
            // *before* converting it to an NSEvent because NSEvent does not
            // support these events.
            if type == CGEventType.tapDisabledByTimeout ||
               type == CGEventType.tapDisabledByUserInput {
                try? tap.start()
                return nil
            }

            guard let event = NSEvent(cgEvent: cgEvent) else {
                return Unmanaged.passUnretained(cgEvent)
            }

            guard tap.isEnabled else { return nil }

            if let result = tap.closure(event)?.cgEvent {
                return Unmanaged.passUnretained(result)
            } else {
                return nil
            }
        }

        let eventMask = CGEventMask(self.eventMask.rawValue)
        let info      = Unmanaged.passUnretained(self).toOpaque()

        guard let port = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                         place: .headInsertEventTap,
                                       options: self.isListenOnly ? .listenOnly
                                                                  : .defaultTap,
                              eventsOfInterest: eventMask,
                                      callback: callback,
                                      userInfo: info) else {
            throw Error.eventTapFailed
        }

        self.port = port
    }

    /**
     * This function configures the run loop source.
     */
    private func setupSource() throws {
        guard let port   = self.port,
              let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                                         port, 0) else {
            throw Error.runLoopSourceFailed
        }

        self.source = source
    }

    // MARK: - State

    /**
     * This function starts the event tap by adding the run loop source to the
     * current run loop.
     */
    public func start() throws {
        if self.isEnabled { return }

        guard let port = self.port else {
            throw Error.invalidEventTap
        }

        guard let source = self.source else {
            throw Error.invalidEventTap
        }

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source,
                           CFRunLoopMode.defaultMode)
        CGEvent.tapEnable(tap: port, enable: true)

        if self.isEnabled == false {
            throw Error.invalidEventTap
        }
    }

    /**
     * This function stops the event tap by removing the run loop source from
     * the current run loop.
     *
     * TODO: verify that this function and the start function are called within
     *       the same run loop.
     */
    public func stop() throws {
        assert(Thread.isMainThread)

        if !self.isEnabled { return }

        guard let port = self.port else {
            throw Error.invalidEventTap
        }

        guard let source = self.source else {
            throw Error.invalidEventTap
        }

        CGEvent.tapEnable(tap: port, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source,
                              CFRunLoopMode.defaultMode)
    }

    deinit {
        try? self.stop()
    }
}
