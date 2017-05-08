//: Playground - noun: a place where people can play

import Cocoa

struct Foo {

    var storedVariable:String = {

        print("Making Stored Variable")

        return "Stored Variable"
        
    }()

    lazy var lazyStoredVariable:String = {

        print("Making Stored Variable Lazilly")

        return "Stored Variable"

    }()

    lazy var lazyComputedProperty: String = {

        print("Making Stored Variable Lazilly")

        let str = "Computed" + " " + "Property"

        return str
    }()
}

let foo = Foo()
let bar = { return "This is Bar" }()
let baz = { (str: String) in "\(str) is Baz" }("This")
let boi = { return "This is Boi" }

bar
baz
boi()