//
//  ActivationPolicy.swift
//  Hoverboard
//
//  Created by Tim van Elsloo on 4/21/17.
//  Copyright © 2017 Tim van Elsloo. All rights reserved.
//

import AppKit
import Foundation

class ActivationPolicy {
    private var timer: Timer?

    /**
     * This function initializes this policy and registers our update function
     * with the notification center.
     */
    init() {
        let center = NotificationCenter.default

        center.addObserver(self, selector: #selector(updateActivationPolicy),
                           name: .NSWindowDidBecomeKey, object: nil)

        center.addObserver(self, selector: #selector(updateActivationPolicy),
                           name: .NSWindowWillClose, object: nil)
    }

    /**
     * This function deregisters our update functions from the notification
     * center.
     */
    deinit {
        let center = NotificationCenter.default

        center.removeObserver(self, name: .NSWindowDidBecomeKey, object: nil)
        center.removeObserver(self, name: .NSWindowWillClose, object: nil)
    }

    /**
     * This function updates the activation policy (the visibility of the Dock
     * icon) according to the number of windows.
     */
    @objc func updateActivationPolicy(notification: Notification) {
        // Filter status bar windows from the list of all windows.
        var windows = NSApp.windows.filter({ (window) -> Bool in
            return !(window is SessionWindow) &&
                window.level != Int(CGWindowLevelForKey(.statusWindow))
        })

        // If the event is NSWindowWillClose, we have to remove that window from
        // the list.
        let window = notification.object as? NSWindow

        if notification.name == .NSWindowWillClose {
            windows = windows.filter { $0 !== window }
        }

        // Update the activation policy.
        if windows.count > 0 {
            self.timer?.invalidate()

            if NSApp.activationPolicy() == .regular {
                return
            }

            NSApp.setActivationPolicy(.regular)

            // We focus the loginwindow process.
            let app = NSWorkspace.shared().runningApplications[0]
            app.activate(options: .activateIgnoringOtherApps)

            let current = NSRunningApplication.current()
            current.activate(options: .activateIgnoringOtherApps)
        } else {
            self.resetTimer()
        }
    }

    func resetTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                          selector: #selector(tick),
                                          userInfo: nil, repeats: false)
    }

    @objc func tick() {
        NSApp.setActivationPolicy(.accessory)
    }
}
