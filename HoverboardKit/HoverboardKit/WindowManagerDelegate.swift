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
 * This protocol should be implemented by all classes that want to receive
 * updates from the window manager. In our case, that's only the app delegate.
 */
public protocol WindowManagerDelegate : class {
    /**
     * This function is called to check if the window manager should start a new
     * session.
     */
    func windowManagerShouldStartSession(_ manager: WindowManager) -> Bool

    /**
     * This function is called when the command key is pressed a single time.
     */
    func windowManagerDidCancelSession(_ manager: WindowManager)

    /**
     * This function is called each time a trigger key is pressed (starting with
     * the first command key).
     */
    func windowManager(_ manager: WindowManager, didRecord key: Key)

    /**
     * This function is called after the modifier keypair is pressed (e.g. any
     * command key twice).
     */
    func windowManager(_ manager: WindowManager,
                       didStartTracking session: Session)

    /**
     * This function is called after the session ended (because of a timeout or
     * rejected key press).
     */
    func windowManager(_ manager: WindowManager,
                       didEndTracking session: Session)
}
