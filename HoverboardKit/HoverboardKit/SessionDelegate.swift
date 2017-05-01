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
 * The session delegate protocol should be implemented by classes that want to
 * get updates about a specific session. Specifically, the `SessionWindow`
 * conforms to this protocol.
 */
public protocol SessionDelegate : class {
    /**
     * This function is called when the user presses arrow keys to move a
     * window.
     */
    func session(_ session: Session, didUpdate grid: Grid)

    /**
     * This function is called when the session times out. This can happen
     * because of three things:
     *
     * 1. The user pressed [esc] or [enter] (key is ignored).
     * 2. The user pressed an unrecognized key (key is sent to active app).
     * 3. The session timed out (after 1s).
     */
    func sessionDidEnd(_ session: Session)
}
