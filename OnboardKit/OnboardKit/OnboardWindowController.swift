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
 * This controller is responsible for an onboarding window. Instead of
 * instantiating a onboarding window directly, this controller should be used.
 */
public class OnboardWindowController : NSWindowController {
    /**
     * This property holds the view controller that is currently visible.
     */
    public private(set) var viewController: NSViewController? {
        didSet {
            self.updateViewController()
        }
    }

    /**
     * This function initializes the onboarding window controller with the given
     * root view controller.
     */
    public init(controller: NSViewController) {
        let window = OnboardWindow(frame: NSRect(
                 x: 0,
                 y: 0,
             width: 600,
            height: 400
        ))

        super.init(window: window)

        self.viewController = controller
        self.updateViewController()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Controllers

    /**
     * This function updates the view controller that is currently shown.
     */
    func updateViewController() {
        // Retrieve the window from this controller.
        guard let window = self.window as? OnboardWindow else { return }

        // Update the title of the navigation bar.
        var title: NSAttributedString?
        title = TitleFormatter.format(string: self.viewController?.title)

        window.navigationBar.attributedTitle = title

        // Finally, add the view controller to the window content view.
        guard let view = self.viewController?.view else { return }

        let holderView = NSView(frame: NSRect(
                 x: 0,
                 y: 94,
             width: 600,
            height: 400 - 94
        ))
        view.frame     = holderView.bounds
        holderView.addSubview(view)
        self.holderView = holderView
    }

    // MARK: - Visibility

    /**
     * We override this function to make sure that the window is positioned at
     * the center of the screen.
     */
    public override func showWindow(_ sender: Any?) {
        // Center window in its screen.
        guard let window = self.window else { return }
        guard let screen = window.screen else { return }

        let frame = screen.visibleFrame
        let origin = NSPoint(x: frame.midX - window.frame.midX,
                             y: frame.midY - window.frame.midY)

        window.setFrameOrigin(origin)

        super.showWindow(sender)
    }

    // MARK: - Navigation

    /**
     * The holder view is used as part of the transition to mask its child view
     * without the child view resizing its own subviews.
     */
    var holderView = NSView() {
        didSet {
            self.window?.contentView?.addSubview(self.holderView)
        }
    }

    /**
     * This function performs the actual transition to a new view controller.
     * Gravity determines the orientation of the translation.
     */
    public func transition(controller: NSViewController, animated: Bool,
                           gravity: CGFloat) {
        guard let contentView = self.window?.contentView else {
            return
        }

        if self.viewController == controller {
            return
        }

        let oldView = self.holderView // else { return }

        self.viewController = controller

        let newView = self.holderView

        let shadow = NSView(frame: oldView.frame)
        shadow.wantsLayer = true
        shadow.layer?.backgroundColor = NSColor(white: 0, alpha: 0.1).cgColor
        shadow.alphaValue = 0
        self.window?.contentView?.addSubview(shadow)

        newView.frame.origin.x   = contentView.bounds.width
        newView.frame.size.width = contentView.bounds.size.width

        if gravity < 0 {
            shadow.alphaValue = 1

            newView.frame.origin.x   = -50
            newView.frame.size.width =  50
            shadow.frame.size.width  =  0
        }

        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration                = 0.6
                context.allowsImplicitAnimation = true
                context.timingFunction          = CAMediaTimingFunction.spring()

                shadow.alphaValue               = 1

                if gravity < 0 {
                    newView.frame.size.width = contentView.bounds.size.width
                    oldView.frame.origin.x  += newView.frame.width
                    shadow.frame.size.width  = newView.frame.width

                    shadow.alphaValue        = 0
                } else {
                    oldView.frame.size.width = 50
                    shadow.frame.size.width  = 50
                    oldView.frame.origin.x  -= 50
                    shadow.frame.origin.x   -= 50
                }

                newView.frame.origin.x = 0
            }) {
                oldView.removeFromSuperview()
                shadow.removeFromSuperview()
            }
        }
    }

    /**
     * This functions pops the current stack / history to the given view
     * controller.
     *
     * NOTE: the given view controller should conceptually be an item on the
     *       stack but since we don't keep track of a stack, this requirement is
     *       currently not enforced.
     */
    public func pop(controller: NSViewController, animated: Bool) {
        self.transition(controller: controller, animated: animated, gravity: -1)
    }

    /**
     * This functions pushes the given view controller on the stack.
     */
    public func push(controller: NSViewController, animated: Bool) {
        self.transition(controller: controller, animated: animated, gravity: 1)
    }
}
