//: Playground - noun: a place where people can play
// https://www.raywenderlich.com/148448/introducing-protocol-oriented-programming

import Cocoa

protocol Bird : CustomStringConvertible {

    var name: String { get }
    var canFly: Bool { get }
}

// Here is the magic. Extending protocols with default implementations.
// This defines an extension on Bird that sets the default behavior for canFly to return true whenever the type is also Flyable.
// In other words, any Flyable bird no longer needs to explicitly declare so!

extension Bird {

    var canFly: Bool { return self is Flyable }
}

protocol Flyable {

    var airSpeedVelocity: Double { get }
}

// Some bird examples with structs

struct FlappyBird : Bird, Flyable {

    let name: String
    //let canFly = true

    let flapAmplitude: Double
    let flapFrequency: Double

    var airSpeedVelocity: Double { return 3 * flapAmplitude * flapFrequency }
}

struct Penguin : Bird {

    let name: String
    //let canFly = false
}

struct SwiftBird : Bird, Flyable {

    var name: String { return "Swift \(version)" }
    //let canFly = true

    let version: Double

    var airSpeedVelocity: Double { return version * 1000.0 }
}

// And some with enums

enum UnladenSwallow : Bird, Flyable {

    case african
    case european
    case unknown

    var name: String {

        switch self {

        case .african: return "African"
        case .european: return "European"
        case .unknown: return "What do you mean? African or European?"
        }
    }

    var airSpeedVelocity: Double {

        switch self {

        case .african: return 10.0
        case .european: return 9.9
        case .unknown: fatalError("You are thrown from the bridge of death!")
        }
    }
}

// I want UnladenSwallow.unknown to return false for canFly. Is it possible to override the default implementation? Yes, it is.

extension UnladenSwallow {

    var canFly: Bool { return self != .unknown }
}

// Conforming to CustomStringConvertible means your type needs to have a description property so it acts like a String.
// Does that mean you now have to add this property to every current and future Bird type?
// Of course, there’s an easier way with protocol extensions.

extension CustomStringConvertible where Self : Bird {

    var description: String { return canFly ? "I can fly" : "Ill just sit here then" }
}

// Test out them…

UnladenSwallow.unknown.canFly
UnladenSwallow.african.canFly
Penguin(name: "Emperor").canFly

SwiftBird(version: 3.0).airSpeedVelocity
FlappyBird(name: "Flappy", flapAmplitude: 2.0, flapFrequency: 3.0).airSpeedVelocity

UnladenSwallow.european

// Enough of the birds then, some numbers

// slice, for example, is not an Array of integers but an ArraySlice<Int>. This special wrapper type acts as a view into the original array and avoids costly
// memory allocations that can quickly add up. Similarly, reversedSlice is actually a ReversedRandomAccessCollection<ArraySlice<Int>> which is again just a 
// wrapper type view into the original array.

let numbers = [10, 20, 30, 40, 50, 60]
let slice = numbers[1...3]
let reversedSlice = slice.reversed()
let answer = reversedSlice.map { $0 * 10 }

print(answer)

// Now some vehicles to race against birds

class Motorcycle {

    var name: String
    var speed: Double

    init(name: String) {

        self.name = name
        speed = 200
    }
}

protocol Racer {

    var speed: Double { get }
}

extension FlappyBird : Racer {

    var speed: Double { return airSpeedVelocity }
}

extension SwiftBird : Racer {

    var speed: Double { return airSpeedVelocity }
}

extension Penguin : Racer {

    var speed: Double { return 42 }
}

extension UnladenSwallow : Racer {

    var speed: Double { return canFly ? airSpeedVelocity : 0 }
}

// Motorcycle already has a speed var

extension Motorcycle : Racer {}

// The line up for this race

let racers: [Racer] =
    [UnladenSwallow.african,
     UnladenSwallow.european,
     UnladenSwallow.unknown,
     Penguin(name: "King Penguin"),
     SwiftBird(version: 3.0),
     FlappyBird(name: "Felipé", flapAmplitude: 3.0, flapFrequency: 20.0),
     Motorcycle(name: "Rossi")
]

// *good*
func topSpeed(of racers: [Racer]) -> Double {

    return racers.max(by: { $0.speed < $1.speed })?.speed ?? 0
}

topSpeed(of: racers)

// *better*
// This takes a sequence instead of an Array so that we're able to do topSpeed(of: racers[1...3])
func topSpeed<RacerType: Sequence>(of racers: RacerType) -> Double where RacerType.Iterator.Element == Racer {

    return racers.max(by: { $0.speed < $1.speed })?.speed ?? 0
}

topSpeed(of: racers[1...3])

// *best*
private extension Sequence where Iterator.Element == Racer {

    func topSpeed() -> Double {

        return self.max(by: { $0.speed < $1.speed })?.speed ?? 0
    }
}

racers.topSpeed()
racers[1...3].topSpeed()
racers[5...6].topSpeed()

// Protocol comparators

protocol Score : Equatable, Comparable {

    var name:  String { get set }
    var value: Int { get }
}

struct RacingScore : Score {

    var name:  String
    let value: Int

    // Equatable
    static func ==(lhs: RacingScore, rhs: RacingScore) -> Bool { return lhs.value == rhs.value }

    // Comparable
    static func <(lhs: RacingScore, rhs: RacingScore) -> Bool { return lhs.value < rhs.value }
}

RacingScore(name: "Foo", value: 23) == RacingScore(name: "Bar", value: 23)
RacingScore(name: "Foo", value: 23) >= RacingScore(name: "Bar", value: 23)
RacingScore(name: "Foo", value: 23) <= RacingScore(name: "Bar", value: 23)
RacingScore(name: "Foo", value: 23) > RacingScore(name: "Bar", value: 42)
RacingScore(name: "Foo", value: 23) < RacingScore(name: "Bar", value: 42)

