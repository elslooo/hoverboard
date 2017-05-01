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
 * This is the preference key that we use to store and retrieve whether or not
 * the user wants Hoverboard to launch when our they start their computer.
 */
fileprivate let key = "shouldLaunchAtStartup"

/**
 * In this extension we add a property to the app delegate that retrieves from
 * the preferences whether or not Hoverboard should launch when our users start
 * their computer.
 */
extension AppDelegate {
    /**
     * This property returns the user's preference to launch Hoverboard at
     * startup. As a side-effect, it also updates the login item if necessary to
     * make sure that it reflects that preference. If updating fails, it will
     * return the actual state of the login item, regardless of whether it
     * reflects the user preference or not.
     */
    var shouldLaunchAtStartup: Bool {
        get {
            // Make sure to re-enable or disable the login item depending on the
            // user preference.
            let enabled              = UserDefaults.standard.bool(forKey: key)
            LoginItem.main.isEnabled = enabled

            // We return the actual state of the login item, rather than the
            // user preference. This means that if enabling the login item
            // fails, the UI will reflect that.
            return LoginItem.main.isEnabled
        }

        set {
            // We first save the new preference, then (attempt to) enable or
            // disable the login item.
            UserDefaults.standard.set(newValue, forKey: key)
            LoginItem.main.isEnabled = newValue
        }
    }

    /**
     * This function should be called at startup to make sure that the login
     * item state reflects the user preference.
     */
    func setupLaunchAtStartup() {
        // Similar to the getter, we need to make sure that the login item
        // reflects the user preference.
        let enabled              = UserDefaults.standard.bool(forKey: key)
        LoginItem.main.isEnabled = enabled
    }
}
