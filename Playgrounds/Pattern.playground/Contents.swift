import Cocoa

enum PointPattern {
    
    case rectangle(w: Int, h: Int)
    case circle(divs: Int)
    
    func trace(size: CGFloat, with:(CGPoint) -> Void) {
        
        switch self {
        case let .rectangle(w, h):
            
            let off = size * 0.5
            (0..<h).forEach { y in (0..<w).forEach { x in with(CGPoint(x: CGFloat(x) * size - off, y: CGFloat(y) * size - off)) }}
            
        case let .circle(divs):
            
            let inc = (.pi * 2.0) / Double(divs)
            
            (0..<divs).forEach { d in
                
                let angle = Double(d) * inc
                with(CGPoint(x: CGFloat(sin(angle)) * size, y: CGFloat(cos(angle)) * size)) }
        }
    }
}

func wave(s: String) {
    
    let f: (CGPoint) -> Void = { p in print("\(s) \(p)") }
    PointPattern.circle(divs: 4).trace(size: 1, with: f)
}

let f: (CGPoint) -> Void = { p in print("f Func \(p)") }
PointPattern.circle(divs: 4).trace(size: 1) { p in f(p) }

wave(s: "Belming")
wave(s: "Mong")

//PointPattern.rectangle(w: 2, h: 3).trace(size: 1) { p in print("Rect 1 \(p)") }
//PointPattern.rectangle(w: 2, h: 2).trace(size: 2) { p in print("Rect 2 \(p)") }
//PointPattern.rectangle(w: 2, h: 2).trace(size: 4) { p1 in
//    PointPattern.rectangle(w: 2, h: 2).trace(size: 2) { p2 in
//        print("Rect 3 \(CGPoint(x: p1.x + p2.x, y: p1.y + p2.y))")
//    }
//}
