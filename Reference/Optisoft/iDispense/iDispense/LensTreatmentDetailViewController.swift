//
//  LensTreatmentDetailViewController.swift
//  iDispense
//
//  Created by Richard Henry on 28/01/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class LensTreatmentDetailViewController: UITableViewController {

    // MARK: Properties

    var order: LensOrder!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var priceField: UITextField!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        println("Set section header how?")
    }
}
