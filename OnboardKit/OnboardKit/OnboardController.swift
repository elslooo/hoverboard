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
 * The onboard controller is a view controller that can be passed to the onboard
 * window controller. It consists of a collection view that shows each of the
 * individual steps (`items`) that are passed to an instance of this class.
 */
public class OnboardController : NSViewController {
    /**
     * This is an array that holds all the onboard items for this controller.
     */
    public let items: [OnboardItem]

    /**
     * This is the direction of this view controller. For example, the setup
     * controller uses a vertical direction and the walkthrough controller uses
     * an horizontal direction.
     */
    public var direction: OnboardDirection = .vertical {
        didSet {
            self.collectionView.reloadData()
        }
    }

    /**
     * This can be set to a view that should be shown at the bottom of the
     * controller.
     *
     * NOTE: this is currently only tested for vertical controllers.
     */
    public var footerView: NSView? {
        didSet {
            self.collectionView.footerView = self.footerView
        }
    }

    /**
     * This function initializes a controller with the given title and items.
     */
    public init(title: String, items: [OnboardItem]) {
        self.items = items

        // swiftlint:disable force_unwrapping
        super.init(nibName: nil, bundle: nil)!
        // swiftlint:enable force_unwrapping

        self.title = title
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     * This is the collection view of this controller. We use it to display all
     * items.
     */
    private let collectionView = CollectionView()

    /**
     * We override this item to replace the view controller default view with
     * our collection view. We also register our cell for a static reuse
     * identifier. This is similar to `viewDidLoad()` on iOS.
     */
    public override func loadView() {
        self.view = self.collectionView

        self.collectionView.register(class: OnboardItemCell.self, for: "Item")
        self.collectionView.dataSource = self
    }

    // MARK: - Selected Item

    /**
     * This property holds the index of the item that is currently selected.
     * Unlike iOS, there is always at least and at most a single row selected at
     * a time.
     */
    public var indexOfSelectedItem: Int = 0

    /**
     * This function selects the item at the given index. If `animated` is true,
     * it will run a transition animation.
     */
    public func selectItem(atIndex index: Int, animated: Bool) {
        self.indexOfSelectedItem = index

        self.collectionView.reloadData(animated: animated)
    }
}

// MARK: - Collection View Data Source

extension OnboardController : CollectionViewDataSource {
    /**
     * This function returns the number of steps (`items`) that were passed to
     * the initializer of this controller.
     */
    func numberOfCells(in collectionView: CollectionView) -> Int {
        return self.items.count
    }

    /**
     * This function dequeues a cell from the collection view and uses it to
     * display the appropriate step.
     */
    func collectionView(_ collectionView: CollectionView,
                        cellForItemAt indexPath: IndexPath)
                        -> CollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(identifier: "Item",
                                                       for: indexPath)
                         as? OnboardItemCell else {
            fatalError("Cell is an incorrect type.")
        }

        cell.item             = self.items[indexPath.item]
        cell.expanded         = indexPath.item == self.indexOfSelectedItem
        cell.completed        = indexPath.item <  self.indexOfSelectedItem
        cell.item?.controller = self

        return cell
    }

    /**
     * This function computes the appropriate size for the row or column at the
     * given index path.
     */
    func collectionView(_ collectionView: CollectionView,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        if self.direction == .horizontal {
            return NSSize(
                width:  collectionView.bounds.width / 3,
                height: collectionView.bounds.height
            )
        }

        if indexPath.item == self.indexOfSelectedItem {
            return NSSize(width: collectionView.bounds.width, height: 120)
        }

        return NSSize(width: collectionView.bounds.width, height: 52)
    }
}
