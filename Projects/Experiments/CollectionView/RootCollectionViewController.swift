//
//  RootCollectionViewController.swift
//  Experiments
//
//  Created by Rich Henry on 20/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class RootCollectionViewController: UICollectionViewController {

    private let dataItems = [(string: "String 1", type:"StringCell", value: 0, hi: false, sel: false),
                             (string: "String 2", type:"SizingCell", value: 0, hi: false, sel: false),
                             (string: "String 3", type:"StringCell", value: 0, hi: false, sel: false),
                             (string: "String 4", type:"StringCell", value: 0, hi: false, sel: false),
                             (string: "String 5", type:"StringCell", value: 0, hi: false, sel: false),
                             (string: "String 6", type:"StringCell", value: 0, hi: false, sel: false)]

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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return dataItems.count }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dataItems[indexPath.row].type, for: indexPath)
    
        // Configure the cell
        (cell as? StringCell)?.configure(content: dataItems[indexPath.row].string)

        return cell
    }

    // MARK: UICollectionViewDelegate

    // Specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return dataItems[indexPath.row].hi }

    // Specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return dataItems[indexPath.row].sel }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

// MARK: - Model

struct StringCellContent {

    var text: String?
}

// MARK: - View

class StringCell : UICollectionViewCell {

    @IBOutlet private var label: UILabel!

    func configure(content: String) {

        label.text = content

        // Accessibility
        label.accessibilityLabel = "Title"
        label.accessibilityValue = content

        // Appearance
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }
}
