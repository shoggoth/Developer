//
//  RootScene.swift
//  JadeTime
//
//  Created by Richard Henry on 10/06/2021.
//

import SpriteKit

class RootScene: SKScene {
    
    private lazy var rttNode = { self.childNode(withName: "//RTT_Node") as! SKSpriteNode }()

    private var lastUpdateTime = TimeInterval.zero
    
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        if lastUpdateTime == .zero { lastUpdateTime = currentTime }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if let texture = self.view?.texture(from: scene!) { print(texture) }
        //renderTexture(to: rttNode)
    }
    
    // MARK: RTT
    
    func renderTexture(to node: SKSpriteNode) {
        
        if let texture = self.view?.texture(from: scene!) {
            
            //rttNode.texture = texture
            rttNode.run(.setTexture(texture, resize: true)) // https://www.hackingwithswift.com/example-code/games/how-to-change-a-sprites-texture-using-sktexture
        }
    }
}
