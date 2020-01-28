import Foundation

/// https://andybargh.com/pattern-matching-in-swift/

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
    if case _ = wc { print("this will always be print")}
    
    /// The tuple pattern
    // Now this should be starting to become a bit more of use.
    
    
}
