//: Playground - noun: a place where people can play

import Cocoa

class MyFunClass {

    func doSomething(activity: String, handler: (String) -> Void) {

    }
}

let fun = MyFunClass()

// From https://twitter.com/NatashaTheRobot
// That is rather old. Probably the syntax has changed since 2014
// fun.doSomething("fun", handler: { (funString) -> Void in })

class MyClass {

    func doSomeStringMagic(str: String, handler: (String) -> Void) {

        _ = handler(str)
    }

    func doSomeStringLenMagic(str: String, handler: (String) -> (Int, String)) -> (Int, String) {

        return handler(str)
    }
}

let my = MyClass()

// Here it is with and without the trailing closure syntax
my.doSomeStringMagic(str: "Hello, World!", handler: { foo in print("Not using it \(foo)") })
my.doSomeStringMagic(str: "Hello, World!") { foo in print("Using it \(foo)") }