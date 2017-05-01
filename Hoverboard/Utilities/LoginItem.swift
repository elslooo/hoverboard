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
 * This class provides a wrapper around LSSharedFileListItem for
 * kLSSharedFileListSessionLoginItems.
 */
public class LoginItem {
    /**
     * A login item is referenced by its url of the application to start at
     * launch.
     */
    public let url: URL

    /**
     * If this login item already exists, we keep a reference to the
     * corresponding `LSSharedFileListItem` so we can use that to remove it
     * later on.
     */
    private var reference: LSSharedFileListItem?

    /**
     * This is a login item for the main bundle. Most of the time, this is the
     * only login item you will need. The only exception is when you're bundling
     * helper apps.
     *
     * - NOTE: this does not mean that the login item is automatically added to
     *         the system.
     */
    public static let main = LoginItem(url: Bundle.main.bundleURL)

    /**
     * This function initializes a new login item with the given url. It does
     * not automatically enable it, however. If it already exists, it also does
     * not disable it.
     */
    public init(url: URL) {
        self.url = url

        if let item = LoginItem.all.first(where: { $0.url == url }) {
            self.reference = item.reference
        }
    }

    /**
     * This function initializes a new login item with the given native
     * reference.
     */
    private init?(reference: LSSharedFileListItem) {
        self.reference = reference

        let resolutionFlags = UInt32(kLSSharedFileListNoUserInteraction |
                                     kLSSharedFileListDoNotMountVolumes)

        // We retrieve the url that corresponds to the given item. For some
        // reason, Apple indicates that this method may fail, therefore this
        // initializer is failable as well.
        guard let url = LSSharedFileListItemCopyResolvedURL(reference,
                                                            resolutionFlags,
                                                            nil) else {
            return nil
        }

        self.url = url.takeUnretainedValue() as URL
    }

    /**
     * This property returns a list of all login items registered on the user
     * system.
     *
     * - NOTE: this also includes login items for other applications.
     */
    public static var all: [LoginItem] {
        // We want to retrieve login items.
        let type = kLSSharedFileListSessionLoginItems.takeUnretainedValue()

        // If we cannot retrieve them (I guess for example if the app is
        // sandboxed), this call will fail and we return an empty array.
        guard let items = LSSharedFileListCreate(nil, type, nil) else {
            return []
        }

        let list = items.takeUnretainedValue()

        // Snapshot seed can be used to update an existing snapshot (educated
        // guess). We don't need that.
        var seed: UInt32 = 0

        guard let copy = LSSharedFileListCopySnapshot(list, &seed) else {
            return []
        }

        guard let snapshot = copy.takeUnretainedValue() as?
                             [LSSharedFileListItem] else {
            return []
        }

        var results: [LoginItem] = []

        for item in snapshot {
            guard let item = LoginItem(reference: item) else {
                continue
            }

            results.append(item)
        }

        // At least in Swift 3.1, memory of the file list and its snapshot is
        // managed by the system and we should not manually release any of it.

        return results
    }

    /**
     * This property returns a boolean that reflects whether or not the login
     * item is actually enabled. Upon changing this value, we automatically add
     * or remove the login item from / to the system's login items list. This
     * operation may fail, in which case the getter will reflect the actual
     * state of the login item.
     */
    var isEnabled: Bool {
        get {
            return LoginItem.all.contains(where: { $0.url == self.url })
        }
        set {
            if self.isEnabled == newValue {
                return
            }
            // We want to retrieve login items.
            let type = kLSSharedFileListSessionLoginItems.takeUnretainedValue()

            guard let items = LSSharedFileListCreate(nil, type, nil) else {
                return
            }

            if newValue {
                // I am not sure why this is an optional. My guess would be it
                // may not be available on all systems and is NULL or nil on
                // earlier systems.
                guard let order = kLSSharedFileListItemBeforeFirst else {
                    return
                }

                LSSharedFileListInsertItemURL(items.takeUnretainedValue(),
                                              order.takeUnretainedValue(), nil,
                                              nil, self.url as CFURL, nil, nil)

                if let item = LoginItem.all.first(where: { $0.url == url }) {
                    self.reference = item.reference
                }
            } else {
                LSSharedFileListItemRemove(items.takeUnretainedValue(),
                                           self.reference)

                self.reference = nil
            }
        }
    }
}
