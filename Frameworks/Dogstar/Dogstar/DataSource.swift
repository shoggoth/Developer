//
//  DataSource.swift
//  Experiments
//
//  Created by Rich Henry on 20/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

public class DataSource : NSObject, UITableViewDataSource, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegate {

    @IBInspectable var sectionCount: Int = 0
    @IBInspectable var contentCount: Int = 0

    @IBInspectable var cellIdentifier: String = "DefaultCell"
    @IBInspectable var imageName: String = ""
    @IBInspectable var canHighlight: Bool = false
    @IBInspectable var canSelect: Bool = false

    @IBInspectable var headerIdentifier: String = "DefaultHeader"
    @IBInspectable var footerIdentifier: String = "DefaultFooter"

    private typealias DataType = (string: String, type: String, value: Int, hi: Bool, sel: Bool)

    private var data: [[DataType]] = []
    private var image: UIImage?

    // MARK: Lifecycle

    override public func awakeFromNib() {

        if !imageName.isEmpty { image = UIImage(named: imageName) }

        for section in 0..<sectionCount { data.append(sectionContent(section)) }
    }

    // MARK: Content generation

    private func sectionContent(_ sectionIndex: Int) -> [DataType] {

        var content = [DataType]()

        let cellIDs = cellIdentifier.components(separatedBy: ",")

        for cellIndex in 0..<contentCount {

            let cellID = cellIDs[cellIndex % cellIDs.count]

            content.append(DataType(string: "Sec \(sectionIndex) Cell \(cellIndex)", type: cellID, value: 0, hi: canHighlight, sel: canSelect))
        }

        return content
    }

    // MARK: Functionality

    public func createNewItem(in collectionView: UICollectionView) {

        let sectionIndex = 0
        let cellIndex = data[sectionIndex].count

        data[0].append(DataType(string: "Add \(sectionIndex) Cell \(cellIndex)", type: cellIdentifier, value: 0, hi: canHighlight, sel: canSelect))

        collectionView.insertItems(at: [IndexPath(item: cellIndex, section: sectionIndex)])
    }

    public func deleteSelectedItems(from collectionView: UICollectionView, completion: ((Bool) -> Void)? = nil) {

        collectionView.performBatchUpdates({

            if let itemPaths = collectionView.indexPathsForSelectedItems {

                // Delete the items from the data array.
                // Sort them first so that we don't get an array out of range error.
                for path in itemPaths.sorted(by: { $0.section == $1.section ? $0.item > $1.item : $0.section > $1.section }) {

                    self.data[path.section].remove(at: path.row)
                }

                // Delete the items from the collection view.
                collectionView.deleteItems(at: itemPaths)
            }
            
        }, completion: completion)
    }

    // MARK: UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int { return data.count }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data[section].count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: data[indexPath.section][indexPath.row].type, for: indexPath)

        // Configure the cell
        cell.textLabel?.text = data[indexPath.section][indexPath.row].string
        cell.detailTextLabel?.text = data[indexPath.section][indexPath.row].string + " detail"
        cell.imageView?.image = image

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return data.count > 1 ? "Section \(section)" : nil
    }

    // MARK: UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int { return data.count }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return data[section].count }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data[indexPath.section][indexPath.row].type, for: indexPath)

        // Configure the cell
        (cell as? StringCollectionViewCell)?.configure(data[indexPath.section][indexPath.row].string)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let reuseIdentifier = kind == UICollectionElementKindSectionHeader ? headerIdentifier : footerIdentifier

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)

        return view
    }

    // MARK: UICollectionViewDelegate

    // Specify if the specified item should be highlighted during tracking
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return data[indexPath.section][indexPath.row].hi }

    // Do the highlighting
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        UIView.animateKeyframes(withDuration: 0.23, delay: 0, options: .allowUserInteraction, animations: {

            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor.blue

        }, completion: nil)
    }

    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {

        UIView.animateKeyframes(withDuration: 0.23, delay: 0, options: .allowUserInteraction, animations: {

            collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = nil

        }, completion: nil)
    }

    // Specify if the specified item should be selected
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return data[indexPath.section][indexPath.row].sel }
}

// MARK: - Width Fitting data source

public class WidthFitDataSource : DataSource, UICollectionViewDelegateFlowLayout {

    @IBInspectable var cellHeight: CGFloat = 44

    // MARK: Sizing

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sz = collectionView.frame.size

        return CGSize(width: sz.width, height: cellHeight)
    }
}

// MARK: - View

open class StringCollectionViewCell : UICollectionViewCell {

    @IBOutlet private var label: UILabel!

    open func configure(_ content: String) {

        label.text = content

        // Accessibility
        label.accessibilityLabel = "Title"
        label.accessibilityValue = content

        // Appearance
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }
}
