//
//  main.swift
//  test
//
//  Created by Richard Henry on 16/10/2018.
//  Copyright © 2018 Dogstar Industries Ltd. All rights reserved.
//

import Foundation

extension String {
    
    func isAnagramOf(potentialAnagram other: String) -> Bool {
        
        let stripAndSort = { (str: String) in return Array(str.lowercased()).filter { $0 != " "}.sorted { $0 > $1 }}
        
        return stripAndSort(self) == stripAndSort(other)
    }
}

if "Laughable Butane Bob".isAnagramOf(potentialAnagram: "Analogue Bubblebath") { print("1: anagram") }
if "Hangable Auto Bulb".isAnagramOf(potentialAnagram: "Analogue Bubblebath") { print("2: anagram") }
if "Bucephalus Bouncing Ball".isAnagramOf(potentialAnagram: "Analogue Bubblebath") { print("2.1: anagram") }
if "🐶🦊🥐🎱🐮".isAnagramOf(potentialAnagram: "🎱🥐 🐮🐶🦊") { print("3: anagram") }
if "🦊🥐🎱🐶🐮".isAnagramOf(potentialAnagram: "🥐🐮🐶🦊") { print("4: anagram") }
