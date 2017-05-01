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
 * This class is inspired by UINavigationBar.
 */
internal class NavigationBar : NSView {
    /**
     * This is the title that is shown in the navigation bar. This overrides
     * attributedTitle if it is set later.
     */
    public var title: String? {
        didSet {
            self.titleLabel.stringValue = self.title ?? ""

            self.layout()
        }
    }

    /**
     * This is the attributed title that is shown in the navigation bar. This
     * overrides title if it is set later.
     */
    public var attributedTitle: NSAttributedString? {
        didSet {
            guard let attributedTitle = self.attributedTitle else {
                self.titleLabel.stringValue = ""
                return
            }

            self.titleLabel.attributedStringValue = attributedTitle

            self.layout()
        }
    }

    /**
     * The navigation bar always shows an image view that displays the app icon.
     */
    private let imageView  = NSImageView(frame: NSRect(
             x: 15,
             y: 15,
         width: 64,
        height: 64
    ))

    /**
     * The navigation bar always shows a title that depends on the view
     * controller that is currently visible.
     */
    private let titleLabel = NSTextField(frame: NSRect(
             x: 94,
             y: 25,
         width: 0,
        height: 34
    ))

    /**
     * This function initializes the navigation bar with the given frame.
     */
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.setupImageView()
        self.setupTitleLabel()
        self.setupSeparator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     * This function configures the image view.
     */
    func setupImageView() {
        // Here we retrieve the app icon from its NSBundle.
        let bundle = Bundle.main

        // Make sure there is an icon set.
        let key = "CFBundleIconFile"

        guard let value = bundle.object(forInfoDictionaryKey: key),
              let name  = value as? String else {
            return
        }

        // Make sure that we can retrieve a path to that icon.
        guard let path = bundle.pathForImageResource(name) else {
            return
        }

        // Open image and assign it to the image view.
        self.imageView.image = NSImage(contentsOfFile: path)

        // Finally, add the image view to the navigation bar.
        self.addSubview(self.imageView)
    }

    /**
     * This function configures the title label.
     */
    func setupTitleLabel() {
        // Make sure it isn't editable, bordered, etc.
        self.titleLabel.isEditable      = false
        self.titleLabel.isSelectable    = false
        self.titleLabel.isBordered      = false
        self.titleLabel.drawsBackground = false

        // Set font and color. Secondary label color makes sure it gets some
        // vibrancy in an effect view.
        self.titleLabel.font            = .systemFont(ofSize: 24)
        self.titleLabel.textColor       = .secondaryLabelColor

        self.addSubview(self.titleLabel)
    }

    /**
     * This function configures the separator.
     */
    func setupSeparator() {
        let separator = Separator(frame: NSRect(
                 x: 0,
                 y: self.bounds.height - 1,
             width: self.bounds.width,
            height: 1
        ))

        self.addSubview(separator)
    }

    override var isFlipped: Bool {
        return true
    }

    override var allowsVibrancy: Bool {
        return true
    }

    /**
     * We override this function to reposition the title label.
     */
    override func layout() {
        super.layout()

        // Make sure that the title label can fit the title.
        self.titleLabel.sizeToFit()

        // Next, center the title label.
        var frame             = self.titleLabel.frame
        frame.origin.y        = round((self.bounds.height - frame.height) / 2)
        self.titleLabel.frame = frame
    }
}
