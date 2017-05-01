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
 * The session window controller is used to bridge the session (from
 * HoverboardKit) and the session window so that it reflects user interaction
 * during that session.
 */
class SessionWindowController : NSWindowController {
    let session: Session

    /**
     * The window controller must be initialized for each session. At the end of
     * a session, we must release the window controller. We do not recycle
     * session window controllers. Specify dark = true to show a dark hud,
     * rather than the light hud (by default).
     */
    init(session: Session, dark: Bool) {
        self.session = session

        let screen = session.screen ?? NSScreen.main()

        // Attempt to retrieve the screen width.
        let width = screen?.visibleFrame.size.width ?? 0

        // Center the hud to the screen horizontally. In my opinion it is better
        // to have it a bit lower than centered vertically, therefore I chose
        // 400px from the bottom (i.e. twice its height).
        var frame = NSRect(x: round(width - 200) / 2, y: 2 * 200,
                           width: 200, height: 200)

        if let screen = screen {
            frame.origin.x += screen.frame.origin.x
            frame.origin.y += screen.frame.origin.y
        }

        let window = SessionWindow(frame: frame)

        if dark == true {
            // In dark mode, selecting the vibrant dark appearance increases the
            // contrast between our symbol and grid and the blurred background.
            // In my opinion, that makes it look a bit nicer. Also, it seems to
            // be what Xcode and the built-in volume hud do as well.
            let appearance = NSAppearance(named: NSAppearanceNameVibrantDark)

            window.appearance          = appearance
            window.effectView.material = .dark
        }

        super.init(window: window)

        self.session.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.window?.close()
    }
}

extension SessionWindowController : SessionDelegate {
    func session(_ session: Session, didUpdate grid: Grid) {
        guard let window = self.window as? SessionWindow else {
            return
        }

        // Once the user presses an arrow key for the first time in this
        // session, we update the grid view which will therefore gain visibility
        // and remove the logo / symbol image view.
        window.gridView.grid = grid
        window.imageView.removeFromSuperview()
    }

    func sessionDidEnd(_ session: Session) {
        // As soon as the session ends, we fade out the window. Note that if the
        // session ends because a new session began, the session window is
        // released immediately and no fade out of the old window occurs. This
        // is a nice side-effect because two windows at the same time look
        // sub-optimal.
        NSAnimationContext.runAnimationGroup({ (context) in
            // Again, hyper parameter but I think this duration is quite good.
            context.duration = 0.4

            self.window?.animator().alphaValue = 0
        }) {
            self.window?.close()

            // TODO: this isn't really good practice.
            guard let delegate = NSApp.delegate as? AppDelegate else {
                return
            }

            if delegate.sessionWindowController === self {
                delegate.sessionWindowController = nil
            }
        }
    }
}
