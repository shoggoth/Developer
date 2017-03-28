//
//  TouchStickController.swift
//  GameControls
//
//  Created by Richard Henry on 20/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

public typealias TouchFunction = (_ touch: UITouch) -> Void

public class TouchStickView: UIView {
    
    @IBInspectable public var viewName: String = "Unnamed"
    
    public var joyFunctions: [TouchFunction] = []
    
    private var joyTouches: [UITouch?] = []
    
    required public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        #if DEBUG
            if let grArray = self.gestureRecognizers, grArray.count > 0 {
                
                print("TouchStickController warning: view \(self) already has \(grArray.count) gesture recognisers.")
                
                for (i, gr) in grArray.enumerated() { print("Recogniser \(i): \(gr)") }
            }
        #endif
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        #if DEBUG
            if let grArray = self.gestureRecognizers, grArray.count > 0 {
                
                print("TouchStickController warning: view \(self) already has \(grArray.count) gesture recognisers.")
                
                for (i, gr) in grArray.enumerated() { print("Recogniser \(i): \(gr)") }
            }
        #endif
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Use the first slot in the array where we find a nil value. If there are no nil slots, append to the array
            // as long as there aren't more touches than there are functions to be called on that touch.
            if let i = joyTouches.index(where: { $0 == nil }) {
                
                joyTouches[i] = t
                joyFunctions[i](t)
                
            } else {
                
                if joyTouches.count < joyFunctions.count {
                    
                    joyFunctions[joyTouches.count](t)
                    joyTouches.append(t)
                }
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Find the touch in the touch array and call the appropriate function (at the same index).
            if let i = joyTouches.index(where: { $0 == t }) { joyFunctions[i](t) }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Set the appropriate slot in the array to nil so that it can be re-used.
            if let i = joyTouches.index(where: { $0 == t }) {
                
                joyFunctions[i](t)
                joyTouches[i] = nil
            }
        }
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Just do the same operation as if the touch had ended.
        touchesEnded(touches, with: event)
    }
}

public class WindowFunction {
    
    public var windowVector: CGPoint = CGPoint()
    public var deadZoneRadiusSquared: CGFloat = 0.0
    
    private let size:  CGSize
    private var origin: CGPoint = CGPoint()
    
    public init(windowSize size: CGSize, deadZoneR2 dzr2: CGFloat = 0.0) {
        
        self.size = size
        self.deadZoneRadiusSquared = dzr2 * dzr2
    }
    
    deinit {
        
        print("DeInited")
    }
    
    public func handleTouch(touch: UITouch) {
        
        let touchPoint = touch.location(in: touch.view)
        
        switch touch.phase {
            
        case .began:
            origin = touchPoint
            windowVector = CGPoint()
            
        case .moved:
            var vector = CGPoint(x:  touchPoint.x - origin.x, y: -(touchPoint.y - origin.y))
            
            // Clip that vector
            if vector.x > size.width { origin.x += vector.x - size.width; vector.x = size.width }
            else if vector.x < -size.width { origin.x += vector.x + size.width; vector.x = -size.width }
            
            if vector.y > size.height { origin.y -= vector.y - size.height; vector.y = size.height }
            else if vector.y < -size.height { origin.y -= vector.y + size.height; vector.y = -size.height }
            
            let vectorLengthSquared = vector.x * vector.x + vector.y * vector.y
            
            windowVector = vectorLengthSquared > deadZoneRadiusSquared ? vector : CGPoint()
            
        case .ended, .cancelled:
            windowVector = CGPoint()
            
        default:break
        }
    }
}
