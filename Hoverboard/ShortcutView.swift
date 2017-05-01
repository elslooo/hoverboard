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

/**
 * The shortcut view visualizes a key combo and can highlight individual keys
 * (in order) upon the user pressing them.
 */
class ShortcutView : NSView {
    /**
     * This is the alignment of this shortcut view. This determines what side
     * the image views are aligned to.
     */
    private let alignment: NSTextAlignment

    /**
     * This is an array of keys that this shortcut view visualizes (in that
     * particular order) and listens for.
     */
    private let keys: [Key]

    /**
     * Collection of keys and their corresponding image view.
     */
    private var views: [(key: Key, imageView: NSImageView)] = []

    /**
     * This is the callback that gets called when all keys have been pressed in
     * order in the same session.
     */
    private let closure: (Void) -> Void

    /**
     * Initialize a new shortcut view that is left-aligned (default).
     *
     * NOTE: this separate initializer is necessary because of an issue with the
     *       Swift compiler. I expect this function to be no longer needed in
     *       the future.
     */
    convenience init(keys: [Key], closure: @escaping (Void) -> Void) {
        self.init(keys: keys, closure: closure, alignment: .left)
    }

    /**
     * Initialize a new shortcut view with custom alignment.
     *
     * TODO: right alignment is currently unsupported.
     */
    public init(keys: [Key], closure: @escaping (Void) -> Void,
                alignment: NSTextAlignment) {
        self.alignment = alignment
        self.closure   = closure
        self.keys      = keys

        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 114))

        self.wantsLayer = true

        self.setupImageViews()
        self.setupIncentiveLabel()
    }

    /**
     * This function configures the image views.
     */
    private func setupImageViews() {
        var offsetX: CGFloat = 0

        if alignment == .center {
            offsetX = round((200 - CGFloat(keys.count) * 40 - 10) / 2)
        }

        for (index, key) in keys.enumerated() {
            let frame = NSRect(
                     x: offsetX + CGFloat(index) * 40,
                     y: 30,
                 width: 34,
                height: 34
            )

            let view = NSImageView(frame: frame)
            self.views.append((key, view))
            self.addSubview(view)

            self.set(highlighted: false, at: index)
        }
    }

    /**
     * This function configures a text field to show a few encouraging words.
     */
    private func setupIncentiveLabel() {
        let text = NSLocalizedString("Go ahead! Give it a try!", comment: "")

        let textField             = NSTextField()
        textField.isEditable      = false
        textField.isSelectable    = false
        textField.isBordered      = false
        textField.drawsBackground = false
        textField.font            = NSFont.systemFont(ofSize: 14.0)
        textField.textColor       = NSColor.tertiaryLabelColor
        textField.stringValue     = text
        textField.sizeToFit()
        textField.frame.origin.y  = 84

        if self.alignment == .center {
            textField.frame.origin.x = round((200 - textField.bounds.width) / 2)
        }

        self.addSubview(textField)
    }

    /**
     * This is a sparse array that maps indices to booleans that indicate if the
     * key for that index has been pressed during the session that is currently
     * active.
     */
    var highlighted: [NSInteger:Bool] = [:]

    /**
     * This function highlights the key at the given index.
     */
    func set(highlighted: Bool, at index: NSInteger) {
        let (key, view) = self.views[index]

        let prefix = (highlighted ? "Key-highlighted-" : "Key-")

        self.highlighted[index] = highlighted

        view.image = NSImage(named: prefix + key.rawValue)
    }

    /**
     * This function processes the given key. In order to reset all highlighted
     * keys, pass nil.
     */
    func process(key: Key?) {
        if self.alphaValue == 0 {
            return
        }

        guard let key = key else {
            (0 ..< self.keys.count).forEach { (index) in
                self.set(highlighted: false, at: index)
            }

            return
        }

        let highlighted = self.highlighted.filter({ $0.value }).count

        /**
         * If all keys are highlighted already, there is nothing we should do.
         */
        if highlighted >= self.keys.count { return }

        /**
         * Find out what key we expect to be pressed next.
         */
        let expectedNext = self.keys[highlighted]

        if expectedNext == key {
            self.set(highlighted: true, at: highlighted)
        } else {
            self.process(key: nil)
        }

        if self.highlighted.filter({ $0.value }).count == self.keys.count {
            DispatchQueue.main.async {
                self.closure()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        return true
    }

    override var allowsVibrancy: Bool {
        return true
    }
}
