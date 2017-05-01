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
 * This should be the last controller in the onboarding guide.
 */
public class OnboardFinishController: NSViewController {
    /**
     * This function initializes the finish controller with the given title.
     */
    public init(title: String) {
        // swiftlint:disable force_unwrapping
        super.init(nibName: nil, bundle: nil)!
        // swiftlint:enable force_unwrapping

        self.title = title
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     * This image view shows the large green checkmark image.
     */
    private let imageView: NSImageView = {
        let view = NSImageView(frame: NSRect(
                 x: 266,
                 y: 60,
             width: 68,
            height: 68
        ))

        view.image = NSImage.largeCheckmark
        return view
    }()

    /**
     * This label shows some text that indicates that this is the final step and
     * that onboarding has now completed.
     */
    private let titleLabel: NSTextField = {
        let label = NSTextField(frame: NSRect(
                 x: 0,
                 y: 168,
             width: 600,
            height: 40
        ))

        label.stringValue     = "You're ready to go!"
        label.alignment       = .center
        label.drawsBackground = false
        label.isBordered      = false
        label.isEditable      = false
        label.isSelectable    = false
        label.font            = NSFont.systemFont(ofSize: 17)
        label.textColor       = NSColor.secondaryLabelColor

        label.sizeToFit()
        label.frame.origin.x = round((600 - label.bounds.width) / 2)
        return label
    }()

    /**
     * This button closes the onboarding window by calling the closeBlock.
     */
    private let closeButton: NSButton = {
        let button = NSButton(frame: NSRect(
                 x: 240,
                 y: 250,
             width: 120,
            height: 32
        ))

        button.bezelStyle    = .rounded
        button.title         = "Close"
        button.keyEquivalent = "\r"

        return button
    }()

    /**
     * This property should be set to a closure that closes the onboarding
     * window and saves the fact that onboarding has completed in persistant
     * storage.
     */
    public var closeBlock: ((Void) -> Void)?

    /**
     * We override this function to add our subviews to the view controller
     * view.
     */
    public override func loadView() {
        self.view = FlippedView(frame: NSRect(
                 x: 0,
                 y: 94,
             width: 600,
            height: 400 - 94
        ))

        self.view.addSubview(self.imageView)
        self.view.addSubview(self.titleLabel)

        self.closeButton.target = self
        self.closeButton.action = #selector(closeButtonPressed)
        self.view.addSubview(self.closeButton)
    }

    /**
     * This function is called by the close button and we propagate the event to
     * our close block.
     */
    @objc private func closeButtonPressed(_ sender: NSButton) {
        self.closeBlock?()
    }
}
