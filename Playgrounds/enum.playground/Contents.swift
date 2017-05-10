//: Playground - noun: a place where people can play

import Cocoa

enum Rank: Int {

    case Ace = 1
    case Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten
    case Jack, Queen, King

    func simpleDescription() -> String {

        switch self {

        case .Ace:
            return "Ace"

        case .Jack:
            return "Jack"

        case .Queen:
            return "Queen"

        case .King:
            return "King"

        default:
            return String(self.rawValue)
        }
    }
}

enum Suit {

    case Spades, Clubs, Hearts, Diamonds

    func colour() -> String { return self == .Spades || self == .Clubs ? "Black" : "Red" }

    func simpleDescription() -> String {

        switch self {

        case .Spades:
            return "Spades"

        case .Clubs:
            return "Clubs"

        case .Hearts:
            return "Hearts"

        case .Diamonds:
            return "Diamonds"
        }
    }
}

struct Card {

    var rank: Rank
    var suit: Suit

    func simpleDescription() -> String { return "The \(rank) of \(suit)" }
}

func compareRank(first: Rank, second: Rank) -> Int {

    return second.rawValue - first.rawValue
}

let ace = Rank.Ace
let arv = Rank.Ace.rawValue
let crv = Rank(rawValue: 3)
let crd = crv?.simpleDescription()
let tos = Card(rank: .Three, suit: .Spades)

tos.simpleDescription()

enum Bird : CustomStringConvertible {

    case Sparrow
    case Starling
    case Blackbird
    // Swft enums can have associated values
    case RacingPigeon(id: Int, name: String)
    case Other(name: String)

    var description: String {

        switch self {

        case .Sparrow: return "Sparrow"
        case .Starling: return "Starling"
        case .Blackbird: return "Blackbird"
        case let .RacingPigeon(id, name): return "Pigeon #\(id) called \(name)"
        case let .Other(name): return name
        }
    }
}

Bird.Sparrow
Bird.Other(name: "Emu")
Bird.RacingPigeon(id: 31337, name: "Boris")
Bird.RacingPigeon
