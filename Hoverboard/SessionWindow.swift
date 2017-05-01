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

import AppKit
import Foundation
import HoverboardKit

/**
 * The session window is a slightly blurred hud window that appears for a little
 * over a second during which the user can adjust the position and size of the
 * foreground window.
 */
class SessionWindow : NSWindow {
    /**
     * The effect view is the background view of our hud window that gives it a
     * blurry appearance.
     */
    let effectView = NSVisualEffectView()

    /**
     * The image view contains our logo / symbol (⌘). This is shown until the
     * user presses the first key, after which the symbol disappears and the
     * grid is shown.
     */
    let imageView  = NSImageView()

    /**
     * The grid view reflects the current positioning of the window. The window
     * controller accesses this property to update its grid.
     */
    let gridView   = GridView()

    /**
     * This function initializes and configures the session window.
     */
    init(frame: CGRect) {
        super.init(contentRect: frame,
                     styleMask: .borderless,
                       backing: .buffered,
                         defer: false)

        self.level = Int(CGWindowLevelKey.floatingWindow.rawValue)

        self.isOpaque             = false
        self.backgroundColor      = .clear
        self.isReleasedWhenClosed = false

        self.setupEffectView()
        self.setupMaskImage()
        self.setupImageView()
        self.setupGridView()
    }

    /**
     * This function configures the effect view.
     */
    func setupEffectView() {
        guard let contentView = self.contentView else {
            return
        }

        self.effectView.frame    = contentView.bounds
        self.effectView.material = .light
        self.effectView.state    = .active
        contentView.addSubview(self.effectView)
    }

    /**
     * This function configures a mask image for the effect view. This is
     * necessary because by default, the effect view is rectangular and we want
     * it to have round corners (like the rest of macOS).
     */
    func setupMaskImage() {
        let image = NSImage(size: self.effectView.bounds.size, flipped: false) {
            (frame) -> Bool in
            let path = NSBezierPath(roundedRect: frame,
                                        xRadius: 20,
                                        yRadius: 20)
            NSColor.black.setFill()
            path.fill()
            return true
        }
        self.effectView.maskImage = image
    }

    /**
     * This function configures the logo / symbol image view.
     */
    func setupImageView() {
        guard let contentView = self.contentView else { return }

        self.imageView.frame = contentView.bounds
        self.imageView.image = NSImage(named: "Session-window-icon")

        // Make sure that it is templated so that it appears vibrant in the
        // effect view.
        self.imageView.image?.isTemplate = true

        self.effectView.addSubview(self.imageView)
    }

    /**
     * This function configures a new grid view. As long as its grid property is
     * nill, it won't be visible to the user.
     */
    func setupGridView() {
        guard let contentView = self.contentView else { return }

        self.gridView.frame = contentView.bounds
        self.effectView.addSubview(self.gridView)
    }
}
