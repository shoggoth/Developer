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

class ViewController : UIViewController {

    @IBOutlet var multiTouchView: TouchControllerView!
    @IBOutlet var singleTouchView: TouchControllerView!
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
        
        let windowFunction = WindowFunction(windowSize: CGSize(width: 20, height: 20), deadZoneR2: 10)

        return { touch in
            
            windowFunction.handleTouch(touch: touch)
            
            self.moveSprite.position = windowFunction.windowVector
        }
    }
    
    func prepareFireFunction() -> TouchFunction {
        
        let windowFunction = WindowFunction(windowSize: CGSize(width: 10, height: 10))
        
        return { touch in
            
            windowFunction.handleTouch(touch: touch)
            
            self.fireSprite.position = windowFunction.windowVector
        }
    }
    
    func prepareBlahFunction() -> TouchFunction {
        
        return { touch in print("Blah (from func) \(touch.hash)") }
    }
}

