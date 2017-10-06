//
//  IDAboutViewController.swift
//  iDispense
//
//  Created by Richard Henry on 08/03/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import UIKit

class IDAboutViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {

        super.viewDidLoad()

        // Load the local web content.
        if let htmlFile = Bundle.main.path(forResource: "about", ofType: "html") {

            do {
                let htmlString = try String(contentsOfFile: htmlFile, encoding: String.Encoding.utf8)

                webView.loadHTMLString(htmlString, baseURL: nil);
            }
            catch _ {}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
