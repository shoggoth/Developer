//
//  GameScene.swift
//  Grid
//
//  Created by Rich Henry on 21/06/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import CoreGraphics
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var lastUpdateTimeInterval: CFTimeInterval = 0
    var gridTime: CGFloat = 0.0

    override func didMove(to view: SKView) {

        if let vortex = self.childNode(withName: "VortexNode") as? SKSpriteNode {

            vortex.size = self.frame.size.applying(CGAffineTransform(scaleX: 0.7, y: 0.7))

            //print("VN = \(String(describing: vortex.userData))")
            enumerateChildNodes(withName: "VortexNode") { node, stop in node.removeFromParent() }
        }

        if let starField = SKEmitterNode(fileNamed: "StarField") {

            //starField.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            starField.zPosition = -1

            addChild(starField)
        }
    }

    override func update(_ currentTime: TimeInterval) {

        if lastUpdateTimeInterval == 0 { lastUpdateTimeInterval = currentTime }
        
        let delta = currentTime - lastUpdateTimeInterval

        lastUpdateTimeInterval = currentTime

        gridTime += CGFloat(delta)

        if gridTime <= 1.0 { drawGrid(inRect: self.frame, fraction: gridTime) }
    }

    func drawGrid(inRect: CGRect, fraction: CGFloat) {

        let gridName = "Grid"

        enumerateChildNodes(withName: gridName) { node, stop in node.removeFromParent() }

        if fraction > 0 {
            
            var x1 = inRect.origin
            var x2 = CGPoint(x: x1.x, y: x1.y + inRect.size.height * gridTime)
            var y1 = inRect.origin
            var y2 = CGPoint(x: x1.x + inRect.size.width * gridTime, y: x1.y)

            let line = CGMutablePath()

            while y1.y <= inRect.origin.y + inRect.size.height {

                if x1.x <= inRect.origin.x + inRect.size.width {

                    line.move(to: x1)
                    line.addLine(to: x2)
                }

                line.move(to: y1)
                line.addLine(to: y2)

                x1.x += inRect.size.width * 0.05
                x2.x = x1.x
                y1.y += inRect.size.width * 0.05
                y2.y = y1.y
            }

            line.closeSubpath()

            let shape = SKShapeNode(path: line)
            
            shape.name = gridName
            
            shape.strokeColor = SKColor.blue
            shape.lineWidth = 3
            shape.zPosition = -0.9
            
            addChild(shape)
        }
    }
}
