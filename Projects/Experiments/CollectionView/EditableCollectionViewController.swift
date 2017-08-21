//
//  EditableCollectionViewController.swift
//  Experiments
//
//  Created by Rich Henry on 27/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit
import Dogstar

class EditableCollectionViewController: UICollectionViewController {

    @IBOutlet var dataSource: DataSource!

    override func viewDidLoad() {

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: Actions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {

        dataSource.createNewItem(in: collectionView!)

        //collectionView?.performBatchUpdates(<#T##updates: (() -> Void)?##(() -> Void)?##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
    }

    @IBAction func trashButtonTapped(_ sender: UIBarButtonItem) {

        dataSource.deleteSelectedItems(from: collectionView!)
    }

    // MARK: Resizing

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

class EditableViewCell : StringCollectionViewCell {

    override func awakeFromNib() {

        Bundle.main.loadNibNamed("CellViews", owner: self, options: nil)
    }
}
