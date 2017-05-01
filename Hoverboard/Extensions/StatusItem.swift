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

import ElsloooKit
import Foundation

extension AppDelegate {
    /**
     * We assign a tag to each menu item for which we want to dynamically update
     * attributes (such as their title or checkmark visibility).
     */
    enum MenuItemTag : Int {
        case lightMode         = 1
        case darkMode          = 2
        case launchAtStartup   = 3
        case disableHour       = 4
        case disableCurrentApp = 5
    }

    /**
     * This property returns an array of bundle identifiers
     * (e.g. com.apple.safari) for which our user has indicated that they want
     * to disable Hoverboard (e.g. because of conflicting keybindings).
     */

    var disabledApplications: [String] {
        get {
            let key       = "disabledApplications"
            let bundleIDs = UserDefaults.standard.array(forKey: key)

            return bundleIDs as? [String] ?? []
        }

        set {
            let key = "disabledApplications"
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    /**
     * This property returns a date that our user has set until which Hoverboard
     * should not be active. As soon as this date expires, this function will
     * return nil. As an implementation detail: we do not update the timestamp
     * that is stored in the user defaults. Instead, we verify that it is not
     * expired in the getter and update it in the setter.
     */
    var disabledUntil: Date? {
        get {
            let interval = UserDefaults.standard.double(forKey: "disabledUntil")

            let date = Date(timeIntervalSince1970: interval)

            if date < Date() {
                return nil
            } else {
                return date
            }
        }

        set {
            UserDefaults.standard.set(newValue?.timeIntervalSince1970,
                                      forKey: "disabledUntil")
        }
    }

    /**
     * This property returns a boolean that indicates whether the user has
     * enabled dark mode (true) or light mode (false, default).
     */
    var isDarkMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isDarkMode")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
        }
    }

    /**
     * This function dynamically updates the given menu item to change its state
     * (checkmark visibility) or title.
     */
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let tag = MenuItemTag(rawValue: menuItem.tag) else {
            return true
        }

        switch tag {
        case .lightMode:
            menuItem.state = !self.isDarkMode ? NSOnState : NSOffState
        case .darkMode:
            menuItem.state =  self.isDarkMode ? NSOnState : NSOffState
        case .launchAtStartup:
            menuItem.state = LoginItem.main.isEnabled ? NSOnState : NSOffState
        case .disableHour:
            menuItem.state = self.disabledUntil != nil ? NSOnState : NSOffState
        case .disableCurrentApp:
            guard let application = NSRunningApplication.foreground,
                  let name        = application.localizedName,
                  let bundleID    = application.bundleIdentifier else {
                // If there is no application running in foreground or if it has
                // no name or bundle identifier we show no specific name. For
                // now it seems suitable and it just postpones the actual
                // problem until after the user clicks on this item.
                let title = NSLocalizedString("for current app", comment: "")
                menuItem.title = title

                return true
            }

            let disabled   = self.disabledApplications.contains(bundleID)
            menuItem.title = NSLocalizedString("for ", comment: "") + name
            menuItem.state = disabled ? NSOnState : NSOffState
        }

