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
 * An application is a specific type of accessibility element with some
 * additional properties that I have removed from this implementation because we
 * don't need them anyway.
 */
internal class Application : Element {
    /**
     * This property returns the key window of this application.
     */
    internal var keyWindow: Window? {
        let attribute = kAXFocusedWindowAttribute

        guard let reference = self.element(forAttribute: attribute) else {
            return nil
        }

        return Window(reference: reference)
    }

    /**
     * This property returns the currently active application (if any).
     */
    internal static var active: Application? {
        let applications = NSWorkspace.shared().runningApplications

        // Retrieve the first running application that is active.
        guard let active = applications.first(where: { $0.isActive }) else {
            return nil
        }

        // Create a new element with the process identifier of the active
        // application.
        let reference = AXUIElementCreateApplication(active.processIdentifier)
        return Application(reference: reference)
    }
}
