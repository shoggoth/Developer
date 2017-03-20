//
//  InvaderCloneAttractScreen.swift
//  InvaderClone
//
//  Created by Richard Henry on 17/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import SpriteKit

class InvaderCloneAttractScene : InvaderCloneScene {
    
    override func didMove(to view: SKView) {
        
        self.sceneIdentifier = "Attract"
        self.loadSceneBlock = { scene in
            
            // Temp
            print("Attract scene loading")
            
            scene?.backgroundColor = SKColor.green
        }
        
        super.didMove(to: view)
        
        // Tap gesture recogniser
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InvaderCloneAttractScene.handleTapGesture(_:))))
    }
    
    override func willMove(from view: SKView) {
        
        if let grList = view.gestureRecognizers {
            
            for gr in grList { view.removeGestureRecognizer(gr) }
        }
    }
    
    func handleTapGesture(_ sender: UIGestureRecognizer) {
        
        let nextScene = InvaderClonePlayScene(size: self.size)
        
        self.view?.presentScene(nextScene, transition: SKTransition.doorsOpenVertical(withDuration: 0.23))
    }
}
