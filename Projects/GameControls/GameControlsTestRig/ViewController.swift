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

            // Present the scene
            spriteView.presentScene(scene)
        }
        
        spriteView.ignoresSiblingOrder = true
        
        spriteView.showsFPS = true
        spriteView.showsNodeCount = true
    }
    
    func prepareMoveFunction() -> TouchFunction {
        
        let windowFunction = WindowFunction(windowSize: CGSize(width: 44, height: 44))

        return { touch in
            
            windowFunction.handleTouch(touch: touch)
            
            self.moveSprite.position = windowFunction.vector
        }
    }
    
    func prepareFireFunction() -> TouchFunction {
        
        return { touch in print("Fire (from func) \(touch.hash)") }
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
            
            print("Move began at (\(touchPoint))")
            
        case .moved:
            vector = CGPoint(x:  touchPoint.x - origin.x, y: -(touchPoint.y - origin.y))
            
            print("Move moved at (\(vector)) \(hypotf(Float(vector.x), Float(vector.y)))")
            
        case .ended, .cancelled:
            vector = CGPoint()
            print("Move ended at (\(touchPoint))")
            
        default:break
        }
    }
}
