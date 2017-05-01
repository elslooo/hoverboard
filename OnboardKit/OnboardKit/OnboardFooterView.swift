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

public class OnboardFooterView : NSView {
    /**
     * This is the text that is shown in the footer view.
     */
    public var text: String = ""

    /**
     * This is the text in the link that is shown.
     */
    public var link: String = ""

    /**
     * This is the closure that gets called when the user presses the link.
     */
    public var action: ((Void) -> Void)?

    /**
     * This is the label that shows the regular text.
     */
    private let label: NSTextField = {
        let label             = NSTextField()
        label.isSelectable    = false
        label.isEditable      = false
        label.isBordered      = false
        label.drawsBackground = false
        label.textColor       = .secondaryLabelColor
        label.font            = .systemFont(ofSize: 14)

        return label
    }()

    /**
     * This is the link button.
     */
    private let button: Button = {
        let button = Button()
        button.isBordered = false

        return button
    }()

    /**
     * This function initializes a footer view with the given regular text, link
     * text and action that gets called when the user presses that link.
     */
    public init(text: String, link: String, action: @escaping (Void) -> Void) {
        super.init(frame: .zero)

        self.text   = text
        self.link   = link
        self.action = action

        self.label.stringValue = text
        self.label.sizeToFit()

        self.label.frame.origin.x = 94

        let underlineStyle  = NSUnderlineStyle.styleSingle.rawValue
        let attributedTitle = NSAttributedString(string: link, attributes: [
            NSForegroundColorAttributeName: NSColor.link,
            NSFontAttributeName:            NSFont.systemFont(ofSize: 14),
            NSUnderlineStyleAttributeName:  underlineStyle
        ])
        self.button.attributedTitle = attributedTitle
        self.button.sizeToFit()
        self.button.frame.origin.x = self.label.frame.maxX + 2
        self.button.target         = self
        self.button.action         = #selector(buttonPressed)
        self.button.cursor         = .pointingHand()

        self.addSubview(self.label)
        self.addSubview(self.button)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var isFlipped: Bool {
        return true
    }

    public override var allowsVibrancy: Bool {
        return true
    }

    // MARK: - Button

    /**
     * This function gets called by the NSButton and propagates that event to
     * the action closure.
     */
    func buttonPressed(_ sender: NSButton) {
        self.action?()
    }

    // MARK: - Layout

    /**
     * We override this function to vertically center the label and button.
     */
    public override func layout() {
        super.layout()

        self.label.frame.origin.y  = self.bounds.midY -
                                     self.label.frame.midY - 3
        self.button.frame.origin.y = self.bounds.midY -
                                     self.button.frame.midY - 3
    }
}
