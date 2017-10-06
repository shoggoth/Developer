//
//  EventViewController.swift
//  BetMe
//
//  Created by Rich Henry on 30/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoLabel.text = "The Event"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
