//
//  CollapsibleTableViewCell.swift
//  DiscloseInStaticTable
//
//  Created by Richard Henry on 13/05/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

import UIKit

class CollapsibleTableViewCell : UITableViewCell {

    @IBInspectable var sizes: CGPoint = CGPoint(x: 44, y: 44)
    @IBInspectable var initiallyCollapsed: Bool = true

    var isCollapsed: Bool { get { return collapsed }}
    
    fileprivate var heightConstraint: NSLayoutConstraint!
    fileprivate var collapsed: Bool = false

    // MARK: Lifecycle

    override func awakeFromNib() {

        collapsed = initiallyCollapsed

        // We want content in this cell to be clipped in case the collapse makes the containing view smaller
        // We are collapsing the height so mark resizing as flexible in that direction.
        self.clipsToBounds = true
        self.contentView.autoresizingMask = .flexibleHeight

        createConstraints()
    }

    // MARK: Actions

    func toggleCollapse(_ tableView: UITableView) { collapse(!collapsed, tableView: tableView) }

    func collapse(_ collapse: Bool, tableView: UITableView) {

        if collapsed != collapse {

            collapsed = collapse

            tableView.beginUpdates()

            heightConstraint.constant = currentHeight()
            self.setNeedsUpdateConstraints()

            tableView.endUpdates()
        }
    }

    func currentHeight() -> CGFloat { return collapsed ? sizes.x : sizes.y }

    // MARK: Setup

    fileprivate func createConstraints() {

        heightConstraint = NSLayoutConstraint(item: self.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: currentHeight())
        heightConstraint.priority = 999
        heightConstraint.isActive = true
    }
}
