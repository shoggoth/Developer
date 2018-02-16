//
//  CALayerMessingViewController.swift
//  CALayerMessing
//
//  Created by Richard Henry on 06/12/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class CALayerMessingViewController : UIViewController {

    @IBOutlet weak var layerView: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("Layer View Bounds = \(layerView.bounds)")
        print("Layer View Frame  = \(layerView.frame)")
        
        // Background Layer
        let bgLayer = CALayer()
        bgLayer.frame = layerView.bounds.insetBy(dx: 3, dy: 3)
        bgLayer.backgroundColor = UIColor.black.cgColor
        
        layerView.layer.addSublayer(bgLayer)
        
        // Shape Layer
        let outlinePath = UIBezierPath()
        outlinePath.move(to: CGPoint(x: 10, y: 10))
        outlinePath.addLine(to: CGPoint(x: 100, y: 10))
        outlinePath.addLine(to: CGPoint(x: 100, y: 100))
        outlinePath.addLine(to: CGPoint(x: 10, y: 100))
        outlinePath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = bgLayer.frame.insetBy(dx: 3, dy: 3)
        shapeLayer.backgroundColor = UIColor.red.cgColor
        shapeLayer.path = outlinePath.cgPath
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 3
        
        layerView.layer.addSublayer(shapeLayer)
    }
}

