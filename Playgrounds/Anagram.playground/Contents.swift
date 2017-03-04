//: Playground - noun: a place where people can play

import Cocoa

extension String {

    func isAnagramOf(potentialAnagram: String) -> Bool {

        let stripAndSort = { (str: String) in return (Array(str.lowercaseString).filter { $0 != " " }).sorted { $0 > $1 } }

        return stripAndSort(self) == stripAndSort(potentialAnagram)
    }
}

if "Laughable Butane Bob".isAnagramOf("Analogue Bubblebath") { println("An anagram is you!!11!!") }
if "🌵☺️👨🏻👰🏻👻👽🐮".isAnagramOf("👰🏻🌵🐮☺️👨🏻👽👻") { println("An anagram is you!!11!!") }

