import Cocoa
import GameKit

struct Statistics {
    
    let str: Int   // How hard you hit something, how much you can carry, and how well you tend to do with strength based skill checks.
    let dex: Int   // How fast you are, as well as how successful you are with ranged attacks.
    let con: Int   // Has a direct effect on your hit points, as well as your resistance to poisoning, how fast you sober up, and the likes.
    let wis: Int   // Knowing about the world around you as well as how perceptive you are. It determines what you naturally notice.
    let int: Int   // How smart you are. It’s that simple really: Intelligence is usually academic intelligence – so how much you know about things.
    let cha: Int   // How good you are with people. It is how good you are at persuading people you are a good guy or how well you get on with NPCs.

    func getModifier(stat: Int) -> Int { (stat / 2) - 5 }
}

//(1...30).forEach { print("s \($0) m \(getModifier(stat: $0))") }

let d6 = GKRandomDistribution.d6()
let tosses = Array(0...5).map { _ in Array(0...3).map { _ in d6.nextInt() }.sorted().dropFirst().reduce(0, +) }.sorted()
print(tosses)

let td6 = Array(0...2).map { _ in d6.nextInt() }.reduce(0, +)
let fd6 = Array(0...3).map { _ in d6.nextInt() }.sorted().dropFirst().reduce(0, +)
print(td6)
print(fd6)

let t = Array(0...3).map { _ in d6.nextInt() }.sorted().dropFirst()
print(t)

enum EnemyMob {
    case fighter
    case thief
    
    func stats() -> Statistics {
        switch self {
        case .fighter:
            Statistics(str: 7, dex: 7, con: 7, wis: 7, int: 7, cha: 7)
        case .thief:
            Statistics(str: 7, dex: 7, con: 7, wis: 7, int: 7, cha: 7)
        }
        return Statistics(str: 7, dex: 7, con: 7, wis: 7, int: 7, cha: 7)
    }
}

let enemy: EnemyMob = .fighter
