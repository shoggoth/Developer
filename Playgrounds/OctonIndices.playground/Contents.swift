import Cocoa

func generateIndices(width: Int, height: Int) -> [Int] {
    
    let row = (0..<width).map { (x: Int) -> (Int) in
        
        let w = Float(width)
        let j = Float(x) / w * 2
        
        return abs(Int((w - 1.0) * floor(j)) - x)
    }

    return (0..<height).flatMap { (y: Int) -> ([Int]) in
        
        let h = Float(height) * 0.5
        return row.map { i in i + y * Int(ceil(h)) }
    }
}

let i1 = generateIndices(width: 5, height: 5)
let i2 = generateIndices(width: 6, height: 5)

let height = 5
let width = 6

let row = (0..<width).map { (x: Int) -> (Int) in
    
    let w = Float(width)
    let j = Float(x) / w * 2
    
    return abs(Int((w - 1.0) * floor(j)) - x)
}

(0..<height).map { (y: Int) -> ([Int]) in
    
    let h = Float(height) * 0.5
    return row.map { i in i + y * Int(ceil(h)) }
}

(0..<width).map { (i: Int) -> ((b: Int, f: Float, c: Float, r: Int)) in
    
    let j = i / (width / 2)
    return (j, 0.0, 0.0, 0)
}

(0..<width).map { (i: Int) -> ((b: Float, f: Float, c: Float, r: Int)) in
    
    let w = Float(width)
    let j = Float(i) / w * 2
    let f = abs(Int((w - 1.0) * floor(j)) - i)
    return (j, floor(Float(j)), ceil(Float(j)), f)
}

(0...5).map { (i: Int) -> ([Float]) in

    let w = Float(width)
    let j = Float(i) / w

    return [j, floor(Float(j)), ceil(Float(j))]
}

stride(from: 0, to: 64, by: 8).flatMap { y in

    [
        UInt8(y),
        UInt8(y),
        UInt8(y),
        UInt8(255)
    ]
}
