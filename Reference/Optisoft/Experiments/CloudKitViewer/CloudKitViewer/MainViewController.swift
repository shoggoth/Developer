//
//  MainViewController.swift
//  CloudKitViewer
//
//  Created by Richard Henry on 27/10/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

class CloudKitViewerMainViewController: UIViewController {

    @IBOutlet weak var uuidLabel: UILabel!

    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        uuidLabel.text = "udid = \(UIDevice.currentDevice().identifierForVendor!.UUIDString)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

