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
 * This class represents a single step in the onboarding process.
 */
public class OnboardItem {
    /**
     * This is a weak reference to the owning onboarding controller.
     *
     * NOTE: we need this because of OnboardItemCell but in the future it would
     *       be nice to be able to remove this.
     */
    weak var controller: OnboardController?

    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title       = title
        self.description = description
    }

    // MARK: - Buttons

    public private(set) var buttons: [OnboardButton] = []

    public func button(type: OnboardButtonType, title: String,
                       action: @escaping (OnboardController) -> Void)
                       -> OnboardItem {
        let button = OnboardButton(type: type, title: title, action: action)
        self.buttons.append(button)

        return self
    }

    // MARK: - Views

    public private(set) var views: [NSView] = []

    public func view(_ view: NSView) -> OnboardItem {
        self.views.append(view)

        return self
    }
}
