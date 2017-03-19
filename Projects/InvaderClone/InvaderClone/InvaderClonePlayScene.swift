//
//  InvaderClonePlayScene.swift
//  InvaderClone
//
//  Created by Richard Henry on 17/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import SpriteKit
import CoreMotion

class InvaderClonePlayScene : InvaderCloneScene {
    
    private var invaderMovementDirection: InvaderMovementDirection = .right
    private var timeOfLastMove: CFTimeInterval = 0.0
    private let timePerMove: CFTimeInterval = 1.0
    
    private let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    private let kInvaderRowCount = 6
    private let kInvaderColCount = 6
    
    private let kShipSize = CGSize(width: 30, height: 16)
    private let kShipName = "ship"
    
    private let kScoreHudName = "scoreHud"
    private let kHealthHudName = "healthHud"
    
    private let motionManager = CMMotionManager()
    
    // MARK: Invaders

    enum InvaderType {
        
        case a
        case b
        case c
        
        static var size: CGSize { return CGSize(width: 24, height: 16) }
        static var name: String { return "Invader" }
    }
    
    enum InvaderMovementDirection {
        
        case right
        case left
        case downThenRight
        case downThenLeft
        case none
    }
    
    // MARK: Setup

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
    
    func makeShip() -> SKNode {
        
        // Create the ship sprite
        let ship = SKSpriteNode(color: SKColor.orange, size: kShipSize)
        ship.name = kShipName
        
        // Create ship physics
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        ship.physicsBody!.isDynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        
        return ship
    }

    func setupInvaders() {

        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
        
        for row in 0..<kInvaderRowCount {

            // What sort of invader are we going to create?
            var invaderType: InvaderType
            
            if row % 3 == 0 {
                invaderType = .a
            } else if row % 3 == 1 {
                invaderType = .b
            } else {
                invaderType = .c
            }
            
            // Compute the invader's position
            let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
            
            for _ in 1..<kInvaderColCount {

                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition
                
                addChild(invader)
                
                invaderPosition = CGPoint( x: invaderPosition.x + InvaderType.size.width + kInvaderGridSpacing.width, y: invaderPositionY)
            }
        }
    }
    
    func setupShip() {
        
        let ship = makeShip()
        
        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        addChild(ship)
    }
    
    func setupHud() {
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        scoreLabel.fontColor = SKColor.green
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        healthLabel.fontColor = SKColor.red
        healthLabel.text = String(format: "Health: %.1f%%", 100.0)
        
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        addChild(healthLabel)
    }
    
    // MARK: Updates
    
    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        
        // TODO: Parent the invaders to some empty node and move that node rather than iterating all the invaders.
        if (currentTime - timeOfLastMove < timePerMove) { return }
        
        determineInvaderMovementDirection()
        
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }
            
            self.timeOfLastMove = currentTime
        }
    }
    
    func determineInvaderMovementDirection() {

        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            
            switch self.invaderMovementDirection {
            
            case .right:
                if (node.frame.maxX >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .downThenLeft
                    
                    stop.pointee = true
                }
            case .left:
                if (node.frame.minX <= 1.0) {
                    proposedMovementDirection = .downThenRight
                    
                    stop.pointee = true
                }
                
            case .downThenLeft:
                proposedMovementDirection = .left
                
                stop.pointee = true
                
            case .downThenRight:
                proposedMovementDirection = .right
                
                stop.pointee = true
                
            default:
                break
            }
            
        }
        
        if (proposedMovementDirection != invaderMovementDirection) { invaderMovementDirection = proposedMovementDirection }
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {

        if let ship = childNode(withName: kShipName) as? SKSpriteNode, let physics = ship.physicsBody {

            if let data = motionManager.accelerometerData {

                if fabs(data.acceleration.x) > 0.2 {

                    physics.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        processUserMotion(forUpdate: currentTime)
        
        moveInvaders(forUpdate: currentTime)
    }
    
    // MARK: Lifecycle
    
    override func didMove(to view: SKView) {
        
        self.sceneIdentifier = "Play"
        self.loadSceneBlock = { scene in
            
            // Temp
            // Check if this reports a Metal layer on a modern device.
            // SOLVED: Yes it does.
            print("Play scene loading sv \(scene?.view)")
        }
        
        super.didMove(to: view)
        
        // This physicsBody belongs to the scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        // Set up the invaders
        // NOTE: It's a bad idea to use this setup block I think.
        // The increase in flexibility is offset by having to watch out for retain cycles every time
        // self is referenced.
        // TODO: Think of some other initialisation method. We are now not protected by the loaded flag.
        self.setupInvaders()
        self.setupShip()
        self.setupHud()

        // Tap gesture recogniser
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InvaderClonePlayScene.handleTapGesture(_:))))
        
        // Motion manager
        motionManager.startAccelerometerUpdates()
    }
    
    // MARK: Gesture handling
    
    func handleTapGesture(_ sender: UIGestureRecognizer) {
        
        let nextScene = InvaderCloneAttractScene(size: self.size)
        
        self.view?.presentScene(nextScene, transition: SKTransition.doorsCloseVertical(withDuration: 0.23))
    }
}

