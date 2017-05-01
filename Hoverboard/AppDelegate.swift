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

import Cocoa
import ElsloooKit
import HockeySDK
import HoverboardKit
import OnboardKit
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // The status item is the center of control for our user. It is always shown
    // as long as the app is running.
    let statusItem = NSStatusBar.system().statusItem(withLength: 0)
    let statusMenu = NSMenu()

    // This is the window manager, basically the highest level of abstraction in
    // HoverboardKit. This manager runs a global key listener on cmd-cmd,
    // handles window movement and resizing, basically everything.
    var manager: WindowManager?

    // These window and view controllers are used for the onboarding tour.
    var onboardingWindowController: OnboardWindowController?
    var setupController: OnboardController?
    var walkthroughController: OnboardController?
    var finishController: OnboardFinishController?

    // Updater instance from Sparkle. It is automatically configured with the
    // settings provided in Info.plist.
    let updater = SUUpdater()

    // This timer makes sure to regularly check for updates since the Sparkle
    // timer is broken unfortunately.
    var updateTimer: Timer?

    // These are the shortcut views currently present. We use these to highlight
    // key presses during the onboarding tour. Pretty ugly method to accomplish
    // that so we'll need to find a better solution in the future.
    var shortcutViews: [ShortcutView] = []

    // The Authorization Manager is used to listen to changes in the TCC
    // (privacy database). If the user revokes our authorization to manage
    // windows of other apps, we show the onboarding again to explain why we
    // need authorization.
    let authorizationManager = AuthorizationManager()

    // The session window is shown as soon as our user hits any of the two
    // command-keys shortly and twice in a row.
    var sessionWindowController: SessionWindowController?

    // This one is imported from ElsloooKit. Replace it with something of your
    // own or Apple's built-in about window if you decide to fork this project.
    var aboutWindowController: AboutWindowController?

    // This instance makes sure that the Dock icon appears only when there are
    // windows.
    let activationPolicy = ActivationPolicy()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // We listen to the privacy database to receive a callback when our
        // access is granted or revoked.
        self.authorizationManager.delegate = self

        // Disable all existing login items that contain the "Hoverboard" name.
        // Mostly this is to remove older versions of Hoverboard (before
        // open-sourcing it). In our `setupLaunchAtStartup()` we make sure to
        // add a new LoginItem if necessary.
        LoginItem.all.filter({ (item) in
            item.url.absoluteString.contains("Hoverboard")
        }).forEach { (item) in
            item.isEnabled = false
        }

        // We use HockeyApp to collect crash reports and **anonymous**
        // statistics (such as the total number of users and total number of
        // sessions). None of that information should be individually
        // identifiable.
        let identifier = "833320ca1c24464aa92b85ff477a8986"
        BITHockeyManager.shared().configure(withIdentifier: identifier)
        BITHockeyManager.shared().start()

        // Each of these is provided in an extension to remove the clutter from
        // this file.
        self.setupLaunchAtStartup()
        self.setupOnboarding()
        self.setupStatusMenu()
        self.setupStatusItem()

        let selector = #selector(checkForUpdatesInBackground)
        let timer    = Timer.scheduledTimer(timeInterval: 3600.0, target: self,
                                                selector: selector,
                                                userInfo: nil, repeats: true)
        self.updateTimer = timer

        self.checkForUpdatesInBackground()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // This is a 'sanity check' in case the authorization manager doesn't
        // update.
        self.checkForAuthorization()
    }
}

// MARK: - Window Manager Delegate

extension AppDelegate : WindowManagerDelegate {
    func windowManagerShouldStartSession(_ manager: WindowManager) -> Bool {
        if let identifier = NSRunningApplication.foreground?.bundleIdentifier {
            if self.disabledApplications.contains(identifier) {
                return false
            }
        }

        return self.disabledUntil == nil
    }

    func windowManager(_ manager: WindowManager, didRecord key: Key) {
        if self.hasCompletedOnboarding == false {
            self.shortcutViews.forEach { (view) in
                view.process(key: key)
            }
        }
    }

    func windowManagerDidCancelSession(_ manager: WindowManager) {
        if self.hasCompletedOnboarding == false {
            self.shortcutViews.forEach { (view) in
                view.process(key: nil)
            }
        }
    }

    func windowManager(_ manager: WindowManager,
                       didStartTracking session: Session) {
        if self.hasCompletedOnboarding == false {
            NSApp.activate(ignoringOtherApps: true)
        }

        let controller = SessionWindowController(session: session,
                                                    dark: self.isDarkMode)
        controller.showWindow(nil)

        self.sessionWindowController = controller
    }

    func windowManager(_ manager: WindowManager,
                       didEndTracking session: Session) {
        if self.hasCompletedOnboarding == false {
            self.shortcutViews.forEach { (view) in
                view.process(key: nil)
            }
        }
    }
}

extension AppDelegate : NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        let window = notification.object as? NSWindow

        if window === self.aboutWindowController?.window {
            self.aboutWindowController = nil
        }
    }
}
