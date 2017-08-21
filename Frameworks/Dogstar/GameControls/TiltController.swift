//
//  TiltController.swift
//  GameControls
//
//  Created by Richard Henry on 20/03/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import CoreMotion

public class TiltController {
    
    private static let motionManager = CMMotionManager()

    public init () {
        
        print("motionManager \(TiltController.motionManager)")
    }
}
