import UIKit

struct Mob {
    let kind: Kind
    let name: String
    let maxSpeed: Double
    
    func describe() {
        switch kind {
        case .player(let i):
            print("Player \(i) up!")
        case .enemy(let n):
            print("A wild \(n) appears!")
        }
    }
}

extension Mob {
    enum Kind {
        case player(Int)
        case enemy(String)
    }
    
    func makeStates(p1: Int, p2: String) -> String { "Two params: \(p1) and \(p2)" }
    func makeStates(p1: Int, p2: String, p3: Double) -> String { "Three params: \(p1), \(p2) and \(p3)" }
}

Mob(kind: .player(1), name: "Player 0", maxSpeed: 234).describe()
Mob(kind: .player(2), name: "Player 1", maxSpeed: 234).describe()
Mob(kind: .enemy("Malchik"), name: "Monster", maxSpeed: 234).describe()

let mob = Mob(kind: .enemy("Grumpling"), name: "Monster", maxSpeed: 303)
print(mob.makeStates(p1: 2, p2: "Two"))
print(mob.makeStates(p1: 3, p2: "Three", p3: 3))
