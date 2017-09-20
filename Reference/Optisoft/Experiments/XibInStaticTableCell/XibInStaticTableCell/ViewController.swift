//
//  ViewController.swift
//  XibInStaticTableCell
//
//  Created by Richard Henry on 28/04/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

import UIKit

class InsertedViewController: UITableViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!

    @IBOutlet var insertViews: [UIView]!
    @IBOutlet var commonLabels: [UILabel]!

    override func viewDidLoad() {

        super.viewDidLoad()

        let array = UINib(nibName: "TableCells", bundle: nil).instantiateWithOwner(self, options: nil)

        println("arr = \(insertViews)")

        // Prepare the dictionary for visual constraint manipulation.
        let viewsDictionary: [String : AnyObject] = ["containerView" : containerView, "insertView_0" : insertViews[0], "insertView_1" : insertViews[1]]
        let metricsDictionary = ["space" : 8]

        // Add the views
        for view in insertViews {

            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            containerView.addSubview(view)
        }

        // Set constraints
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(space)-[insertView_0]-(space)-|", options: nil, metrics: metricsDictionary, views: viewsDictionary))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(space)-[insertView_1]-(space)-|", options: nil, metrics: metricsDictionary, views: viewsDictionary))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(space)-[insertView_0]-(space)-[insertView_1(==insertView_0)]-(space)-|", options: nil, metrics: metricsDictionary, views: viewsDictionary))

        // Set labels
        for label in commonLabels { label.text = "Common" }
        leftLabel.text = "Left"
        rightLabel.text = "Right"
    }
}
