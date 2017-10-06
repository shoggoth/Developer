//
//  DataSource.swift
//  BetMe
//
//  Created by Rich Henry on 22/08/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

class SubscriptionDataSource : NSObject, UITableViewDataSource, UICollectionViewDataSource, UITableViewDelegate, UICollectionViewDelegate {

    public var tableCellConfigBlock: ((UITableViewCell, SubsData) -> Void)? = nil

    public var sectionHeaderViews: [UIView]?

    @IBInspectable var tableViewCellIdentifier: String = "DefaultCell"
    @IBInspectable var collectionViewCellIdentifier: String = "DefaultCell"

    @IBInspectable var canHighlight: Bool = false
    @IBInspectable var canSelect: Bool = false

    @IBInspectable var collectionViewHeaderIdentifier: String = "DefaultHeader"
    @IBInspectable var collectionViewFooterIdentifier: String = "DefaultFooter"

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var collectionView: UICollectionView?

    typealias SubsData = [String : Any]
    var data: [[SubsData]] = []

    private let session = BetMeServerSession.sharedInstance

    // MARK: Lifecycle

    override public func awakeFromNib() {

        super.awakeFromNib()
    }

    // MARK: Un/Subscribe To Changes

    public func subscribe(withNotificationKey noteKey: String) {

        if let accountID = AccountManager.sharedInstance.defaultAccount?.accountID {

            // Subscribe to change notifications
            session.subscribe(toPositionsInAccount: accountID) { result in

                self.data = [result]

                // Subscribe to changes in the target.
                self.session.connection.addObserver(forNotificationNamed: noteKey, object: self, sel: #selector(self.subscriptionChangeNotification))

                // Reload data from the connected views.
                self.collectionView?.reloadData()
                self.tableView?.reloadData()
            }
        }
    }

    public func unsubscribe(withNotificationKey noteKey: String) {

        if let accountID = AccountManager.sharedInstance.defaultAccount?.accountID {

            // Unsubscribe from notifications
            session.unsubscribe(fromPositionsInAccount: accountID) { replyObject in
                
                self.session.connection.removeObserver(forNotificationNamed: noteKey, object: self)
            }
        }
    }

    func dictionaryOfMarketEntries(fromDelta delta: SubsData) -> [String : SubsData] {

        var marketEntriesDict: [String : SubsData] = [:]

        for marketEntry in delta["market_entries"] as? [SubsData] ?? [] {

            if let id = marketEntry["market_entry_id"] as? String { marketEntriesDict[id] = marketEntry }
        }

        return marketEntriesDict
    }

    let dictMerge: (_: [SubsData], _: [String : SubsData], _: String) -> [SubsData] = { data, delta, key in

        var newArray: [SubsData] = []

        for d in data {

            if let id = d[key] as? String, let matchingDelta = delta[id] {

                var newData = d

                for (key, value) in matchingDelta { newData[key] = value }

                newArray.append(newData)
            }
        }
        
        return newArray
    }

    // MARK: Notification

    func subscriptionChangeNotification(note: Notification) {

        print("Doing nothing with notification. Result: \(String(describing: note.userInfo?["result"]))")
    }

    // MARK: Mutation of Data

    public func createNewItem(in collectionView: UICollectionView) {

        let sectionIndex = 0
        let cellIndex = data[sectionIndex].count

        //data[0].append(DataType(title: "Add \(sectionIndex) Cell \(cellIndex)", type: tableViewCellIdentifier, value: 0, hi: canHighlight, sel: canSelect))

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

        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)

        // Configure the cell

        tableCellConfigBlock?(cell, data[indexPath.section][indexPath.row])

        cell.textLabel?.text = data[indexPath.section][indexPath.row]["id"] as? String
        cell.detailTextLabel?.text = "Detail"

        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return data.count > 1 ? "Section \(section)" : nil
    }

    // MARK: UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int { return data.count }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return data[section].count }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath)

        // Configure the cell
        // (cell as? StringCollectionViewCell)?.configure(data[indexPath.section][indexPath.row].title)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let reuseIdentifier = kind == UICollectionElementKindSectionHeader ? collectionViewHeaderIdentifier : collectionViewFooterIdentifier

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)

        return view
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return sectionHeaderViews?[section].frame.size.height ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return sectionHeaderViews?[section]
    }

    // MARK: UICollectionViewDelegate

    // Specify if the specified item should be highlighted during tracking
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return canHighlight }

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
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return canSelect }
}
