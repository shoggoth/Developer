//
//  ViewController.swift
//  GameControlsTestRig
//
//  Created by Richard Henry on 21/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit
import GameControls

class ViewController: UIViewController {

    @IBOutlet var multiTouchView: TouchTestView!
    @IBOutlet var singleTouchView: TouchTestView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let joyFuncs: [TouchFunction] = [
            { touch in print("Move \(touch.hash)") },
            { touch in print("Fire \(touch.hash)") },
            { touch in print("Smar \(touch.hash)") }
        ]

        singleTouchView.joyFunctions = joyFuncs
        multiTouchView.joyFunctions = joyFuncs
    }
}

