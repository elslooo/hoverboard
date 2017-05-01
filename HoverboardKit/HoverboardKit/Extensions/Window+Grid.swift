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
 * This extension implements a property that updates the position and size of
 * the window according to the given grid.
 */
internal extension Window {
    /**
     * Setting this property to a new grid updates the position and size of the
     * window.
     */
    var grid: Grid? {
        set {
            guard let grid   = newValue,
                  let screen = self.screen else {
                return
            }

            var visibleFrame = screen.visibleFrame
            visibleFrame.origin.y = screen.frame.height - visibleFrame.maxY

            let width           = visibleFrame.width
            let height          = visibleFrame.height

            let x = grid.x / grid.width
            let y = grid.y / grid.height

            let bounds = NSRect(
                     x: visibleFrame.origin.x + x * width,
                     y: visibleFrame.origin.y + y * height,
                 width: grid.xnum * width  / grid.width,
                height: grid.ynum * height / grid.height
            )

            if self.isResizable {
                self.frame = bounds
            } else {
                let size   = self.size
                let origin = NSPoint(
                    x: bounds.origin.x + round(bounds.width  - size.width)  / 2,
                    y: bounds.origin.y + round(bounds.height - size.height) / 2
                )
                self.origin = origin
            }
        }

        get {
            return nil
        }
    }
}
