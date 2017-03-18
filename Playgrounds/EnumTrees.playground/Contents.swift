//: Playground - noun: a place where people can play

import Cocoa

// http://cutting.io/posts/the-power-of-swift-enums/
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html#//apple_ref/doc/uid/TP40014097-CH12-ID536

indirect enum Tree<T: Comparable> : CustomStringConvertible {
    
    case Empty
    case Node(value: T, left: Tree, right: Tree)
    
    func insert(newValue: T) -> Tree {
        
        switch self {
            
        case .Empty:
            return Tree.Node(value: newValue, left: Tree.Empty, right: Tree.Empty)
            
        case let .Node(value, left, right):
            
            if newValue > value { return Tree.Node(value: value, left: left, right: right.insert(newValue: newValue)) }
            else { return Tree.Node(value: value, left: left.insert(newValue: newValue), right: right) }
        }
    }
    
    var depth: Int {
        
        switch self {
            
        case .Empty:
            return 0
        case let .Node(_, left, right):
            return 1 + max(left.depth, right.depth)
        }
    }
    
    var description: String {
        
        switch self {
            
        case .Empty:
            return "."
        case let .Node(value, left, right):
            return "[\(left) \(value) \(right)]"
        }
    }
}

var it = Tree<Int>.Empty

it = it.insert(newValue: 23)
it = it.insert(newValue: 15)
it = it.insert(newValue: 42)
it = it.insert(newValue: 11)
it = it.insert(newValue: 13)
it = it.insert(newValue: 9)
it = it.insert(newValue: 54)
print(it.depth)

var st = Tree<String>.Empty

st = st.insert(newValue: "e")
st = st.insert(newValue: "d")
st = st.insert(newValue: "b")
st = st.insert(newValue: "g")
st = st.insert(newValue: "f")
st = st.insert(newValue: "c")
st = st.insert(newValue: "a")
print(st.depth)
