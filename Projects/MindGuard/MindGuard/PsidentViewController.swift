//
//  PsidentViewController.swift
//  MindGuard
//
//  Created by Rich Henry on 11/09/2017.
//  Copyright © 2017 Dogstar Industries Ltd. All rights reserved.
//

import UIKit

@IBDesignable class InvaderView : UIView {

    override class var layerClass : AnyClass { return InvaderLayer.self }

    override func draw(_ rect: CGRect) {} // so that layer will draw itself
}

class InvaderLayer : CALayer {

    @NSManaged var thickness : CGFloat

    override class func needsDisplay(forKey key: String) -> Bool {

        if key == #keyPath(thickness) { return true }

        return super.needsDisplay(forKey:key)
    }

    override func draw(in con: CGContext) {

        let r = self.bounds.insetBy(dx:0, dy:0)

        con.setFillColor(UIColor.red.cgColor)
        con.fill(r)
        con.setStrokeColor(UIColor.blue.cgColor)
        con.setLineWidth(self.thickness)
        con.stroke(r)
    }

    override func action(forKey key: String) -> CAAction? {

        if key == #keyPath(thickness) {

            let ba = CABasicAnimation(keyPath: key)
            ba.fromValue = self.presentation()?.value(forKey:key)

            return ba
        }

        return super.action(forKey:key)
    }
}

class PsidentViewController: UIViewController {

    @IBOutlet var invaderView: InvaderView!

    // Actions

    @IBAction func borderSwitchValueChanged(_ sender: UISwitch) {

        (invaderView.layer as? InvaderLayer)?.thickness = sender.isOn ? 40 : 0
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (invaderView.layer as? InvaderLayer)?.thickness = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
