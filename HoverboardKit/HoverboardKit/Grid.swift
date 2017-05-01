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

public struct Grid {
    // swiftlint:disable identifier_name
    public var x: CGFloat      = 0.0
    public var y: CGFloat      = 0.0
    // swiftlint:enable identifier_name

    public var xnum: CGFloat   = 1.0
    public var ynum: CGFloat   = 1.0
    public var width: CGFloat  = 1.0
    public var height: CGFloat = 1.0

    public mutating func normalize() {
        self.width  = min(3.0, self.width)
        self.height = min(3.0, self.height)
        self.x      = min(self.width  - 1.0, self.x)
        self.y      = min(self.height - 1.0, self.y)
        self.x      = max(0, self.x)
        self.y      = max(0, self.y)
        self.xnum   = min(self.xnum, self.width)
        self.ynum   = min(self.ynum, self.height)
        self.x      = min(self.x, self.width  - self.xnum)
        self.y      = min(self.y, self.height - self.ynum)
    }
}
