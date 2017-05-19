//
//  PixelGridScene.swift
//  ScrollPixels
//
//  Created by Rich Henry on 19/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import SpriteKit

class PixelGridScene: SKScene {

    private var pixelNode: SKShapeNode?

    override func didMove(to view: SKView) {

        addChild(pixelNode!)
        addChild(pixelNode?.copy() as! SKNode)
    }

    override func sceneDidLoad() {

        // Create shape node.
        pixelNode = SKShapeNode.init(rectOf: CGSize(width: 16, height: 16))
        pixelNode?.position = CGPoint(x: 100, y: 100)
        pixelNode?.fillColor = SKColor.red
    }

    func touchDown(atPoint pos : CGPoint) {

        if let n = self.pixelNode?.copy() as! SKShapeNode? {
            n.position = pos
            //n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
}

