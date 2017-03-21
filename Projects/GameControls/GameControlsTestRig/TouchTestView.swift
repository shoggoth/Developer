//
//  TouchTestView.swift
//  GameControls
//
//  Created by Richard Henry on 21/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

typealias TouchFunction = (_ touch: UITouch) -> Int

class TouchTestView: UIView {
    
    @IBInspectable public var viewName: String = "Unnamed"
    
    public var joyFunctions: [TouchFunction] {
        
        get { return joyFuncs }
        set { joyFuncs = newValue }
    }
    
    private var joyFuncs: [TouchFunction] = []
    private var joyTouches: [UITouch : TouchFunction] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        joyFuncs = [{ touch in print("Move \(touch.hash) \(self.viewName)"); return 0 }, { touch in print("Fire \(touch.hash)"); return 1 }, { touch in print("Smartie \(touch.hash)"); return 1 }]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if joyFuncs.count > 0 {
            
            for t in touches { if !joyFuncs.isEmpty { joyTouches[t] = joyFuncs.removeFirst() }}
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { if let touchFunc = joyTouches[t] { _ = touchFunc(t) } }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            
            if let touchFunc = joyTouches[t] { joyFuncs.insert(touchFunc, at: min(touchFunc(t), joyFuncs.count)) }
            
            joyTouches.removeValue(forKey: t)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touchesEnded(touches, with: event)
    }
}
