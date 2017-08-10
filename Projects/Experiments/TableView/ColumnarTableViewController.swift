//
//  ColumnarTableViewController.swift
//  Experiments
//
//  Created by Rich Henry on 07/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

private let data = [["Data1", "Data2", "Data3", "Data4"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4456", "Data5"],
                    ["Data1", "Data2456", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3456", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5456"],
                    ["Data1456", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "DataL", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
                    ["Data1", "Data2", "Data3", "Data4", "Data5"],
]

class ColumnarTableViewController: UITableViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)

        // Configure the cell...

        (cell as? ColumnCell)?.configure(withData: data[indexPath.row])

        return cell
    }
}

class BetMePositionTableViewController: UITableViewController {

    @IBOutlet var sectionHeader: UIView?

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        Bundle.main.loadNibNamed("SectionHeader", owner: self, options: nil)

        //headerTitleLabel.text = "Hello, World"
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

class ColumnCell : UITableViewCell {

    @IBOutlet var dataLabels: [UILabel]!

    func configure(withData data: [String]?) {

        let dataLength = data?.count ?? 0

        for (index, label) in dataLabels.enumerated() {

            label.text = index < dataLength ? data?[index] : "Unknown \(index)"
        }
    }
}
