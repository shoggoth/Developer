//
//  TableRootViewController.swift
//  TableView
//
//  Created by Rich Henry on 03/08/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class TableRootViewController: UIViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()
    }


    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToRoot(sender: UIStoryboardSegue) {

        print("And relax \(sender.source)")
    }
}

