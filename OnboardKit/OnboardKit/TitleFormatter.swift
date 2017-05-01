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
 * This formatter is used to substitute a placeholder and replace it with a
 * (capitalized) app name.
 */
internal class TitleFormatter {
    /**
     * This function formats the given string by substituting a placeholder with
     * the name of the main bundle.
     */
    internal class func format(string: String?) -> String? {
        guard let result = string else { return nil }
        guard let name   = Bundle.main.name else { return result }

        return result.replacingOccurrences(of: "$(CFBundleName)", with: name)
    }

    /**
     * This function formats the given string by substituting a placeholder with
     * the name of the main bundle. In addition, the app name is also
     * highlighted in black.
     */
    internal class func format(string: String?) -> NSAttributedString? {
        guard let string = string else { return nil }

        let result = NSMutableAttributedString(string: string)

        let range = (result.string as NSString).range(of: "$(CFBundleName)")

        if range.location != NSNotFound {
            guard let name = Bundle.main.name else {
                return result.copy() as? NSAttributedString
            }

            let part = NSAttributedString(string: name, attributes: [
                NSForegroundColorAttributeName: NSColor.black
            ])

            result.replaceCharacters(in: range, with: part)
        }

        return result.copy() as? NSAttributedString
    }
}
