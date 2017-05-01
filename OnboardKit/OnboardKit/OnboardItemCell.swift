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
 * The onboard item cell presents a single step.
 */
class OnboardItemCell : CollectionViewCell {
    /**
     * This is the title of the step that this cell represents. The title is
     * always visible.
     */
    let titleLabel: NSTextField = {
        let textField             = NSTextField()
        textField.isEditable      = false
        textField.isSelectable    = false
        textField.isBordered      = false
        textField.drawsBackground = false
        textField.textColor       = .labelColor
        textField.font            = .systemFont(ofSize: 17.0)
        return textField
    }()

    /**
     * This is the description that corresponds to the step that this cell
     * represents. The description is only visible when the cell is expanded.
     */
    let descriptionLabel: NSTextField = {
        let textField             = NSTextField()
        textField.isEditable      = false
        textField.isSelectable    = false
        textField.isBordered      = false
        textField.drawsBackground = false
        textField.textColor       = .labelColor
        textField.font            = .systemFont(ofSize: 14.0)
        textField.cell?.wraps     = true
        textField.alphaValue      = 0
        return textField
    }()

    /**
     * This is the badge view that indicates the step.
     */
    let badgeView = OnboardBadgeView(frame: NSRect(
             x: 31,
             y: 8,
         width: 32,
        height: 32
    ))

    /**
     * This is the checkmark view that appears as soon as the step is completed.
     */
    let checkmarkView: OnboardBadgeView = {
        let view = OnboardBadgeView(frame: NSRect(
                 x: 0,
                 y: 8,
             width: 32,
            height: 32
        ))

        view.style = .checkmark

        return view
    }()

