//
//  OctonScene.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SpriteKit

class OctonScene: SKScene {
    
    private var feedbackNode = SKSpriteNode()
    private lazy var feedbackRoot = { childNode(withName: "FeedbackRoot") }()
    private lazy var sceneRoot = { childNode(withName: "SceneRoot") }()

    override func didMove(to view: SKView) {
        
        let octonNode = SKSpriteNode(texture: UInt32.random(in: UInt32.min...UInt32.max).texture())
        sceneRoot?.addChild(octonNode)
        
        // Set up the view
        view.preferredFramesPerSecond = 120
        view.ignoresSiblingOrder = true
        
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        #endif

        // Set up feedback
        feedbackRoot?.addChild(feedbackNode)
        feedbackNode.color = .red
        feedbackNode.setScale(1.1)

        // Register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateActiveStatus(withNotification:)), name: UIApplication.didBecomeActiveNotification,  object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateActiveStatus(withNotification:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        rtt()
    }
    
    // MARK: RTT
    
    func rtt() {
        
        if let scene = scene, let texture = view?.texture(from: scene) {
            
            feedbackNode.run(.setTexture(texture, resize: true))
        }
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
