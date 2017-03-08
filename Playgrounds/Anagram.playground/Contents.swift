//: Playground - noun: a place where people can play

import Cocoa

extension String {

    func isAnagramOf(_ potentialAnagram: String) -> Bool {

        let stripAndSort = { (str: String) in return Array(str.trimmingCharacters(in: .whitespacesAndNewlines).utf16).sorted() }
        //let stripAndSort = { (str: String) in return (str.lowercaseString).filter { $0 != " " }.sorted { $0 > $1 } }

        return stripAndSort(self) == stripAndSort(potentialAnagram)
    }
}

if "Laughable Butane Bob".isAnagramOf("Analogue Bubblebath") { print("An anagram is you!!11!!") }
if "🌵☺️👨🏻👰🏻👻👽🐮".isAnagramOf("👰🏻🌵🐮☺️👨🏻👽👻") { print("An anagram is you!!22!!") }

