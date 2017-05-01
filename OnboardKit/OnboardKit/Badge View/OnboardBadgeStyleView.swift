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
 * This is the actual styled badge view. To make life a bit easier I decided to
 * do all the styling in this class and simply fade between instances of it
 * rather than implementing the fading in this class as well. In the future, if
 * we want to do complex animations, we will need to integrate this with
 * OnboardBadgeView.
 */
internal class OnboardBadgeStyleView : NSView {
    /**
     * This if the label field.
     */
    private let textField: NSTextField = {
        let textField             = NSTextField()
        textField.isEditable      = false
        textField.isSelectable    = false
        textField.isBordered      = false
        textField.drawsBackground = false
        textField.textColor       = .white
        textField.font            = .systemFont(ofSize: 17)
        textField.alignment       = .center

        textField.wantsLayer      = true

        return textField
    }()

    /**
     * This is the text that should be shown in the label field.
     */
    public var text: String = "" {
        didSet {
            self.textField.stringValue = text
            self.textField.sizeToFit()

            self.textField.frame.size.width = self.frame.width
            self.textField.frame.origin.y   = self.frame.midY -
                                              self.textField.bounds.midY - 1
        }
    }

    /**
     * This function initializes a new styled badge view in the given frame and
     * with the given style. Note that the style is immutable after
     * initialization.
     */
    public init(frame frameRect: NSRect, style: OnboardBadgeStyle) {
        super.init(frame: frameRect)

        self.wantsLayer = true

        if style == .transparent {
            self.textField.textColor = .black
        } else if style == .focused {
            let imageView = NSImageView(frame: NSRect(
                     x: 1,
                     y: 2,
                 width: 34,
                height: 34
            ))
            imageView.image = NSImage.badge
            self.addSubview(imageView)
        } else if style == .checkmark {
            let imageView = NSImageView(frame: NSRect(
                     x: 1,
                     y: 2,
                 width: 34,
                height: 34
            ))
            imageView.image = NSImage.checkmark
            self.addSubview(imageView)
        }

        if style != .checkmark {
            self.addSubview(self.textField)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        return true
    }
}
