//: Playground - noun: a place where people can play

import Cocoa

class DeinitTest {

    internal var counter: Int

    init (counter: Int) {

        self.counter = counter
    }

    deinit {

        print("Going away \(counter)")
    }
}

var foo: DeinitTest? = DeinitTest(counter: 12)
foo?.counter = 23

foo = DeinitTest(counter: 42)
foo = nil