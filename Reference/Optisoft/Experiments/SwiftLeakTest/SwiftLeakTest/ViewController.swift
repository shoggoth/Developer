//
//  ViewController.swift
//  SwiftLeakTest
//
//  Created by Richard Henry on 07/05/2015.
//  Copyright (c) 2015 Dogstar Industries. All rights reserved.
//

import UIKit

// MARK: Class

class SwiftLeakTestViewController: UIViewController {

    @IBOutlet weak var graceLabel: UILabel!

    var viewAppearCount = 0;
    let foo: String = "Foo"
    var bar: String?
    let baz: String? = "Baz"

    // MARK: Lifecycle
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.

        // This will not leak because all the parameters are non-optional.
        println("View loaded, printing non-optional \(foo)")
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Extension

extension SwiftLeakTestViewController {

    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)

        println("View appeared. Animated: \(animated) Count: \(++viewAppearCount)")
    }

    @IBAction func bakewallPressed(sender: AnyObject) {

        // This is going to leak as there is an optional parameter.
        println("Bakewall pressed, printing nil optional \(self.bar)")
    }

    @IBAction func yentlPressed(sender: AnyObject) {

        // This is going to leak as there is an optional parameter.
        println("Yentl pressed, printing non-nil optional \(self.baz)")
    }
}
