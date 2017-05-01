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
 * A session starts when the key combo (⌘ + ⌘) is recognized.
 */
public class Session {
    /**
     * This is the session timeout. Currently, we don't change it anywhere but
     * in the future we might want to add an option for this to the status bar
     * menu.
     */
    public static var timeout: TimeInterval = 1.0

    /**
     * This can be set to an object that implements the SessionDelegate protocol
     * and wants to receive updates by this session.
     */
    public weak var delegate: SessionDelegate?

    /**
     * This is a weak reference to the manager that owns this session.
     */
    internal weak var manager: WindowManager?

    /**
     * This is a timer that is responsible for the session timeout.
     */
    private var timer: Timer?

    /**
     * This is a reference to the screen that is focused.
     */
    public var screen: NSScreen?

    /**
     * This function initializes a session with the given manager.
     */
    internal init(manager: WindowManager) {
        self.manager = manager

        self.screen = Application.active?.keyWindow?.screen

        self.resetTimer()
    }

    /**
     * This is a boolean that is set to false when the session ends. This is in
     * case the session remains in memory even after it has ended (e.g. due to
     * unexpected behavior of automatic retain count).
     */
    internal private(set) var isActive = true

    /**
     * This is the grid that gets created by a user during a session.
     */
    private var grid = Grid()

    // MARK: - Processing Events

    /**
     * This function processes the left arrow key.
     */
    internal func processLeftArrowKey(shift: Bool) {
        guard let manager = self.manager else {
            return
        }

        manager.delegate?.windowManager(manager, didRecord: .left)

        if shift && (self.grid.x != 0 || self.grid.width != 3) {
            // If shift is pressed, we add one to the right without moving from
            // the left.
            self.grid.xnum += 1
        }

        if self.grid.width == 3 && self.grid.x > 0 {
            self.grid.x -= 1
        }

        if self.grid.x == 0 {
            self.grid.width += 1
        } else if self.grid.width != 3 {
            self.grid.x -= 1
        }
    }

    /**
     * This function processes the right arrow key.
     */
    internal func processRightArrowKey(shift: Bool) {
        guard let manager = self.manager else {
            return
        }

        manager.delegate?.windowManager(manager, didRecord: .right)

        if self.grid.x == self.grid.width - 1 {
            self.grid.width += 1
        }

        self.grid.x += 1

        if shift {
            self.grid.x    -= 1
            self.grid.xnum += 1
        }
    }

    /**
     * This function processes the down arrow key.
     */
    internal func processDownArrowKey(shift: Bool) {
        guard let manager = self.manager else {
            return
        }

        manager.delegate?.windowManager(manager, didRecord: .down)

        if self.grid.y == self.grid.height - 1 {
            self.grid.height += 1
        }

        self.grid.y += 1

        if shift {
            self.grid.y    -= 1
            self.grid.ynum += 1
        }
    }

    /**
     * This function processes the up arrow key.
     */
    internal func processUpArrowKey(shift: Bool) {
        guard let manager = self.manager else {
            return
        }

        manager.delegate?.windowManager(manager, didRecord: .up)

        if shift && (self.grid.y != 0 || self.grid.height != 3) {
            self.grid.ynum += 1
        }

        if self.grid.height == 3 && self.grid.y > 0 {
            self.grid.y -= 1
        }

        if self.grid.y == 0 {
            self.grid.height += 1
        } else if self.grid.height != 3 {
            self.grid.y -= 1
        }
    }

    /**
     * This function processes an event retrieved from the event tap.
     */
    internal func process(event: NSEvent) -> Bool {
        let isShift = event.modifierFlags.contains(.shift)

        switch event.keyCode {
        case 123:
            // This is the left arrow key.
            self.processLeftArrowKey(shift: isShift)
        case 124:
            // This is the right arrow key.
            self.processRightArrowKey(shift: isShift)
        case 125:
            // This is the down arrow key.
            self.processDownArrowKey(shift: isShift)
        case 126:
            // This is the up arrow key.
            self.processUpArrowKey(shift: isShift)
        case 54, 55, 56, 60:
            // Command right, command left, shift left, shift right
            self.resetTimer()

            return true
        default:
            // Ending because of an unknown key.
            self.end()

            return event.keyCode == 53 || event.keyCode == 36
        }

        self.grid.normalize()

        self.delegate?.session(self, didUpdate: self.grid)
        self.manager?.session(self, didUpdate: self.grid)
        self.resetTimer()

        return true
    }

    // MARK: - Timeout

    /**
     * This function resets the timeout. The timeout is reset each time the user
     * presses a key.
     */
    private func resetTimer() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(timeInterval: Session.timeout,
                                                target: self,
                                              selector: #selector(tick),
                                              userInfo: nil, repeats: false)
    }

    /**
     * This function is called when the timer fires and ends the session.
     */
    @objc private func tick(timer: Timer) {
        self.end()
    }

    // MARK: - Ending

    /**
     * This function ends the session.
     */
    func end() {
        guard self.isActive else { return }

        self.isActive = false

        self.delegate?.sessionDidEnd(self)
        self.manager?.sessionDidEnd(self)
        self.timer?.invalidate()
    }

    /**
     * Upon deallocation, this function also makes sure to end the session,
     * thereby calling all the necessary delegate functions.
     */
    deinit {
        self.end()
    }
}
