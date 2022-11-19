import Cocoa

var currentTime: TimeInterval = 9

struct DeltaTime {
    
    let last: TimeInterval
    
    init(t: TimeInterval = 0) {
        last = t
    }
    
    init(dt: DeltaTime) {
        last = dt.last
    }
}

while currentTime < 23 {
    
    let delta = DeltaTime(t: currentTime)
    print("Time = \(currentTime)")
    let d2 = DeltaTime(dt: delta)
    
    currentTime += 0.5
}