    required init() {
        super.init()

        self.addSubview(self.badgeView)
        self.addSubview(self.checkmarkView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     * This is an array of buttons that are added to the cell, one for each
     * button in the corresponding OnboardItem.
     */
    private var buttons: [NSButton] = []

    /**
     * This is an array of views that are added to the cell, one for each view
     * in the corresponding OnboardItem. These views are similar to accessory
     * views in UITableViewCells on iOS.
     */
    private var views: [NSView]     = []

    /**
     * This property holds the onboard item that this cell should represent.
     * Upon changing this value, the cell updates its user interface state.
     */
    internal var item: OnboardItem? {
        didSet {
            guard let item = self.item else { return }

            self.titleLabel.stringValue       = item.title
            self.descriptionLabel.stringValue = item.description
            self.badgeView.text               = "\(self.indexPath.item + 1)"

            self.layout()

            self.buttons.forEach { $0.removeFromSuperview() }
            self.buttons.removeAll()

            var y: CGFloat = 11

            for (index, button) in item.buttons.enumerated() {
                let control = NSButton(frame: NSRect(
                         x: self.bounds.width - 120,
                         y: y,
                     width: 100,
                    height: 32
                ))
                control.autoresizingMask = .viewMinXMargin
                control.bezelStyle       = .rounded
                control.title            = button.title

                // Add default key binding.
                if button.type == .default {
                    control.keyEquivalent = "\r"
                }

                control.tag        = index
                control.target     = self
                control.action     = #selector(buttonPressed)
                control.alphaValue = (self.expanded ? 1.0 : 0.0)
                self.buttons.append(control)
                self.addSubview(control)

                y += control.frame.size.height - 4
            }

            self.views.forEach { $0.removeFromSuperview() }
            self.views.removeAll()

            for view in item.views {
                self.views.append(view)
                self.addSubview(view)
            }
        }
    }

    /**
     * This boolean indicates if the cell is expanded. In expanded state, the
     * cell displays the description and its buttons and views.
     */
    internal var expanded: Bool = false {
        didSet {
            self.descriptionLabel.alphaValue = (self.expanded ? 1.0 : 0.0)
            self.badgeView.style             = (self.expanded ? .focused :
                                                                .transparent)

            self.buttons.forEach { (button) in
                button.alphaValue = (self.expanded ? 1.0 : 0.0)
                button.isEnabled  =  self.expanded
            }

            self.views.forEach { (view) in
                view.alphaValue = (self.expanded ? 1.0 : 0.0)
            }
        }
    }

    /**
     * This boolean indicates if the item is completed. In completed state, the
     * cell shows a checkmark.
     */
    internal var completed: Bool = false {
        didSet {
            let scale = CGFloat(self.completed ? 1.0 : 2.0)
            self.checkmarkView.layer?.transform = CATransform3DMakeScale(scale,
                                                                         scale,
                                                                         1)
            self.checkmarkView.alphaValue = (self.completed ? 1.0 : 0.0)
        }
    }

    override var isFlipped: Bool {
        return true
    }

    // MARK: - Layout

    /**
     * In a horizontal layout, the buttons are shown at the right of the cell.
     */
    private func layoutHorizontally() {
        self.badgeView.frame.origin.x  = 15

        self.titleLabel.frame.origin.x = 15
        self.titleLabel.frame.origin.y = 52

        let size = self.descriptionLabel.sizeThatFits(NSSize(
             width: self.bounds.width - 15 - 15,
            height: 500
        ))
        self.descriptionLabel.frame.size = size

        self.descriptionLabel.frame.origin.x = 15
        self.descriptionLabel.frame.origin.y = self.titleLabel.frame.maxY + 4

        self.separator.frame = NSRect(
                 x: self.bounds.width - 1,
                 y: 0,
             width: 1,
            height: self.bounds.height
        )

        for (index, button) in self.buttons.reversed().enumerated() {
            button.frame.origin = NSPoint(
                x: self.bounds.midX - button.bounds.midX,
                y: self.bounds.height - 15 - 28 * CGFloat(index) - 32
            )
        }

        for view in self.views {
            view.frame.origin.x   = 15
            view.frame.size.width = self.bounds.width - 15 - 15
        }
    }

    /**
     * In a vertical layout, the buttons are shown at the bottom of the cell.
     */
    private func layoutVertically() {
        self.badgeView.frame.origin.x  = (94 - 32) / 2

        self.titleLabel.frame.origin.x = 94
        self.titleLabel.frame.origin.y = 25 - self.titleLabel.bounds.midY

        let size = self.descriptionLabel.sizeThatFits(NSSize(
             width: 380,
            height: 500
        ))
        self.descriptionLabel.frame.size = size

        self.descriptionLabel.frame.origin.x = 94
        self.descriptionLabel.frame.origin.y = 46

        for view in self.views {
            view.frame.origin.x   = 94
            view.frame.size.width = self.bounds.width - 94 - 15
        }
    }

    /**
     * We override this function to reposition all of the subviews, depending on
     * the layout of the controller.
     */
    override func layout() {
        super.layout()

        self.titleLabel.sizeToFit()

        if self.item?.controller?.direction == .horizontal {
            self.layoutHorizontally()
        } else {
            self.layoutVertically()
        }

        var y = CGFloat(0)

        for view in self.views {
            view.frame.origin.y   = self.descriptionLabel.frame.maxY + y
            y += view.frame.size.height
        }

        self.checkmarkView.frame.origin.x = self.bounds.width -
                                            self.checkmarkView.frame.width -
                                            20 + 2

        let scale     = CGFloat(self.completed ? 1.0 : 2.0)
        let transform = CATransform3DMakeScale(scale, scale, 1)
        self.checkmarkView.layer?.sublayerTransform = transform
    }

    // MARK: - Buttons

    /**
     * This function is called by a NSButton and propagates that event to the
     * action closure that correspond to that button.
     */
    func buttonPressed(_ sender: NSButton) {
        guard let item       = self.item, self.expanded else { return }
        guard let controller = item.controller else { return }

        let button = item.buttons[sender.tag]
        button.action(controller)
    }
}
