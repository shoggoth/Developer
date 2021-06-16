//
//  Feedback.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SpriteKit

extension UInt32 {
    
    func texture() -> SKTexture {

        SKTexture(data: Data(stride(from: 0, to: 64, by: 1).flatMap { i in

            [
                UInt8(drand48() * 255),
                UInt8(drand48() * 255),
                UInt8(drand48() * 255),
                UInt8(255)
            ]
        }), size: CGSize(width: 8, height: 8))
    }
}
