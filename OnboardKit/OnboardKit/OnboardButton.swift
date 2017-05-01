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
 * There are two types of buttons. Default buttons are blue, focused and can be
 * activated by pressing enter. Normal buttons are gray. There can be only one
 * default button in a window.
 */
public enum OnboardButtonType {
    case normal
    case `default`
}

/**
 * An onboard button is represented by an NSButton. This is modeled after
 * UIAlertAction on iOS.
 */
public struct OnboardButton {
    /**
     * This is the type of the button.
     */
    public let type:   OnboardButtonType

    /**
     * This is the localized title of the button.
     */
    public let title:  String

    /**
     * This is the action closure that should be called upon pressing the button
     * or enter if it is the default button.
     */
    public let action: (OnboardController) -> Void

    /**
     * This function initializes a button with the given type, title and action.
     */
    public init(type: OnboardButtonType, title: String,
                action: @escaping (OnboardController) -> Void) {
        self.type   = type
        self.title  = title
        self.action = action
    }
}
