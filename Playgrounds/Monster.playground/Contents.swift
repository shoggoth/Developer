import Cocoa

// The rigmarole of accessing something in the Sources folder.
let ms = MonsterStruct()

// Gosh, I wish I could enumerate the types of monster in a game.
// Wouldn't it be useful if I could iterate through all the cases though.
// But we need to provide a custom implementation of allCases if we have associated values.
// https://stackoverflow.com/questions/61757785
enum DefenderMonsterType {
    
    var name: String { "DefenderMonster" }
    
    case lander(Int)
    case mutant(() -> ())
    case baiter
    case bomber
    case pod(() -> String)
    case swarmer
    
    func describe() {
        switch self {
        case .lander(let i):
            print("Landing on \(i) things, \(name)")
        case .bomber:
            print("Laying a bomb here")
        case .mutant(let f):
            f()
        case .pod(let f):
            print("Pods gonna \(f())")
        default:
            print("Huh, who knows")
        }
    }
}

// Assigning and type inference
var dmt1 = DefenderMonsterType.lander(9)
let dmt2: DefenderMonsterType = .pod { "Podling" }
var dmt3 = dmt2

dmt1.describe()

dmt1 = .swarmer
dmt1 = dmt2
dmt3 = .bomber
dmt3 = .lander(23)

dmt1.describe()
dmt3.describe()

// Case iteration is why we added the CaseIterable protocol above, silly.
// DefenderMonster.allCases.forEach { print("lol is a \($0)")}
// See the comment I made earlier in the file for the reason allCases above is commented out.

struct DefenderMonster {
    
    var name = "Jogger"
    let type: DefenderMonsterType
}

var dmtc = DefenderMonster(type: .lander(23))
dmtc.name = "Gonna Jog"
//dmtc.type = .bomber

var dm = [DefenderMonster]()
dm.append(DefenderMonster(type: .bomber))
dm.append(DefenderMonster(type: .lander(1)))
dm.append(DefenderMonster(type: .pod { "PodNigger" }))

dm.forEach { $0.type.describe() }
