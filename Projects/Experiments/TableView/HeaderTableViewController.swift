//
//  HeaderTableViewController.swift
//  Experiments
//
//  Created by Rich Henry on 04/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class HeaderTableViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        Bundle.main.loadNibNamed("Header", owner: self, options: nil)

        headerTitleLabel.text = "class HeaderTableViewController"

        tableView.tableHeaderView = headerView
    }
}

class IBConstructedHeaderTableViewController: UITableViewController {

    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        headerTitleLabel.text = "class IBConstructedHeaderTableViewController"
    }
}

class StickyHeaderTableViewController: UIViewController {

    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        headerTitleLabel.text = "class StickyHeaderTableViewController"
    }
}

class SingleSectionHeaderTableViewController: UITableViewController {

    @IBOutlet var sectionHeader: UIView?
    @IBOutlet var headerTitleLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        Bundle.main.loadNibNamed("SectionHeader", owner: self, options: nil)

        headerTitleLabel.text = "class SingleSectionHeaderTableViewController"
    }

    // MARK: UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 50 }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        // Configure the cell
        cell.textLabel?.text = "Sec \(indexPath.section) Cell \(indexPath.row)"

        return cell
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return "Section \(section)"
    }

    // MARK: UICollectionViewDataSource

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return section == 0 ? sectionHeader?.frame.size.height ?? 88 : 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard section == 0 else { return nil }
        guard sectionHeader == nil else { return sectionHeader }

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 88))

        let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 18))

        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        label.text = "Section Header Missing"

        view.addSubview(label)
        view.backgroundColor = UIColor.gray

        return view
    }
}
