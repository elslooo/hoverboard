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
 * This class is used internally to quickly configure custom error messages.
 */
internal class Error : Swift.Error, CustomStringConvertible {
    /**
     * We can use this error code for e.g. Github issues. These codes must be
     * very specific: we must not use the same error code at multiple places in
     * our project.
     */
    internal let code: Int

    /**
     * This message is supposed to be shown to the user. It should be
     * appropriately clear what is wrong (even though sometimes this is of
     * course not possible).
     */
    internal let message: String

    /**
     * This function initializes a new error with the given code and message.
     * Only use this in this file.
     */
    fileprivate init(code: Int, message: String) {
        self.code    = code
        self.message = NSLocalizedString(message, comment: "")
    }

    /**
     * We overrides because we want our custom message to show up in the
     * console.
     */
    var description: String {
        return self.message + " (\(self.code))"
    }

    /**
     * We overrides because we want our custom message to show up in our user
     * interface.
     */
    var localizedDescription: String {
        return self.message + " (\(self.code))"
    }

    // swiftlint:disable line_length

    // -1 unauthorized
    static let unauthorized = Error(code: -1, message: "Hoverboard does not have permission to manage windows of other applications.")

    // -2 event tap failed (EventTap.setupPort)
    static let eventTapFailed = Error(code: -2, message: "Creating a new event tap failed.")

    // -3 run loop source failed (EventTap.setupSource)
    static let runLoopSourceFailed = Error(code: -3, message: "Creating a new run loop source failed.")

    // -4 invalid event tap (EventTap.start and EventTap.stop)
    static let invalidEventTap = Error(code: -4, message: "Event tap is not valid.")

    // swiftlint:enable line_length
}
