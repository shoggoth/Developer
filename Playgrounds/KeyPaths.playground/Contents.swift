import Cocoa

// https://blog.joshtastic.de/2019/08/22/swift-keypaths/

struct Cat {
    
    let name: String
    var colour: String
}

class Dog {
    
    let name: String = "Fido"
    var colour: String = "Black"
}

let enchilada = Cat(name: "Enchilada", colour: "Tabby")

let name = enchilada[keyPath: \Cat.name]

// Look at the types for these keypaths
let t1 = type(of: \Cat.name)
let t2 = type(of: \Cat.colour)
let t3 = type(of: \Dog.colour)

// https://www.hackingwithswift.com/articles/57/how-swift-keypaths-let-us-write-more-natural-code

struct Person: Identifiable {
    
    static let uniqueIdentifier = \Person.socialSecurityNumber
    
    var socialSecurityNumber: String
    var name: String
}

struct Book: Identifiable {

    static let uniqueIdentifier = \Book.isbn

    var isbn: String
    var title: String
}

// Create an Identifiable protocol that uses an associated type (a hole in the protocol), then use that as a keypath.
// What this means is that every conforming type will be asked to provide a keypath that points towards whatever property identifies it uniquely

protocol Identifiable {
    
    associatedtype Identifier
    
    static var uniqueIdentifier: WritableKeyPath<Self, Identifier> { get }
}

// Print the identifier of any Identifiable type like this:

func printIdentifier<T: Identifiable>(thing: T) { print(thing[keyPath: T.uniqueIdentifier]) }

printIdentifier(thing: Person(socialSecurityNumber: "123-456-789", name: "ButterBall, Brian"))
printIdentifier(thing: Book(isbn: "12345-6789", title: "Mung beans on the sprout."))
