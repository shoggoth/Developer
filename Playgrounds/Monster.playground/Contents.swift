import Cocoa

// The rigmarole of accessing something in the Sources folder.
let ms = MonsterStruct()

// Gosh, I wish I could enumerate the types of monster in a game.
// Wouldn't it be useful if I could iterate through all the cases though.
// But we need to provide a custom implementation of allCases if we have associated values.
// https://stackoverflow.com/questions/61757785
enum DefenderMonster {
    
    case lander(Int)
    case mutant
    case baiter
    case bomber
    case pod
    case swarmer
    
    func describe() {
        switch self {
        case .lander(let i):
            print("Landing on \(i) things")
        case .bomber:
            print("Laying a bomb here")
        default:
            print("Huh, who knows")
        }
    }
}

// Assigning and type inference
var dmt1 = DefenderMonster.lander(9)
let dmt2: DefenderMonster = .pod
var dmt3 = dmt2

dmt1.describe()

dmt1 = .swarmer
dmt1 = dmt2
dmt3 = .bomber
dmt3 = .lander(23)

dmt3.describe()

// Case iteration is why we added the CaseIterable protocol above, silly.
// DefenderMonster.allCases.forEach { print("lol is a \($0)")}
