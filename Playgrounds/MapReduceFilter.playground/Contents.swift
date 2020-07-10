import Cocoa

// I couldn't find a way to map in place for an array.
// https://www.objc.io/blog/2018/04/17/map-in-place/
//extension Array { mutating func mapInPlace(_ transform: (Element)) -> Element { self.map(transform) } }

func printArrayWithIndices(_ arr: [Any]) { for (index, element) in arr.enumerated() { print("\(element) is at index \(index)") }}

/// Mapping things with the map function.

let arr = ["foo", "bar", "baz", "tat"].map { $0 + " (a)" }
let set: Set = ["foo", "bar", "baz", "tat"]
let dic = [ 12 : "dozen", 23 : "Eris", 42 : "meaning"]

let m = arr.map { $0 + " (map)" }
let d = dic.map { $0.key + 1 }

struct st {
    
    let val: Int
    let nam: String
}

class cl {
    
    let val: Int
    
    init(val: Int) { self.val = val }
}

//let stArr: [st] = [st(val: 3, nam: "foo"), st(val: 1, nam: "bar"), st(val: 7, nam: "baz")].map { $0.val * 23; $0.nam + " mut"; return $0 }
let stArr = [st(val: 3, nam: "foo"), st(val: 1, nam: "bar"), st(val: 7, nam: "baz")].map { return st(val: $0.val * 23, nam: $0.nam + " mut") }

printArrayWithIndices(stArr)

/// Reducing things with the reduce function.

let t1 = arr.reduce("", +)
let t2 = arr.reduce("t2 is ") { "\($0) and \($1)" }
let t3 = "t3 is \(arr.reduce("") { return ($0 == "" ? $1 : "\($0) and \($1)") })"
// reduce is not a straightforward solution here since you need special handling for the first element. String's join method is better for this purpose:
let t4 = "t4 is \(arr.joined(separator: " and "))"

/// Filtering things with the filter function

let f1 = arr.filter { $0.contains("ba") }
f1
