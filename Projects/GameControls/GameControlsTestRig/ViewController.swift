//
//  ViewController.swift
//  GameControlsTestRig
//
//  Created by Richard Henry on 21/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit
import SpriteKit
import GameControls

class ViewController: UIViewController {

    @IBOutlet var multiTouchView: TouchTestView!
    @IBOutlet var singleTouchView: TouchTestView!
    @IBOutlet var spriteView: SKView!
    
    private var moveSprite: SKSpriteNode!
    private var fireSprite: SKSpriteNode!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let joyFuncs: [TouchFunction] = [
            prepareMoveFunction(),
            prepareFireFunction(),
            prepareBlahFunction()
        ]

        singleTouchView.joyFunctions = joyFuncs
        multiTouchView.joyFunctions = joyFuncs
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "JoystickScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            moveSprite = scene.childNode(withName: "//moveSprite") as! SKSpriteNode
            fireSprite = scene.childNode(withName: "//fireSprite") as! SKSpriteNode

            // Present the scene
            spriteView.presentScene(scene)
        }
        
        spriteView.ignoresSiblingOrder = true
        
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
    }
    
    func prepareMoveFunction() -> TouchFunction {
        
        let windowFunction = WindowFunction(windowSize: CGSize(width: 20, height: 20))

        return { touch in
            
            windowFunction.handleTouch(touch: touch)
            
            self.moveSprite.position = windowFunction.vector
        }
    }
    
    func prepareFireFunction() -> TouchFunction {
        
        let windowFunction = WindowFunction(windowSize: CGSize(width: 10, height: 10))
        
        return { touch in
            
            windowFunction.handleTouch(touch: touch)
            
            self.fireSprite.position = windowFunction.vector
        }
    }
    
    func prepareBlahFunction() -> TouchFunction {
        
        return { touch in print("Blah (from func) \(touch.hash)") }
    }
}

public class WindowFunction {
    
    public var vector: CGPoint = CGPoint()
    
    private let size:  CGSize
    private var origin: CGPoint = CGPoint()
    
    init(windowSize size: CGSize) {
        
        self.size = size
    }
    
    func handleTouch(touch: UITouch) {
        
        let touchPoint = touch.location(in: touch.view)
        
        switch touch.phase {
        
        case .began:
            origin = touchPoint
            vector = CGPoint()
            
        case .moved:
            vector = CGPoint(x:  touchPoint.x - origin.x, y: -(touchPoint.y - origin.y))
            
            // Clip that vector
            if vector.x > size.width { origin.x += vector.x - size.width; vector.x = size.width }
            else if vector.x < -size.width { origin.x += vector.x + size.width; vector.x = -size.width }
            
            if vector.y > size.height { origin.y -= vector.y - size.height; vector.y = size.height }
            else if vector.y < -size.height { origin.y -= vector.y + size.height; vector.y = -size.height }
            
        case .ended, .cancelled:
            vector = CGPoint()
            
        default:break
        }
    }
}
