//
//  ViewController.swift
//  InvaderClone
//
//  Created by Richard Henry on 17/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit
import SpriteKit

class InvaderCloneViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Configure the SpriteKit view.
        guard let spriteKitView = self.view as? SKView else { return };
        
        // Enable FPS display while debugging.
        #if DEBUG
            spriteKitView.showsFPS = true
            spriteKitView.showsNodeCount = true
        #endif
        
        // No overlapping sprites in this game so we can use a z-ordering optimisation.
        spriteKitView.ignoresSiblingOrder = true
        
        // Create and do initial drawing of the game scene.
        let scene = InvaderClonePlayScene(size: spriteKitView.frame.size)
        spriteKitView.presentScene(scene)
        
        // Notification handlers for pause toggling on app state changes.
        NotificationCenter.default.addObserver(self, selector: #selector(InvaderCloneViewController.handleApplicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InvaderCloneViewController.handleApplicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    // MARK: Window and device setup
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var shouldAutorotate: Bool { return true }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait, .portraitUpsideDown] }
    
    // MARK: Notification handling
    
    func handleApplicationWillResignActive(_ note: Notification) {
        
        (self.view as! SKView).isPaused = true
    }
    
    func handleApplicationDidBecomeActive(_ note: Notification) {
        
        (self.view as! SKView).isPaused = false
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        #if DEBUG
            print("Received memory warning")
        #endif
    }
}

