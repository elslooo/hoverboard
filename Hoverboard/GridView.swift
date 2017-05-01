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

class GridView : NSView {
    var grid: Grid? = nil {
        didSet {
            self.subviews.forEach { $0.removeFromSuperview() }

            guard let grid = self.grid else { return }

            let width  = (CGFloat(140) - 10 * (grid.width  - 1)) / grid.width
            let height = (CGFloat(140) - 10 * (grid.height - 1)) / grid.height

            let size = NSSize(width: 140, height: 140)

            let view = NSImageView(frame: NSRect(x: 30, y: 30,
                                                 width: 140, height: 140))
            view.image = NSImage(size: size, flipped: true, drawingHandler: {
                [weak self] (frame) -> Bool in
                NSColor.black.setFill()

                guard let grid = self?.grid else {
                    return false
                }

                for x in 0 ..< Int(grid.width) {
                    for y in 0 ..< Int(grid.height) {
                        let x1 = Int(grid.x),
                            x2 = x1 + Int(grid.xnum)
                        let y1 = Int(grid.y),
                            y2 = y1 + Int(grid.ynum)

                        if x == x1 && y == y1 {
                            let frame = NSRect(
                                     x: CGFloat(x) * (width + 10),
                                     y: CGFloat(y) * (height + 10),
                                 width: (width  + 10) * CGFloat(x2 - x1) - 10,
                                height: (height + 10) * CGFloat(y2 - y1) - 10
                            )

                            let xRadius = min(20, width / 4)
                            let yRadius = min(20, height / 4)
                            let radius  = min(xRadius, yRadius)

                            let path = NSBezierPath(roundedRect: frame,
                                                        xRadius: radius,
                                                        yRadius: radius)

                            if !(x >= x1 && x < x2 && y >= y1 && y < y2) {
                                let rect = frame.insetBy(dx: 4, dy: 4)
                                path.appendRoundedRect(rect,
                                              xRadius: radius - 4,
                                              yRadius: radius - 4)
                            }

                            path.windingRule = .evenOddWindingRule
                            path.fill()
                        } else if x >= x1 && x < x2 && y >= y1 && y < y2 {

                        } else {
                            let frame = NSRect(
                                     x: CGFloat(x) * (width + 10),
                                     y: CGFloat(y) * (height + 10),
                                 width: width,
                                height: height
                            )

                            let xRadius = min(20, width  / 4)
                            let yRadius = min(20, height / 4)
                            let radius  = min(xRadius, yRadius)

                            let path = NSBezierPath(roundedRect: frame,
                                                        xRadius: radius,
                                                        yRadius: radius)

                            let rect = frame.insetBy(dx: 4, dy: 4)
                            path.appendRoundedRect(rect,
                                          xRadius: radius - 4,
                                          yRadius: radius - 4)

                            path.windingRule = .evenOddWindingRule
                            path.fill()
                        }
                    }
                }

                return true
            })
            view.image?.isTemplate = true
            self.addSubview(view)
        }
    }
}