        return true
    }

    /**
     * This function shows my own about window. If you decide to fork this
     * project, make sure to replace my about window with your own or the
     * default about panel by Apple. My about window is not open source and may
     * not be incorporated into other apps.
     */
    func showAboutPanel() {
        // We need to keep a reference to the window controller for as long as
        // the window is shown. Otherwise, it'll immediately close because its
        // retain count drops to zero.
        self.aboutWindowController = AboutWindowController()
        self.aboutWindowController?.window?.delegate = self
        self.aboutWindowController?.showWindow(nil)

        NSApp.activate(ignoringOtherApps: true)
    }

    /**
     * This function is called by the light mode menu item to switch to light
     * mode.
     */
    func enableLightMode() {
        self.isDarkMode = false
    }

    /**
     * This function is called by the dark mode menu item to switch to dark
     * mode.
     */
    func enableDarkMode() {
        self.isDarkMode = true
    }

    /**
     * This function toggles between the launch at startup user preference and
     * updates the LoginItem accordingly.
     */
    func toggleLaunchAtStartup() {
        self.shouldLaunchAtStartup = !self.shouldLaunchAtStartup
    }

    /**
     * This function is called by its corresponding menu item to disable
     * Hoverboard.
     */
    func disableHour() {
        if self.disabledUntil == nil {
            self.disabledUntil = Date().addingTimeInterval(3600)
        } else {
            self.disabledUntil = nil
        }
    }

    /**
     * This function is called by its corresponding menu item to disable
     * Hoverboard for the application currently in foreground.
     */
    func disableCurrentApp() {
        guard let application = NSRunningApplication.foreground,
              let identifier  = application.bundleIdentifier else {
            return
        }

        if self.disabledApplications.contains(identifier) {
            let results = self.disabledApplications.filter { (existing) in
                return existing != identifier
            }

            self.disabledApplications = results
        } else {
            self.disabledApplications.append(identifier)
        }
    }

    /**
     * This property returns a new options menu.
     */
    var optionsMenu: NSMenu {
        let menu = NSMenu()

        // Add the light mode item.
        do {
            let title = NSLocalizedString("Light Mode", comment: "")
            let item  = menu.addItem(withTitle: title,
                                        action: #selector(enableLightMode),
                                 keyEquivalent: "")
            item.tag = MenuItemTag.lightMode.rawValue
        }

        // Add the dark mode item.
        do {
            let title    = NSLocalizedString("Dark Mode", comment: "")
            let darkItem = menu.addItem(withTitle: title,
                                           action: #selector(enableDarkMode),
                                    keyEquivalent: "")
            darkItem.tag = MenuItemTag.darkMode.rawValue
        }

        // Add separator item.
        menu.addItem(.separator())

        // Add the launch at startup item.
        let title = NSLocalizedString("Launch at Startup", comment: "")
        let item  = menu.addItem(withTitle: title,
                                    action: #selector(toggleLaunchAtStartup),
                             keyEquivalent: "")
        item.tag  = MenuItemTag.launchAtStartup.rawValue

        return menu
    }

    /**
     * This property returns a new disable menu.
     */
    var disableMenu: NSMenu {
        let menu = NSMenu()

        // Add the disable for an hour item.
        do {
            let title = NSLocalizedString("for an hour", comment: "")
            let item  = menu.addItem(withTitle: title,
                                        action: #selector(disableHour),
                                 keyEquivalent: "")
            item.tag  = MenuItemTag.disableHour.rawValue
        }

        // Add the disable for current app item.
        do {
            let title = NSLocalizedString("for current app", comment: "")
            let item  = menu.addItem(withTitle: title,
                                        action: #selector(disableCurrentApp),
                                 keyEquivalent: "")
            item.tag  = MenuItemTag.disableCurrentApp.rawValue
        }

        return menu
    }

    /**
     * This function configures the status menu. This function should be called
     * only once.
     */
    func setupStatusMenu() {
        self.statusItem.length = NSSquareStatusItemLength

        // The menu will look like this:
        //
        // About
        // Documentation
        // -----------------
        // Options
        // Disable
        // -----------------
        // Check for Updates
        // Quit Hoverboard

        // Add About Hoverboard item that shows a small window with credits and
        // version info.
        do {
            let title = NSLocalizedString("About Hoverboard", comment: "")
            self.statusMenu.addItem(withTitle: title,
                                       action: #selector(showAboutPanel),
                                keyEquivalent: "")
        }

        // Add Documentation item that opens a web browser and directs it to
        // our help page with key commands.
        do {
            let title = NSLocalizedString("Documentation", comment: "")
            self.statusMenu.addItem(withTitle: title,
                                       action: #selector(openDocumentation),
                                keyEquivalent: "")
        }

        // Add separator item.
        self.statusMenu.addItem(.separator())

        // Add Options submenu that users can use to activate Launch on Startup
        // and Dark Mode.
        do {
            let title    = NSLocalizedString("Options", comment: "")
            let item     = self.statusMenu.addItem(withTitle: title,
                                                      action: nil,
                                               keyEquivalent: "")
            item.submenu = self.optionsMenu
        }

        // Add Disable submenu that users can use to temporarily deactivate
        // Hoverboard.
        do {
            let title    = NSLocalizedString("Disable", comment: "")
            let item     = self.statusMenu.addItem(withTitle: title,
                                                      action: nil,
                                               keyEquivalent: "")
            item.submenu = self.disableMenu
        }

        // Add separator item.
        self.statusMenu.addItem(.separator())

        // Check for Updates let's users check for updates through Sparkle.
        do {
            let title = NSLocalizedString("Check for Updates...", comment: "")
            self.statusMenu.addItem(withTitle: title,
                                       action: #selector(checkForUpdates),
                                keyEquivalent: "")
        }

        // Quit Hoverboard terminates Hoverboard and removes it from the status
        // bar tray.
        do {
            let title = NSLocalizedString("Quit Hoverboard", comment: "")
            self.statusMenu.addItem(withTitle: title,
                                       action: #selector(NSApp.terminate),
                                keyEquivalent: "")
        }
    }

    /**
     * This function configures the Hoverboard status item that is always
     * visible.
     */
    func setupStatusItem() {
        statusItem.image             = NSImage(named: "Hoverboard-Mini")
        statusItem.image?.isTemplate = true
        statusItem.highlightMode     = true

        statusItem.menu              = self.statusMenu
    }

    /**
     * This function opens the browser and navigates to the documentation of
     * Hoverboard on my website.
     *
     * TODO: this function still needs to be implemented.
     */
    func openDocumentation() {

    }
}
