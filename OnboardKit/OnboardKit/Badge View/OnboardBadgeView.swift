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
 * This is the badge view that we incorporate in onboard item cells to indicate
 * the order and state of steps.
 */
internal class OnboardBadgeView : NSView {
    /**
     * We initialize 3 views: one for each badge style. To transition between
     * each state, we simply fade between those views.
     */
    private var views: [OnboardBadgeStyle : OnboardBadgeStyleView] = [:]

    /**
     * The default style is transparent. Upon changing this value, we switch the
     * alpha values of the views that correspond to the old and new badge style.
     */
    internal var style: OnboardBadgeStyle = .transparent {
        didSet {
            if let oldView = self.views[oldValue] {
                oldView.alphaValue = 0.0
            }

            if let newView = self.views[self.style] {
                newView.alphaValue = 1.0
            }
        }
    }

    /**
     * This is the text that should be shown in the badge. We propagate changes
     * to the individual styled badge views.
     */
    internal var text: String = "" {
        didSet {
            for view in self.views.values {
                view.text = text
            }
        }
    }

    /**
     * This function initializes the badge view with the given frame.
     */
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect.insetBy(dx: -2, dy: -2))

        self.wantsLayer = true

        for style in [ OnboardBadgeStyle.transparent,
                       OnboardBadgeStyle.focused,
                       OnboardBadgeStyle.checkmark ] {
            let view = OnboardBadgeStyleView(frame: self.bounds, style: style)

            if style != .transparent {
                view.alphaValue = 0
            }

            self.addSubview(view)

            // Keep a reference to this view for this particular style.
            views[style] = view
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
