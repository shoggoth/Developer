import Foundation

/// This has come from https://andybargh.com/pattern-matching-in-swift/

public func patternExperiments() {
    
    /// The identifier pattern
    // Represents a concrete value just like in the more civilised languages such as C
    
    let ident = 1
    
    switch ident {
    case 1:
        print("Identifier pattern matched the integer 1")
    default:
        print("Identifier pattern was something else")
    }
    
    // The indentifier pattern can also be used within an if statement
    // This looks really retarded tbh.
    // Consider it as a shorthand for a switch...case statement.
    
    if case 1 = ident { print("Identifier pattern \(ident) matched the 1 in an if statement") }
    if 1 ~= ident { print("The if case and single equality looks retarded. This is a lot better.") }
    
    /// The wildcard pattern
    var wc = 3
    
    for _ in 1...3 { wc *= 3 }
    
    print("Wildcard is in the for loop \(wc)")
    
    // Can be used in a for loop as well, why would anyone do this though?
    if case _ = wc { print("this will always be print") }
    
    /// The tuple pattern
    // Now this should be starting to become a bit more of use.
    
    let tup = (2.0, "Hello")
    
    switch tup {
        
    case (1, "World"):
        print("Match 1")
        
    case (2, "Hello"):
        print("Match 2")
        
    default:
        print("No Match")
    }
    
    let tups = [(2, "Hello"), (3, "World"), (1, "Hello")]
    
    for tuple in tups {
        
        switch tuple {
            
        case (_, "Hello"):
            print(tuple.0)
        default:
            print("Didn't match")
        }
    }
    
    // Here is a shortened version of the above if the default isn't needed
    for case (_, "Hello") in tups { print("Matched") }
    
    /// The value binding pattern.
    // In the last example above, I was wondering how to get the matched value out and print it
    // Maybe this next thing is what I need to accomplish that end.
    // It is, and there is an equivalent as well supplied.
    
    for case (let x, "World") in tups { print("Matched \(x)") }
    for case let (x, "World") in tups { print("Matched \(x)") }
    
    // These are equivalent as well
    switch tup { case (let x, let y): print("Equiv \(x) \(y)") }
    switch tup { case let (x, y): print("Equiv \(x) \(y)") }
    
    // The value binding pattern can be used as part of an if or guard statement.
    let b = 10
    
    if case let c = b { print(c) }
    if case var c = b { c += 3; print(c) }
    
    if case b = 11, case let c = b { print(c) }
    
    /// The enumeration case pattern
    // Used to match the cases of an existing enumeration type.
    
    enum Orientation {
       case FaceUp
       case FaceDown(Int)
    }
}
