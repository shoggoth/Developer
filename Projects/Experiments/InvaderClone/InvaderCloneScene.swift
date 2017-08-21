//
//  InvaderCloneScene.swift
//  InvaderClone
//
//  Created by Richard Henry on 18/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import SpriteKit

class InvaderCloneScene : SKScene {
    
    internal var sceneIdentifier = "Unnamed"
    internal var loadSceneBlock: ((_ scene: SKScene?) -> Void)?
    
    private var loaded = false
    
    override func didMove(to view: SKView) {
        
        // Load the scene content
        if !loaded {
            
            loadSceneBlock?(self.scene)
            loaded = true
        }
    }
    
    deinit {
        
        print("\(sceneIdentifier) scene deinited")
    }
}
