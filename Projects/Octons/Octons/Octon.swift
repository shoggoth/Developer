//
//  Feedback.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SpriteKit

struct Octon {
    
    let bits: UInt32
    
    func mirrorIndices(width: Int, height: Int) -> [Int] {
        
        let row = (0..<width).map { (x: Int) -> (Int) in
            
            let w = Float(width)
            let j = Float(x) / w * 2
            
            return abs(Int((w - 1.0) * floor(j)) - x)
        }

        return (0..<height).flatMap { (y: Int) -> ([Int]) in row.map { i in i + y * Int(ceil(Float(height) * 0.5)) }}
    }
}

// MARK: -

extension UInt32 {
    
    func texture(width: Int, height: Int) -> SKTexture {
        
        let indices = Octon(bits: self).mirrorIndices(width: width, height: height)
        
        let onPixel = [UInt8(255), UInt8(255), UInt8(255), UInt8(255)]
        let offPixel = [UInt8(0), UInt8(0), UInt8(0), UInt8(0)]

        let texture = SKTexture(data: Data((0..<(width * height)).flatMap { i in

            ((self >> indices[i]) & 1) != 0 ? onPixel : offPixel
        
        }), size: CGSize(width: width, height: height))
        
        texture.filteringMode = .nearest
        
        return texture
    }
}
