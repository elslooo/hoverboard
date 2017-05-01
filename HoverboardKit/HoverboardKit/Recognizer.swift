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
 * The recognizer is responsible only for recognizing the cmd-cmd sequence.
 */
internal class Recognizer {
    private enum State : String {
        case possible
        case pressedCommandOnce
        case releasedCommandOnce
        case pressedCommandTwice
        case rejected
        case recognized
    }

    /**
     * This array consists of two event taps: one that catches only cmd, shift
     * keys etc. that is activated by default to detect our key combo, and one
     * that catches all keys but is only activated after the key combo is
     * detected.
     */
    private var taps: [EventTap] = []

    /**
     * This measures the time between the first and second cmd press.
     */
    private var timer: Timer?

    /**
     * Reference to the window manager that we use to call some delegate
     * functions.
     */
    internal weak var manager: WindowManager?

    /**
     * This is the current state of the recognizer (similar to
     * UIGestureRecognizer).
     */
    private var state = State.possible {
        didSet {
            do {
                try self.disableTaps()

                switch self.state {
                case .pressedCommandOnce,
                     .releasedCommandOnce,
                     .pressedCommandTwice:
                    try? self.taps[1].start()

                    self.timer?.invalidate()

                    // TODO: this is my favorite interval but that may be
                    //       personal. Maybe add some kind of preference setting
                    //       to the app?
                    self.timer = Timer.scheduledTimer(timeInterval: 0.4,
                                                      target: self,
                                                      selector: #selector(tick),
                                                      userInfo: nil,
                                                      repeats: false)

                    if self.state != .releasedCommandOnce {
                        self.manager?.session?.end()

                        guard let manager  = self.manager,
                              let delegate = manager.delegate else {
                            return
                        }

                        delegate.windowManager(manager,
                                    didRecord: .command)
                    }
                case .possible, .recognized, .rejected:
                    try self.taps[0].start()

                    self.timer?.invalidate()

                    if self.state == .recognized {
                        self.closure()
                    } else if self.state == .rejected {
                        guard let manager  = self.manager,
                              let delegate = manager.delegate else {
                            return
                        }

                        delegate.windowManagerDidCancelSession(manager)
                    }
                }
            } catch {
                // TODO: determine if we should really ignore this.
            }
        }
    }

    /**
     * This is the closure that is passed to the initializer. This function is
     * called when the recognizer has detected our signature key combo (⌘ + ⌘).
     */
    private let closure: (Void) -> Void

    /**
     * This function initializes a new recognizer that will call the given
     * function when our signature key combo is detected. This initializer will
     * throw an error when Hoverboard is not authorized to listen to global key
     * events.
     */
    public init(closure: @escaping (Void) -> Void) throws {
        self.closure = closure

        try self.taps.append(EventTap(eventMask: .flagsChanged,
                                      listenOnly: true) {
            [weak self] (event) -> NSEvent? in
            return self?.flagsChanged(event: event)
        })

        try self.taps.append(EventTap(eventMask: [ .flagsChanged, .keyDown,
                                                   .keyUp ], listenOnly: true) {
            [weak self] (event) -> NSEvent? in
            return self?.keysPressed(event: event)
        })

        self.state = .possible
        try self.disableTaps()
        try self.taps[0].start()
    }

    deinit {
        print("Deinit")
    }

    // MARK: - Tap Events

    // TODO: find a way to extract this rather than hardcode them, even though
    //       they seem to be stable over the last ~ 2 years.

    // 1st = command, 2nd = left
    private static let leftCommandKeyMask:  UInt = 0b000100000000000000001000

    // 1st = command, 2nd = right
    private static let rightCommandKeyMask: UInt = 0b000100000000000000010000

    // No key is pressed.
    private static let emptyMask:           UInt = 0b000000000000000000000000

    /**
     * This function is called from the initial event tap to detect our
     * signature key combo.
     */
    func flagsChanged(event: NSEvent) -> NSEvent? {
        // TODO: not sure why this bit is set. It seems to be always 1, even
        //       when no key is pressed.
        let rawValue = event.modifierFlags.rawValue ^ 0b100000000

        if rawValue == Recognizer.leftCommandKeyMask ||
           rawValue == Recognizer.rightCommandKeyMask {
            if event.modifierFlags.contains(.command) {
                self.state = .pressedCommandOnce
            } else {
                // Unlikely
                self.state = .possible
            }
        } else if rawValue == Recognizer.emptyMask {

        } else {
            self.state = .possible
        }

        return event
    }

    /**
     * This function is called from the session event tap to detect subsequent
     * keys. Note that this catches all keys but is only activated *after* we
     * have recognized our signature key combo. As soon as we notice a key that
     * is unsupported (e.g. a letter), this event tap is also deactivated.
     */
    func keysPressed(event: NSEvent) -> NSEvent? {
        // TODO: not sure why this bit is set. It seems to be always 1, even
        //       when no key is pressed.
        let rawValue = event.modifierFlags.rawValue ^ 0b100000000

        if self.state == .pressedCommandOnce {
            if event.type == .flagsChanged && rawValue == Recognizer.emptyMask {
                self.state = .releasedCommandOnce
            } else {
                self.state = .rejected
            }
        } else if self.state == .releasedCommandOnce {
            if event.type == .flagsChanged {
                if rawValue == Recognizer.leftCommandKeyMask ||
                   rawValue == Recognizer.rightCommandKeyMask {
                    self.state = .pressedCommandTwice
                } else {
                    self.state = .rejected
                }
            } else {
                self.state = .rejected
            }
        } else if self.state == .pressedCommandTwice {
            if event.type == .flagsChanged && rawValue == Recognizer.emptyMask {
                self.state = .recognized
            } else {
                self.state = .rejected
            }
        } else if self.state == .rejected {
            if rawValue == Recognizer.emptyMask {
                self.state = .possible
            }
        }

        return event
    }

    // MARK: - Taps

    /**
     * This function attempts to disable all taps.
     */
    func disableTaps() throws {
        try taps.forEach { try $0.stop() }
    }

    // MARK: - Timeout

    /**
     * This function is called by our timer when the signature key combo times
     * out (after 0.4s of inactivity).
     */
    @objc func tick(timer: Timer) {
        self.state = .rejected
    }
}
