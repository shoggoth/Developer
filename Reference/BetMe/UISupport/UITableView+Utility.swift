//
//  UITableView+Utility.swift
//  BetMe
//
//  Created by Rich Henry on 02/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

public extension UITableView {

    func indexPath(forCellContentView view: UIView) -> IndexPath? {

        return self.indexPathForRow(at:view.convert(CGPoint(), to:self))
    }

    func cell(forCellContentView view: UIView) -> UITableViewCell? {

        guard let indexPath = indexPath(forCellContentView: view) else { return nil }

        return self.cellForRow(at: indexPath)
    }
}

