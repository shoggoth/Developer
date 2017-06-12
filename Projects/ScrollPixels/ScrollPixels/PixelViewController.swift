//
//  PixelViewController.swift
//  ScrollPixels
//
//  Created by Rich Henry on 19/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import SpriteKit

class PixelViewController: UIViewController {

    @IBOutlet weak var spriteKitView: SKView!

    override func viewDidLoad() {

        super.viewDidLoad()

        let pixelGridScene = PixelGridScene(size: view.frame.size)

        pixelGridScene.scaleMode = .aspectFill

        spriteKitView.ignoresSiblingOrder = true
        #if DEBUG
            spriteKitView.showsFPS = true
            spriteKitView.showsNodeCount = true
        #endif

        spriteKitView.backgroundColor = UIColor.red

        spriteKitView.presentScene(pixelGridScene)
    }

    override var shouldAutorotate: Bool { return true }

    override var prefersStatusBarHidden: Bool { return true }
}
