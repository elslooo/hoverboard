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

fileprivate let bundle = Bundle(for: OnboardBadgeStyleView.self)

/**
 * This extension implements some computed properties that return image
 * resources.
 */
internal extension NSImage {
    /**
     * This property returns the blue badge image that indicates the current
     * step.
     */
    static var badge: NSImage {
        return bundle.image(forResource: "Badge") ?? NSImage()
    }

    /**
     * This property returns the green checkmark image that has the same size as
     * a badge and indicates that a step has been completed.
     */
    static var checkmark: NSImage {
        return bundle.image(forResource: "Checkmark") ?? NSImage()
    }

    /**
     * This property returns a large green checkmark image that is shown in the
     * last step.
     */
    static var largeCheckmark: NSImage {
        return bundle.image(forResource: "Checkmark-large") ?? NSImage()
    }
}
