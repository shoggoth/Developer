//: Playground - noun: a place where people can play

import Cocoa

extension String {

    func isAnagramOf(str2: String) -> Bool {

        let foo = { (str: String) in return (Array(str).filter { $0 != " " }).sorted { $0 > $1 } }

        return foo(self) == foo(str2)
    }
}

var str1 = "hello there"

var set1: Set<Character> = []
for char in str1 { set1.insert(char) }
for char in str1 { set1.insert(char) }

print("uniques characters in \(str1) = \(set1.count)")

var str2 = "there ghello"

var arr1 = (Array(str1).filter { $0 != " " }).sorted { $0 > $1 }
var arr2 = (Array(str2).filter { $0 != " " }).sorted { $0 > $1 }

print("1 = \(arr1)")
print("2 = \(arr2)")

//var arr1 = Array(str1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())); arr1.sort { $0 > $1 }
//var arr2 = Array(str2.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())); arr2.sort { $0 > $1 }

if str1.isAnagramOf(str2: str2) { print("An anagram is you!!11!!") }

//func isAnagram(str1: String, str2: String) -> Bool {
//
//    let foo = { (str: String) in return (Array(str).filter { $0 != " " }).sorted { $0 > $1 } }
//
//    return foo(str1) == foo(str2)
//}

