//
//  TouchTestView.swift
//  GameControls
//
//  Created by Richard Henry on 21/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

typealias TouchFunction = (_ touch: UITouch) -> Void

class TouchTestView: UIView {
    
    @IBInspectable public var viewName: String = "Unnamed"
    
    public var joyFunctions: [TouchFunction] = []
    
    private var joyTouches: [UITouch?] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Use the first slot in the array where we find a nil value. If there are no nil slots, append to the array
            // as long as there aren't more touches than there are functions to be called on that touch.
            if let i = joyTouches.index(where: { $0 == nil }) { joyTouches[i] = t } else { if joyTouches.count < joyFunctions.count { joyTouches.append(t) } }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Find the touch in the touch array and call the appropriate function (at the same index).
            if let i = joyTouches.index(where: { $0 == t }) { joyFunctions[i](t) }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            // Set the appropriate slot in the array to nil so that it can be re-used.
            if let i = joyTouches.index(where: { $0 == t }) { joyTouches[i] = nil }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Just do the same operation as if the touch had ended.
        touchesEnded(touches, with: event)
    }
}
