//
//  Random.swift
//  Frameworks
//
//  Created by Rich Henry on 28/07/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import Foundation

// MARK: Random generation

public func randomName() -> String {

    let title = ["Mr.", "Mrs.", "Miss", "Dr.", "Reverend"]

    let firstNameSyllableOne = ["Rich", "Ant", "St", "Jas", "Mart", "Bor", "Alfr", "Alb", "Barr", "Cam", "Ham", "T", "Br"]
    let firstNameSyllableTwo = ["ard", "ony", "er", "on", "in", "an", "is", "ed", "ert", "y", "ie", "eron", "ish", "ington"]

    let surNameSyllableOne = ["Bim", "Bum", "Chur", "Cum", "McFer", "Pup", "Ro", "Tram"]
    let surNameSyllableTwo = ["kin", "son", "ley", "lish", "ple", "mont"]

    return ("\(title.randomElement()!) \(firstNameSyllableOne.randomElement()!)\(firstNameSyllableTwo.randomElement()!) \(surNameSyllableOne.randomElement()!)\(surNameSyllableTwo.randomElement()!)")
}

public func randomString(length: Int) -> String {

    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {

        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

// MARK: - Local support

private extension Collection where Index == Int {

    func randomElement() -> Iterator.Element? {

        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}
