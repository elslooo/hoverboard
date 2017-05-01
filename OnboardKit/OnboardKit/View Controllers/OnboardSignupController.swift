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
 * This view controller provides users with the option to signup for a
 * newsletter. The newsletter subscription mechanism should be written by the
 * user of this class.
 */
public class OnboardSignupController: NSViewController {
    /**
     * This function initializes a signup controller with the given title.
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
                 y: 20,
             width: 68,
            height: 68
        ))

        view.image = NSImage.largeCheckmark

        return view
    }()

    /**
     * This label indicates to the user that the onboarding has almost
     * completed.
     */
    private let titleLabel: NSTextField = {
        let label = NSTextField(frame: NSRect(
                 x: 0,
                 y: 108,
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
     * This label explains why users should signup for the newsletter.
     */
    private let textLabel: NSTextField = {
        let label = NSTextField(frame: NSRect(
                 x: 0,
                 y: 138,
             width: 400,
            height: 40
        ))

        let string = "Signup for the $(CFBundleName) Newsletter to be kept " +
                     "up-to-date and get weekly tips-and-tricks."

        label.stringValue     = TitleFormatter.format(string: string) ?? ""
        label.alignment       = .left
        label.drawsBackground = false
        label.isBordered      = false
        label.isEditable      = false
        label.isSelectable    = false
        label.font            = NSFont.systemFont(ofSize: 14)
        label.textColor       = NSColor.secondaryLabelColor
        label.alphaValue      = 0.75

        let size             = label.sizeThatFits(NSSize(width: 400, height: 0))
        label.frame.origin.x = 100
        label.frame.size     = size

        return label
    }()

    /**
     * This text field is meant for the user to enter their email address into.
     */
    private let textField: NSTextField = {
        let field = NSTextField(frame: NSRect(
                 x: 100,
                 y: 208,
             width: 240,
            height: 30
        ))

        field.font              = NSFont.systemFont(ofSize: 20)
        field.placeholderString = "Your email address"

        return field
    }()

    /**
     * This is the default button that users press to sign up for the
     * newsletter.
     */
    private let signupButton: NSButton = {
        let button = NSButton(frame: NSRect(
                 x: 340,
                 y: 204,
             width: 140,
            height: 41
        ))

        button.bezelStyle    = .rounded
        button.keyEquivalent = "\r"
        button.title         = "Signup"
        button.action        = #selector(signupButtonPressed)
        return button
    }()

    /**
     * This is the button that users can press if they do not want to sign up
     * for the newsletter.
     */
    private let skipButton: NSButton = {
        let button = NSButton(frame: NSRect(
                 x: 350,
                 y: 250,
             width: 120,
            height: 32
        ))

        button.bezelStyle    = .rounded
        button.title         = "Skip"
        button.action        = #selector(skipButtonPressed)
        return button
    }()

    /**
     * This closure gets called when the user presses the signup button or
     * presses enter while filling in their email address. The first parameter
     * is the email address that is filled in.
     */
    public var signupBlock: ((String) -> Void)?

    /**
     * This closure gets called when the user presses the skip button.
     */
    public var skipBlock:   ((Void)   -> Void)?

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
        self.view.addSubview(self.textLabel)
        self.view.addSubview(self.textField)
        self.view.addSubview(self.signupButton)
        self.view.addSubview(self.skipButton)

        self.signupButton.target = self
        self.skipButton.target   = self
    }

    /**
     * We override this function to make sure that the email field is focused as
     * soon as the controller appears.
     */
    public override func viewDidAppear() {
        super.viewDidAppear()

        self.textField.becomeFirstResponder()
    }

    /**
     * This function is called by the signup button and propagates that event to
     * the signup block.
     */
    @objc private func signupButtonPressed(_ sender: NSButton) {
        self.signupBlock?(self.textField.stringValue)
    }
    /**
     * This function is called by the skip button and propagates that event to
     * the skip block.
     */
    @objc private func skipButtonPressed(_ sender: NSButton) {
        self.skipBlock?()
    }
}
