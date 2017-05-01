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

extension AppDelegate : AuthorizationManagerDelegate {
    /**
     * In this function we update our user interface if necessary to reflect
     * whether or not Hoverboard is authorized to manage windows of other
     * applications.
     */
    func authorizationManagerDidGrantAccess(_ manager: AuthorizationManager) {
        if self.hasCompletedOnboarding == false {
            // If the user has not completed onboarding, we make sure to present
            // the onboarding window controller. It will also activate (focus)
            // the app and show our icon in the dock.
            if self.onboardingWindowController == nil {
                self.setupOnboardingController()
            }

            NSApp.activate(ignoringOtherApps: true)
            NSApp.setActivationPolicy(.regular)
        } else {
            // If the user has already completed onboarding, we don't have to do
            // anything other than to make sure that the icon is not shown in
            // the dock.
            NSApp.setActivationPolicy(.accessory)
        }

        do {
            // Initialize and configure a new window manager.
            try self.manager = WindowManager()
            self.manager?.delegate = self
            try self.manager?.start()

            // If we are in the process of onboarding, make sure that the user
            // interface reflects the change in authorization.
            if let setupController = self.setupController {
                if setupController.indexOfSelectedItem < 2 &&
                   LoginItem.main.isEnabled {
                    setupController.selectItem(atIndex: 2, animated: true)
                } else if setupController.indexOfSelectedItem < 1 {
                    setupController.selectItem(atIndex: 1, animated: true)
                }
            }
        } catch let error {
            // TODO: we need to propagate this error to the user interface.
            print("Error: \(error)")
        }
    }

    /**
     * In this function we update the user interface state to reflect that
     * authorization to Hoverboard for managing windows of other applications
     * has been revoked.
     */
    func authorizationManagerDidRevokeAccess(_ manager: AuthorizationManager) {
        NSApp.setActivationPolicy(.regular)

        self.hasCompletedOnboarding = false

        if let controller      = self.onboardingWindowController,
           let setupController = self.setupController {
            // We need to show the onboarding window, pop it to the first view
            // controller and select the first stage (authorization).
            controller.showWindow(nil)
            controller.pop(controller: setupController, animated: true)
            self.setupController?.selectItem(atIndex: 0, animated: true)
        } else {
            self.setupOnboardingController()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
