//
//  DataSource.swift
//  Experiments
//
//  Created by Rich Henry on 20/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class DataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBInspectable var sectionCount: Int = 0
    @IBInspectable var contentCount: Int = 0

    @IBInspectable var cellIdentifier: String = "DefaultCell"
    @IBInspectable var canHighlight: Bool = false
    @IBInspectable var canSelect: Bool = false

    @IBInspectable var headerIdentifier: String = "DefaultHeader"
    @IBInspectable var footerIdentifier: String = "DefaultFooter"

    private typealias DataType = (string: String, type: String, value: Int, hi: Bool, sel: Bool)

    private var data: [[DataType]] = []

    // MARK: Lifecycle

    override func awakeFromNib() {

        for section in 0..<sectionCount { data.append(sectionContent(section)) }
    }

    // MARK: Content generation

    private func sectionContent(_ sectionIndex: Int) -> [DataType] {

        var content = [DataType]()

        for cellIndex in 0..<contentCount {

            content.append(DataType(string: "Sec \(sectionIndex) Cell \(cellIndex)", type: cellIdentifier, value: 0, hi: canHighlight, sel: canSelect))
        }

        return content
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int { return data.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return data[section].count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data[indexPath.section][indexPath.row].type, for: indexPath)

        // Configure the cell
        (cell as? StringCell)?.configure(data[indexPath.section][indexPath.row].string)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let reuseIdentifier = kind == UICollectionElementKindSectionHeader ? headerIdentifier : footerIdentifier

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath)

        return view
    }

    // MARK: UICollectionViewDelegate

    // Specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return data[indexPath.section][indexPath.row].hi }

    // Do the highlighting
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = UIColor.blue
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {

        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = nil
    }
    

    // Specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return data[indexPath.section][indexPath.row].sel }
}

// MARK: - Random name generation

private extension Collection where Index == Int {

    func randomElement() -> Iterator.Element? {

        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(endIndex)))]
    }
}

private func randomName() -> String {

    let title = ["Mr.", "Mrs.", "Miss", "Dr.", "Reverend"]

    let firstNameSyllableOne = ["Rich", "Ant", "St", "Jas", "Mart", "Bor", "Alfr", "Alb", "Barr", "Cam", "Ham", "T", "Br"]
    let firstNameSyllableTwo = ["ard", "ony", "er", "on", "in", "an", "is", "ed", "ert", "y", "ie", "eron", "ish", "ington"]

    let surNameSyllableOne = ["Bim", "Bum", "Chur", "Cum", "McFer", "Pup", "Ro", "Tram"]
    let surNameSyllableTwo = ["kin", "son", "ley", "lish", "ple", "mont"]

    return ("\(title.randomElement()!) \(firstNameSyllableOne.randomElement()!)\(firstNameSyllableTwo.randomElement()!) \(surNameSyllableOne.randomElement()!)\(surNameSyllableTwo.randomElement()!)")
}

private func randomString(length: Int) -> String {

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
