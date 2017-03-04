//: Playground - noun: a place where people can play

import Cocoa

// Can now init a let sensibly
let isIt = true
let myString: String

if (isIt) { myString = "YES" } else { myString = "NO" }

// New 'as'

class Animal {

    var name: String?

    init() { name = "Dunno" }

    func eat() { println("Om nom") }
}

class Dog : Animal {

    override init() {

        super.init()
        name = "Chuppa Chup"
    }

    override func eat() { println("Snarf") }
}

func asTest(animal: Animal?) {

    if let a = animal as? Dog { println("Woof") }
}

func asTest2(animal: Animal) {

    let dog = animal as! Dog

    println("Hasn't crashed")

    dog.eat()
}

let dog = Dog()
let cat = Animal()

asTest(cat)
asTest(dog)
asTest(nil)

asTest2(dog)
asTest2(cat)
println("Hasn't crashed")
