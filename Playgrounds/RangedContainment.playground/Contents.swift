//: Playground - noun: a place where people can play

import Cocoa

(1...10).contains(2)
1...10 ~= 2
(1...10).contains(23)
1...10 ~= 23

if 2 ~= 1...3 { print("In range") }

extension Comparable {

    /// Returns a Boolean value indicating whether a value is included in a
    /// range.
    ///
    /// You can use this pattern matching operator (`~=`) to test whether a value
    /// is included in a range. The following example uses the `~=` operator to
    /// test whether an integer is included in a range of single-digit numbers.
    ///
    ///     let chosenNumber = 3
    ///     if chosenNumber ~= 0...9 {
    ///         print("\(chosenNumber) is a single digit.")
    ///     }
    ///     // Prints "3 is a single digit."
    ///
    /// - Parameters:
    ///   - lhs: A value to match against `rhs`.
    ///   - rhs: A range.

    public static func ~=(lhs: Self, rhs: ClosedRange<Self>) -> Bool {
        return rhs ~= lhs
    }
}

if 2 ~= 1...3 { print("In range") }
