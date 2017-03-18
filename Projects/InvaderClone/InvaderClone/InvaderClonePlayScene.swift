//
//  InvaderClonePlayScene.swift
//  InvaderClone
//
//  Created by Richard Henry on 17/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import SpriteKit

class InvaderClonePlayScene : InvaderCloneScene {
    
    enum InvaderType {
        
        case a
        case b
        case c
        
        static var size: CGSize { return CGSize(width: 24, height: 16) }
        static var name: String { return "Invader" }
    }
    
    func makeInvader(ofType type: InvaderType) -> SKNode {
        
        var invaderColour: SKColor
        
        switch (type) {
            
        case .a: invaderColour = SKColor.red
        case .b: invaderColour = SKColor.green
        case .c: invaderColour = SKColor.blue
        }
        
        let invader = SKSpriteNode(color: invaderColour, size: InvaderType.size)
        
        invader.name = InvaderType.name
        
        return invader
    }
    
    // MARK: Lifecycle
    
    override func didMove(to view: SKView) {
        
        self.sceneIdentifier = "Play"
        self.loadSceneBlock = { scene in
            
            // Temp
            // TODO: Check if this reports a Metal layer on a modern device.
            print("Play scene loading sv \(scene?.view)")
            
            scene?.backgroundColor = SKColor.red
        }
        
        super.didMove(to: view)
        
        // Tap gesture recogniser
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InvaderClonePlayScene.handleTapGesture(_:))))
    }
    
    // MARK: Gesture handling
    
    func handleTapGesture(_ sender: UIGestureRecognizer) {
        
        let nextScene = InvaderCloneAttractScene(size: self.size)
        
        self.view?.presentScene(nextScene, transition: SKTransition.doorsCloseVertical(withDuration: 0.23))
    }
}
