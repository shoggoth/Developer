//: Playground - noun: a place where people can play

import Cocoa

class Generic <T> {

    var value: T? = nil

    func printSelf() { print("Self = \(self) value = \(String(describing: value))") }
}

let intGen = Generic<Int>()
intGen.value = 23

intGen.printSelf()

class Concrete : Generic<Float> {
}

let floatGen = Concrete()
floatGen.value = 2.3

floatGen.printSelf()