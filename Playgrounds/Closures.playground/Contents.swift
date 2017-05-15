//: Closures and that

import Cocoa

let names = ["Chris", "Alex", "Eddy", "Barry", "Dan"]
let numbers = [23, 5, 15, 356, 27, 58, 19, 7]

// Sort using a function parameter

func backward(_ s1: String, _ s2: String) -> Bool { return s1 > s2 }

var reversedNames = names.sorted(by: backward)

// Using a closure with full specification

reversedNames = names.sorted(by: { (s1: String, s2: String) -> Bool in

    return s1 > s2
})

// Inferring the types from the context

reversedNames = names.sorted(by: { s1, s2 in

    return s1 > s2
})

let reversedNumbers = numbers.sorted(by: { s1, s2 in

    return s1 > s2
})

// Inferring the return type in single-expression closures

reversedNames = names.sorted(by: { s1, s2 in

    s1 > s2
})

// Shorthand argument names

/*
 Swift automatically provides shorthand argument names to inline closures, which can be used to refer to the values of the closure’s arguments by the names $0, $1, $2, and so on.

 If you use these shorthand argument names within your closure expression, you can omit the closure’s argument list from its definition, and the number and type of the shorthand argument names will be inferred from the expected function type. The in keyword can also be omitted, because the closure expression is made up entirely of its body
 */

reversedNames = names.sorted(by: {

    $0 > $1
})

// Operator methods

/*
Swift’s String type defines its string-specific implementation of the greater-than operator (>) as a method that has two parameters of type String, and returns a value of type Bool. This exactly matches the method type needed by the sorted(by:) method. Therefore, you can simply pass in the greater-than operator, and Swift will infer that you want to use its string-specific implementation 
 */

reversedNames = names.sorted(by: >)

// Trailing closures



