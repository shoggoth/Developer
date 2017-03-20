//
//  TouchStickController.swift
//  GameControls
//
//  Created by Richard Henry on 20/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import Foundation

public class TouchStickController {
    
    public init (handlingTouchesFrom view: UIView) {
        
        #if DEBUG
            if let grArray = view.gestureRecognizers, grArray.count > 0 {
                
                print("TouchStickController warning: view \(view) already has \(grArray.count) gesture recognisers.")
                
                for (i, gr) in grArray.enumerated() { print("Recogniser \(i): \(gr)") }
            }
        #endif
    }
}
