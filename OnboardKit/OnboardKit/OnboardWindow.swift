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
 * This is the window that is used for onboarding. This window should not be
 * used directly. Instead, use OnboardWindowController.
 */
internal class OnboardWindow : NSWindow {
    /**
     * This is responsible for the translucent, blurry background of the window.
     */
    let effectView = VisualEffectView()

    /**
     * This is the navigation bar that is shown at the top of the window.
     */
    let navigationBar = NavigationBar(frame: NSRect(
             x: 0,
             y: 0,
         width: 600,
        height: 94
    ))

    /**
     * This function initializes the window with the given frame.
     */
    init(frame: CGRect) {
        let styleMask: NSWindowStyleMask = [ .titled, .fullSizeContentView ]

        super.init(contentRect: frame, styleMask: styleMask,
                       backing: .buffered, defer: true)

        // The window should be a bit blurred.
        self.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)

        self.titlebarAppearsTransparent  = true
        self.contentView                 = self.effectView
        self.isMovableByWindowBackground = true

        self.effectView.state    = .active
        self.effectView.material = .light
        self.effectView.addSubview(self.navigationBar)
    }
}
