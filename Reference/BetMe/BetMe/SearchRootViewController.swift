//
//  SearchGroupViewController.swift
//  BetMe
//
//  Created by Rich Henry on 25/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import UISupport

struct SearchGroupEntry {

    let type: SearchGroupItemType
    let data: [String : Any]

    var title: String? { get { return formattedNameString(dataDictionary: data, mapping: ["%D" : "start_date", "%E" : "name", "%M" : "event_name"]) ?? data["name"] as? String }}
}

enum SearchGroupItemType {

    case searchGroup(id: String, name: String)
    case event
    case market

    var cellIdentifier: String {

        switch self {

        case .searchGroup:
            return "GroupPathCell"

        case .event:
            return "EventCell"

        case .market:
            return "MarketCell"
        }
    }
}

class SearchGroupViewController: UITableViewController, UISearchResultsUpdating {

    @IBOutlet var emptyTableView: UIView!

    private var rootSearchGroup: SearchGroupEntry? = nil
    private var groupEntries = [SearchGroupEntry]()
    private var filteredGroupEntries = [SearchGroupEntry]()

    private let searchController = UISearchController(searchResultsController: nil)
    private let serverSession = BetMeServerSession.sharedInstance

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        navigationItem.title = rootSearchGroup?.title ?? "Library"

        // By initializing UISearchController without a searchResultsController, you are telling the search controller
        // that you want use the same view that you’re searching to display the results.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        // By setting definesPresentationContext on your view controller to true, you ensure that the search bar does not
        // remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true

        tableView.tableHeaderView = searchController.searchBar

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresherValueChanged(sender:)), for: .valueChanged)
        refreshControl = refresher

        fetch()
    }

    // MARK: UISearchResultsUpdating

    func filterContent(forsearchText searchText: String, scope: String = "All") {

        filteredGroupEntries = groupEntries.filter { groupEntry in

            groupEntry.title?.lowercased().contains(searchText.lowercased()) ?? false
        }

        tableView.reloadData()
    }

    func updateSearchResults(for searchController: UISearchController) {

        filterContent(forsearchText: searchController.searchBar.text!)
    }

    // MARK: Fetch

    func fetch(withCompletion completion: (() -> Void)? =  nil) {

        // Contact the server to get the children of this group path.
        serverSession.getGroupPathChildren(forGroupPathID: rootSearchGroup?.data["id"] as? String ?? "0") { result in

            if let children = result["children"]  as? [[String : Any]] {

                for child in children {

                    switch child["type"] {

                    case "group_path" as String:

                        if let groupID = child["id"] as? String, let groupName = child["name"] as? String {

                            self.groupEntries.append(SearchGroupEntry(type: .searchGroup(id: groupID, name: groupName), data: child))
                        }

                    case "event" as String:

                        self.groupEntries.append(SearchGroupEntry(type: .event, data: child))

                    case "market" as String:

                        self.groupEntries.append(SearchGroupEntry(type: .market, data: child))

                    default:
                        
                        print("Unknown type \(String(describing: child["type"]))")
                    }
                }
                
                self.reloadData()

                completion?()
            }
        }
    }

    // MARK: Refresh

    @objc private func refresherValueChanged(sender: UIRefreshControl) {

        groupEntries.removeAll()

        fetch { sender.endRefreshing() }
    }

    func reloadData() {

        tableView.reloadData()

        if groupEntries.count == 0 {

            tableView.backgroundView = emptyTableView
            tableView.separatorStyle = .none

        } else {

            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    // MARK: Table View DataSource

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" { return filteredGroupEntries.count }

        return groupEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let entry = searchController.isActive && searchController.searchBar.text != "" ? filteredGroupEntries[indexPath.row] : groupEntries[indexPath.row]
        let identifier = entry.type.cellIdentifier

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        cell.textLabel?.text = entry.title ?? "????"

        return cell
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? UITableViewCell {
            
            if let row = tableView.indexPath(for: cell)?.row {

                let entry = searchController.isActive && searchController.searchBar.text != "" ? filteredGroupEntries[row] : groupEntries[row]

                // If the segue refers to this class, fill in the root group path.
                (segue.destination as? SearchGroupViewController)?.rootSearchGroup = entry

                // If the segue refers to a market, do something (what?).
                (segue.destination as? MarketViewController)?.rootSearchGroup = entry

                // If the segue's destination view controller needs a market passing to it, do that.
                (segue.destination as? MarketInjectable)?.market = Market(data: entry.data)
            }
        }
    }
}
