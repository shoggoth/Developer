//
//  TouchTestView.swift
//  GameControls
//
//  Created by Richard Henry on 21/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

private extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        
        if let index = index(of: object) { remove(at: index) }
    }
}

private extension UITouch {
    
    var index: Int { return 1 }
}

typealias TouchFunction = (_ touch: UITouch) -> Void

class JoystickTouch : UITouch {
    
    var touchFunc: TouchFunction!
}

class TouchTestView: UIView {
    
    @IBInspectable public var viewName: String = "Unnamed"
    
    public var joyFunctions: [TouchFunction] {
        
        get { return joyFuncs }
        set { joyFuncs = newValue }
    }
    
    private var joyFuncs: [TouchFunction] = []
    private var joyTouches: [(touch: UITouch, func: TouchFunction)] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Began touch \(touches.count) - \(joyTouches.count) in view \(viewName) (multi \(isMultipleTouchEnabled))")
        
        for t in touches {
            
            if joyTouches.contains(where: { $0.touch == t }) { print("already there") } else { joyTouches.append(t) }
            //if joyTouches.contains(t) { print("already there") } else { joyTouches.append(t) }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Moved touch \(touches.count) in view \(viewName)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { joyTouches.remove(object: t) }
        
        print("Ended touch \(touches.count) in view \(viewName)")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Cancelled touch \(touches.count) in view \(viewName)")    }
}
