//: Playground - noun: a place where people can play
// https://www.natashatherobot.com/swift-what-are-protocols-with-associated-types/

import Cocoa

protocol Initializable {

    init()
}

// Power is a generic
// Power's type must adopt protocol Initializable

class Pokeman <Power: Initializable> {

    func attack() -> Power { return Power() }
}

// Power types
struct 🌧: Initializable {

    func wut() { print("water") }
}

struct 🌩: Initializable {

    init() { wut() }
    func wut() { print("lightning") }
}

struct 🔥: Initializable {

    func wut() { print("fire") }
}

class Pikachu: Pokeman<🌩> {}

let pikachu = Pikachu()

// Instead of subclassing, let’s do the same thing with PATs!
// PAT == Protocol Associated Type

protocol PowerTrait {

    associatedtype Power: Initializable

    func attack() -> Power
}

extension PowerTrait {

    func attack() -> Power { return Power() }
}

struct Raichu: PowerTrait {

    typealias Power = 🌩
}

struct Charizard: PowerTrait {

    typealias Power = 🔥
}

let charizard = Charizard()

pikachu.attack()
charizard.attack()
