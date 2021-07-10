import Cocoa

var greeting = "Hello, playground"

struct Spawner {
    
    let activeCount: Int
}

let spawners = [
    "Foo" : Spawner(activeCount: 12),
    "Bar" : Spawner(activeCount: 13),
    "Baz" : Spawner(activeCount: 114)
]

var count: Int
count = { var total = 0; spawners.forEach { total += $1.activeCount }; return total }()
count
count = (spawners.reduce(("", 0)) { (nil, $0.1 + $1.1.activeCount) }).1
count
