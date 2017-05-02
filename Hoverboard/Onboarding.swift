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
import HoverboardKit
import LetsMove
import OnboardKit

extension AppDelegate {
    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue,
                              forKey: "hasCompletedOnboarding")

            self.updater.automaticallyChecksForUpdates = newValue
        }
    }

    func setupOnboarding() {
        self.updater.automaticallyChecksForUpdates = self.hasCompletedOnboarding
        
        if !self.hasCompletedOnboarding {
            if self.onboardingWindowController == nil {
                self.setupOnboardingController()
            }
        }
    }

    func setupSetupController() {
        let title = "Getting Started with $(CFBundleName)"

        // swiftlint:disable line_length
        let controller = OnboardController(title: title, items: [
            OnboardItem(title: "Authorize Hoverboard", description: "In order to manage your windows, Hoverboard requests authorization. Please open System Preferences and make sure that 'Hoverboard' is checked.")
            .button(type: .default, title: "Authorize", action: { _ in
                self.authorizeManually()
            }),
            OnboardItem(title: "Launch Hoverboard at Startup (optional)", description: "We recommend to turn on Launch on Startup so Hoverboard is always running. You can always turn off this setting in the Hoverboard Preferences afterwards.")
            .button(type: .default, title: "Turn On", action: { (controller) in
                // TODO: decide if we should uncomment this line again.
                // PFMoveToApplicationsFolderIfNecessary()
                self.shouldLaunchAtStartup = true

                controller.selectItem(atIndex: 2, animated: true)
            })
            .button(type: .normal, title: "Skip", action: { (controller) in
                self.shouldLaunchAtStartup = false

                controller.selectItem(atIndex: 2, animated: true)
            }),
            OnboardItem(title: "Get to Know All of Hoverboard", description: "Well done! Now, to unleash the full potential of Hoverboard, let's see what it can do for you!")
            .button(type: .default, title: "Next", action: { _ in
                guard let windowController = self.onboardingWindowController,
                      let viewController   = self.walkthroughController else {
                    return
                }

                windowController.push(controller: viewController,
                                        animated: true)
            })
        ])
        // swiftlint:enable line_length

        controller.footerView = OnboardFooterView(text: "Need assistence?",
                                                  link: "Contact me", action: {
            guard let url = URL(string: "https://elsl.ooo/bio/") else {
                return
            }

            NSWorkspace.shared().open(url)
        })

        self.setupController = controller
    }

    func setupShortcutViews() {
        self.shortcutViews = []

        // Add the first shortcut view (cmd + cmd + left + up).
        do {
            let keys: [Key] = [ .command, .command, .left, .up ]

            let view = ShortcutView(keys: keys) { [weak self] in
                guard let controller = self?.walkthroughController else {
                    return
                }

                controller.selectItem(atIndex: 1, animated: true)
            }

            self.shortcutViews.append(view)
        }

        // Add the second shortcut view (cmd + cmd + left + left).
        do {
            let keys: [Key] = [ .command, .command, .left, .left ]

            let view = ShortcutView(keys: keys) { [weak self] in
                guard let controller = self?.walkthroughController else {
                    return
                }

                controller.selectItem(atIndex: 2, animated: true)
            }

            self.shortcutViews.append(view)
        }

        // Add the third shortcut view (cmd + cmd + left + shift left).
        // TODO: the shift is currently not enforced.
        do {
            let keys: [Key] = [ .command, .command, .left, .left ]

            let view = ShortcutView(keys: keys) { [weak self] in
                guard let windowController = self?.onboardingWindowController,
                      let controller       = self?.finishController else {
                    return
                }

                windowController.push(controller: controller, animated: true)
            }

            self.shortcutViews.append(view)
        }
    }

    func setupWalkthroughController() {
        let title = "Get to Know All of $(CFBundleName)"

        // swiftlint:disable line_length
        self.walkthroughController = OnboardController(title: title, items: [
            OnboardItem(title: "Move a Window", description: "Shortly press cmd twice, then a sequence of arrow keys.")
            .button(type: .normal, title: "Skip", action: {
                (controller) in
                controller.selectItem(atIndex: 1, animated: true)
            }).view(self.shortcutViews[0]),
            OnboardItem(title: NSLocalizedString("3x3 Grid", comment: ""),
                        description: NSLocalizedString("You can create up to three columns and rows.", comment: ""))
            .button(type: .normal, title: NSLocalizedString("Skip", comment: ""), action: {
                (controller) in
                controller.selectItem(atIndex: 2, animated: true)
            }).view(self.shortcutViews[1]),
            OnboardItem(title: NSLocalizedString("Twice the Size", comment: ""),
                        description: NSLocalizedString("Hold shift while pressing left for the second time.", comment: ""))
            .button(type: .normal, title: NSLocalizedString("Skip", comment: ""), action: {
                _ in
                guard let windowController = self.onboardingWindowController,
                      let signupController = self.finishController else {
                    return
                }

                windowController.push(controller: signupController,
                                        animated: true)
            }).view(self.shortcutViews[2])
        ])
        // swiftlint:disable line_length

        self.walkthroughController?.direction = .horizontal
    }

    func setupFinishController() {
        let title = "Welcome to $(CFBundleName)"

        self.finishController = OnboardFinishController(title: title)

        self.finishController?.closeBlock = {
            self.onboardingWindowController?.window?.close()

            self.hasCompletedOnboarding = true

            // TODO: verify that no other window is open.
            NSApp.setActivationPolicy(.accessory)
        }
    }

    /**
     * This function configures the entire onboarding process.
     */
    func setupOnboardingController() {
        self.setupShortcutViews()

        self.setupSetupController()
        self.setupWalkthroughController()
        self.setupFinishController()

        guard let controller = self.setupController else { return }

        // TODO: make sure to replace controller parameter name.
        let windowController = OnboardWindowController(controller: controller)
        windowController.showWindow(nil)

        self.onboardingWindowController = windowController
    }
}
