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
 * This class is modeled after UICollectionViewCell on iOS and renders one row
 * in a collection view. It should be instantiated by the collection view.
 */
internal class CollectionViewCell : NSView {
    /**
     * This is a thin line at the bottom of the cell. Subclasses can access this
     * property e.g. to hide it if necessary.
     */
    internal let separator = Separator()

    /**
     * This holds the index path for the row that is represented by this cell.
     */
    internal var indexPath = IndexPath()

    required init() {
        super.init(frame: .zero)

        self.addSubview(self.separator)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Separator Insets

    /**
     * This refers to the spacing around the separator.
     */
    public var separatorInsets = NSEdgeInsetsZero {
        didSet {
            self.layout()
        }
    }

    // MARK: - Layout

    /**
     * We override this function to update the separator frame according to the
     * separator insets.
     */
    override func layout() {
        super.layout()

        self.separator.frame = NSRect(
                 x: self.separatorInsets.left,
                 y: self.frame.height - self.separatorInsets.bottom - 1,
             width: self.frame.width  - self.separatorInsets.horizontal,
            height: self.frame.height - self.separatorInsets.vertical
        )
    }
}
