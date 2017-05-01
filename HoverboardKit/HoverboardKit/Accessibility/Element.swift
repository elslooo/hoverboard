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

// swiftlint:disable force_cast

/**
 * The Element class provides a wrapper around AXUIElement, which isn't very
 * elegant.
 */
internal class Element {
    /**
     * This property holds a reference to the underlying `AXUIElement`.
     */
    private let reference: AXUIElement

    /**
     * This function initializes a new element
     */
    internal init(reference: AXUIElement) {
        self.reference = reference

        // Make sure that the accessibility APIs do not block the main thread.
        AXUIElementSetMessagingTimeout(self.reference, 0.0)
    }

    // MARK: - Check for Setter

    func canSet(attribute: String) -> Bool {
        var settable: DarwinBoolean = false
        AXUIElementIsAttributeSettable(self.reference, attribute as CFString,
                                       &settable)
        return settable.boolValue
    }

    // MARK: - Getters

    internal func value(forAttribute attribute: String) -> AnyObject? {
        var value: AnyObject?
        AXUIElementCopyAttributeValue(self.reference, attribute as CFString,
                                      &value)
        return value
    }

    internal func value(forAttribute attribute: String,
                        parameter: AnyObject) -> AnyObject? {
        var value: AnyObject?

        AXUIElementCopyParameterizedAttributeValue(self.reference,
                                                   attribute as CFString,
                                                   parameter, &value)
        return value
    }

    internal func bool(forAttribute attribute: String) -> Bool {
        return self.value(forAttribute: attribute) as? Bool ?? false
    }

    internal func element(forAttribute attribute: String) -> AXUIElement? {
        if let value = self.value(forAttribute: attribute) {
            return (value as! AXUIElement)
        }

        return nil
    }

    internal func elements(forAttribute attribute: String) -> [AXUIElement] {
        var items: AnyObject?
        AXUIElementCopyAttributeValue(self.reference,
                                      kAXChildrenAttribute as CFString, &items)

        return items as? [AXUIElement] ?? []
    }

    internal func string(forAttribute attribute: String) -> String? {
        return self.value(forAttribute: attribute) as? String
    }

    internal func point(forAttribute attribute: String) -> NSPoint? {
        if let value = self.value(forAttribute: attribute) {
            var point = CGPoint()

            guard let type  = AXValueType(rawValue: kAXValueCGPointType) else {
                return nil
            }

            if AXValueGetValue(value as! AXValue, type, &point) {
                return point
            }
        }

        return nil
    }

    internal func size(forAttribute attribute: String) -> NSSize? {
        if let value = self.value(forAttribute: attribute) {
            var size = CGSize()

            guard let type = AXValueType(rawValue: kAXValueCGSizeType) else {
                return nil
            }

            if AXValueGetValue(value as! AXValue, type, &size) {
                return size
            }
        }

        return nil
    }

    internal func rect(forAttribute attribute: String) -> NSRect? {
        if let value = self.value(forAttribute: attribute) {
            var rect = NSRect()

            guard let type = AXValueType(rawValue: kAXValueCGRectType) else {
                return nil
            }

            if AXValueGetValue(value as! AXValue, type, &rect) {
                return rect
            }
        }

        return nil
    }

    // MARK: - Setters

    internal func set(value: AnyObject, for attribute: String) {
        AXUIElementSetAttributeValue(self.reference, attribute as CFString,
                                     value)
    }

    internal func set(bool: Bool, for attribute: String) {
        self.set(value: bool as AnyObject, for: attribute)
    }

    internal func set(point: NSPoint, for attribute: String) {
        var copy = point

        guard let type  = AXValueType(rawValue: kAXValueCGPointType),
              let value = AXValueCreate(type, &copy) else {
            return
        }

        self.set(value: value, for: attribute)
    }

    internal func set(size: NSSize, for attribute: String) {
        var copy = size

        guard let type  = AXValueType(rawValue: kAXValueCGSizeType),
              let value = AXValueCreate(type, &copy) else {
            return
        }

        self.set(value: value, for: attribute)
    }

    internal func set(rect: NSRect, for attribute: String) {
        var copy = rect

        guard let type  = AXValueType(rawValue: kAXValueCGRectType),
              let value = AXValueCreate(type, &copy) else {
            return
        }

        self.set(value: value, for: attribute)
    }

    // MARK: - Position + size

    internal var origin: NSPoint {
        get {
            return self.point(forAttribute: kAXPositionAttribute) ?? .zero
        }
        set {
            self.set(point: newValue, for: kAXPositionAttribute)
        }
    }

    internal var size: NSSize {
        get {
            return self.size(forAttribute: kAXSizeAttribute) ?? .zero
        }
        set {
            self.set(size: newValue, for: kAXSizeAttribute)
        }
    }

    internal var frame: NSRect {
        get {
            return self.rect(forAttribute: "AXFrame") ?? .zero
        }
        set {
            self.size   = newValue.size
            self.origin = newValue.origin
            self.size   = newValue.size
        }
    }

    internal var parent: Element? {
        if let ax = self.element(forAttribute: kAXParentAttribute) {
            return Element(reference: ax)
        }

        return nil
    }

    // MARK: - Actions

    internal func raise() -> Element {
        AXUIElementPerformAction(self.reference, kAXRaiseAction as CFString)

        return self
    }

    internal func press() -> Element {
        AXUIElementPerformAction(self.reference, kAXPressAction as CFString)

        return self
    }

    // MARK: - Children

    internal var children: [Element] {
        let attribute = kAXVisibleChildrenAttribute

        return self.elements(forAttribute: attribute).map(Element.init)
    }

}

// swiftlint:enable force_cast
