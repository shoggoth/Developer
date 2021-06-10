//
//  RootScene.swift
//  JadeTime
//
//  Created by Richard Henry on 10/06/2021.
//

import SpriteKit

class RootScene: SKScene {
    
    private var feedbackNode = SKSpriteNode()
    private lazy var jadeNode = { self.childNode(withName: "//JadeNode") as! SKSpriteNode }()
    private lazy var rttRoot = { self.childNode(withName: "//RTT_Root")! }()
    private lazy var hudRoot = { self.childNode(withName: "//HUD_Root")! }()

    private var lastUpdateTime = TimeInterval.zero
    
    required init?(coder aDecoder: NSCoder) {
        
        feedbackNode.size = UIScreen.main.bounds.size
        feedbackNode.color = .red
        feedbackNode.setScale(1.1)
        
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        
        rttRoot.addChild(feedbackNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        if lastUpdateTime == .zero { lastUpdateTime = currentTime }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        renderTexture(to: feedbackNode)
    }
    
    // MARK: RTT
    
    func renderTexture(to node: SKSpriteNode) {
        
        hudRoot.isHidden = true
        if let texture = self.view?.texture(from: scene!) {
            
            //rttNode.texture = texture
            feedbackNode.run(.setTexture(texture, resize: true)) // https://www.hackingwithswift.com/example-code/games/how-to-change-a-sprites-texture-using-sktexture
        }
        hudRoot.isHidden = false
    }
}
