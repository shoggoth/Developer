//
//  OctonScene.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SpriteKit

class OctonScene: SKScene {
    
    private var lastUpdateTime = TimeInterval.zero

    override func didMove(to view: SKView) {
        
        // Set up the view
        view.preferredFramesPerSecond = 120
        view.ignoresSiblingOrder = true
        
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        #endif

        // Register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateActiveStatus(withNotification:)), name: UIApplication.didBecomeActiveNotification,  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateActiveStatus(withNotification:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        if lastUpdateTime == .zero { lastUpdateTime = currentTime }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        print(delta)
    }
    
    // MARK: Touch handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Touched lad")
    }

    // MARK: Notification
    
    @objc func updateActiveStatus(withNotification notification: NSNotification) {
        
        print("TODO: Handle these with pausing in the current scene = \(notification)")
    }
}
