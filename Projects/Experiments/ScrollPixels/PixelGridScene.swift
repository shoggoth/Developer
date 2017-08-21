//
//  PixelGridScene.swift
//  ScrollPixels
//
//  Created by Rich Henry on 19/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import SpriteKit

class PixelGridScene: SKScene {

    private var shapeNodes: [SKShapeNode] = []

    override func sceneDidLoad() {

        // Create shape nodes.
        let rowLength = 16

        let w = size.width / 16
        let h = size.height / 9
        let s = min(w, h) * 0.9

        for i in 0..<144 {

            let shapeNode = SKShapeNode.init(rectOf: CGSize(width: s, height: s))
            shapeNode.position = CGPoint(x: (CGFloat(i % rowLength) + 0.5) * w, y: (CGFloat(i / rowLength) + 0.5) * h)
            shapeNode.fillColor = SKColor.red
            shapeNode.lineWidth = 0

            shapeNodes.append(shapeNode)
            addChild(shapeNode)
        }
    }

    override func update(_ currentTime: TimeInterval) {

        for node in shapeNodes {

            node.fillColor = UIColor(white: CGFloat(arc4random() % 1000) * 0.001, alpha: 1)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {

        if let n = self.shapeNodes[0].copy() as? SKShapeNode {

            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
}

