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
 * This class reimplements parts of the UICollectionView that are not available
 * on Mac.
 */
internal class CollectionView : NSView {
    private var numberOfCells: Int = 0

    /**
     * This holds all items that are currently *visible* in the collection view.
     * Note that this may not include cells for all items in the data source.
     */
    private var cells: [CollectionViewCell] = []

    /**
     * The collection view loads data from its data source. Changing the data
     * source automatically calls reloadData().
     */
    public var dataSource: CollectionViewDataSource? {
        didSet {
            self.reloadData()
        }
    }

    /**
     * This will hold all cells that are visible.
     */
    internal let cellsView = FlippedView()

    public var footerView: NSView? = nil {
        didSet {
            oldValue?.removeFromSuperview()

            guard let view         = self.footerView else { return }
            view.frame.size.width  = self.bounds.size.width
            view.frame.origin.y    = self.cells.last?.frame.maxY ?? 0
            view.frame.size.height = self.bounds.size.height -
                                     view.frame.origin.y
            self.addSubview(view)
        }
    }

    override var isFlipped: Bool {
        return true
    }

    // MARK: - Cell Registration and Dequeueing

    /**
     * This dictionary holds all cell classes that have been registered.
     */
    var cellClasses: [String : AnyClass] = [:]

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.wantsLayer = true

        self.addSubview(self.cellsView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        self.reloadData()
    }

    /**
     * Call this function in `loadView()` to register any cell classes you need
     * for this collection view.
     */
    public func register(class: CollectionViewCell.Type,
                         for reuseIdentifier: String) {
        assert(!self.cellClasses.contains { $0.key == reuseIdentifier },
               "Reuse identifier \(reuseIdentifier) has already been " +
               "registered with class: \(`class`).")

        self.cellClasses[reuseIdentifier] = `class`
    }

    /**
     * Call this function from `cellForItemAt()` to dequeue a cell of the class
     * that corresponds to the given reuse identifier.
     */
    public func dequeueReusableCell(identifier: String,
                                    for indexPath: IndexPath)
                                    -> CollectionViewCell {
        // First, we look if a cell with the given identifier *and* indexPath
        // already exists and is visible.
        for cell in self.cells {
            if cell.identifier == identifier && cell.indexPath == indexPath {
                return cell
            }
        }

        // If not, we need to instantiate a new cell.
        guard let `class` = self.cellClasses[identifier] as?
                            CollectionViewCell.Type else {
            fatalError("Collection view cell does not subclass the correct " +
                       "type.")
        }

        let cell        = `class`.init()
        cell.identifier = identifier
        cell.indexPath  = indexPath
        self.cells.append(cell)

        return cell
    }

    // MARK: - Reloading the Collection View

    /**
     * This function reloads the data that is shown in this collection view.
     */
    func reloadData() {
        guard let dataSource = self.dataSource else {
            // TODO: clear collection view.

            return
        }

        self.numberOfCells = dataSource.numberOfCells(in: self)

        // We start by removing the old cells from the view. Note that we do
        // keep them in memory for a while.
        self.cells.forEach { $0.removeFromSuperview() }

        // Now, we reposition each of the cells.
        var offset = NSPoint.zero
        var size   = NSSize.zero

        for index in 0 ..< self.numberOfCells {
            let path = IndexPath(item: index, section: 0)

            // Retrieve a cell for this path from the data source and make sure
            // that is from the reusable cache.
            let cell = dataSource.collectionView(self, cellForItemAt: path)
            assert(self.cells.contains(cell), "Cell must be retrieved from " +
                   "`dequeueReusableCell()`.")

            let cellSize = dataSource.collectionView(self, sizeForItemAt: path)

            cell.frame.origin.x = offset.x
            cell.frame.origin.y = offset.y
            cell.frame.size     = cellSize
            self.cellsView.addSubview(cell)

            // Update current offset and size.
            if cellSize.height == self.bounds.height {
                offset.x    += cellSize.width
                size.width  += cellSize.width
                size.height  = max(size.height, cellSize.height)
            } else {
                offset.y    += cellSize.height
                size.width   = max(size.width, cellSize.width)
                size.height += cellSize.height
            }
        }

        // Update the bounds of the cells view.
        self.cellsView.frame.size.width  = size.width
        self.cellsView.frame.size.height = size.height

        guard let view         = self.footerView else { return }
        view.frame.size.width  = self.bounds.size.width
        view.frame.origin.y    = self.cells.last?.frame.maxY ?? 0
        view.frame.size.height = self.bounds.size.height - view.frame.origin.y
        self.addSubview(view)
    }

    /**
     * This function reloads the data in this collection view with a short
     * transition animation.
     */
    func reloadData(animated: Bool) {
        if !animated {
            return self.reloadData()
        }

        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration                = 0.4
            context.allowsImplicitAnimation = true
            context.timingFunction          = .spring()

            self.reloadData()
        }, completionHandler: nil)
    }
}
