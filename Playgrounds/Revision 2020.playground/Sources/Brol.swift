import Foundation

public func experimentOne() {
    
    let fl = Float(4.0)
    let tp = (1, 3.7)
    let fn: (Int, Double) -> Bool = { i, f in (Double(i) > f) }

    print(type(of: fl))
    print(type(of: tp))
    print(type(of: fn))

    print(!fn(3, 2))

    if var wu = Int("12") {
        multiplyBy2(&wu)
    }

    let s1 = "This should be a String (not optional)"
    let s2 = String(31337)  // Why isn't this optional?
    let i1 = Int(s2)
    let s3 = String(i1!)    // This has to be an optional

    print(type(of: s1))
    print(type(of: s2))
    print(type(of: s3))
    print(type(of: i1))     // This is optional
}

public func experimentTwo() {
    
    var numbers = [20, 34, 7, 86, 18, 20]

    let mult = 3

    let foo = { (num: Int) -> Int in mult * num }
    func bar (num: Int) -> Int { num * mult }
    let baz = { num in mult * num }

    // All these are the same thing. Note also that they capture from the scope (mult).
    let _ = numbers.map(foo)
    let _ = numbers.map(bar)
    let _ = numbers.map(baz)
    let _ = numbers.map({ (num: Int) -> Int in mult * num })
    let _ = numbers.map({ mult * $0 })
    let _ = numbers.map{ mult * $0 }
}

func setToThree(_ i: inout Int) { i = 3 }

func multiplyBy2(_ i: inout Int) { i *= 2 }

func optionals() {
    
    let nickName: String? = nil
    let wigaName: String? = "Wigger"
    let fullName: String = "Bum Holio"

    // Optionals can be chained more than once.
    let greeting = "Hi \(nickName ?? wigaName ?? fullName)"
    
    print(greeting)
}
