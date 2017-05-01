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

extension AppDelegate {
    /**
     * This function checks if we have authorization to manage windows of other
     * applications and updates the onboarding user interface accordingly if
     * necessary.
     */
    func checkForAuthorization() {
        if self.authorizationManager.isAuthorized {
            guard let controller = self.setupController else {
                return
            }

            if controller.indexOfSelectedItem < 1 {
                controller.selectItem(atIndex: 1, animated: true)
            }
        } else {
            guard let controller = self.setupController else {
                return
            }

            if controller.indexOfSelectedItem > 0 {
                controller.selectItem(atIndex: 0, animated: true)
            }
        }
    }

    /**
     * This function prompts the user to grand authorization to Hoverboard for
     * managing windows of other applications.
     *
     * NOTE: below macOS 10.12 we were able to automatically authorize it (after
     *       user consent). Unfortunately due to a misunderstanding by some
     *       users about the way this was implemented by Dropbox, this is no
     *       longer an option.
     */
    func authorizeManually() {
        let options: [String : Bool] = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
        ]

        if AXIsProcessTrustedWithOptions(options as CFDictionary) {
            self.checkForAuthorization()
        }
    }
}
