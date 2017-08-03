//
//  RootCollectionViewController.swift
//  Experiments
//
//  Created by Rich Henry on 20/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit
import Dogstar

class RootCollectionViewController: UICollectionViewController {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet var selectedBackgroundView: UIView!

    private let dataItems = [(string: "String 1", type:"SelectCell", value: 0, hi: true,  sel: true ),
                             (string: "String 2", type:"SizingCell", value: 0, hi: false, sel: false),
                             (string: "String 3", type:"Segue1Cell", value: 0, hi: true , sel: false),
                             (string: "String 4", type:"Segue2Cell", value: 0, hi: false, sel: false),
                             (string: "String 5", type:"Segue3Cell", value: 0, hi: false, sel: false),
                             (string: "String 6", type:"Segue4Cell", value: 0, hi: false, sel: false),
                             (string: "String a", type:"Segue5Cell", value: 0, hi: false, sel: false),
                             (string: "String d", type:"Segue6Cell", value: 0, hi: false, sel: false),
                             (string: "String e", type:"Segue7Cell", value: 0, hi: false, sel: false),
                             (string: "String b", type:"SelectCell", value: 0, hi: true,  sel: true ),
                             (string: "String c", type:"SelectCell", value: 0, hi: false, sel: true ),
                             (string: "String 7", type:"StringCell", value: 0, hi: true,  sel: false)]

    override func viewDidLoad() {

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToRoot(sender: UIStoryboardSegue) {

        print("And relax")
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return dataItems.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataItems[indexPath.row].type, for: indexPath)
    
        // Configure the cell
        (cell as? StringCollectionViewCell)?.configure(dataItems[indexPath.row].string)

        cell.backgroundView = backgroundView

        return cell
    }

    // MARK: UICollectionViewDelegate

    // Specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return dataItems[indexPath.row].hi }

    // Do the highlighting
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)

        cell?.contentView.backgroundColor = UIColor.blue
    }

    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)

        cell?.contentView.backgroundColor = nil
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)

        print("Selected \(String(describing: cell))")

        //super.collectionView(collectionView, didSelectItemAt: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath)

        print("Deselected \(String(describing: cell))")

        //super.collectionView(collectionView, didDeselectItemAt: indexPath)
    }

    // Specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return dataItems[indexPath.row].sel }
}

// MARK: - Model

struct StringCellContent {

    var text: String?
}

class SizingCollectionViewCell : StringCollectionViewCell {

    @IBOutlet private var subLabel: UILabel!

    override func configure(_ content: String) {

        super.configure("sup" + content)

        subLabel.text = "sub" + content

        // Accessibility
        subLabel.accessibilityLabel = "Sub"
        subLabel.accessibilityValue = content

        // Appearance
        subLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
}
