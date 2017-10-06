//
//  MarketViewController.swift
//  BetMe
//
//  Created by Rich Henry on 30/05/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import UISupport

class MarketViewController : UICollectionViewController {

    internal var rootSearchGroup: SearchGroupEntry? = nil

    private let reuseIdentifier = "MarketCell"

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        // print("RSG = \(rootSearchGroup)")

        (self.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return (rootSearchGroup?.data["children"] as? [[String : Any]])?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell
        if let markets = rootSearchGroup?.data["children"] as? [[String : Any]] {

            (cell as? MarketInjectable)?.market = Market(data: markets[indexPath.row])
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool { return true }

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        (segue.destination as? MarketInjectable)?.market = (sender as? MarketInjectable)?.market
    }
}

class MarketCell : UICollectionViewCell, MarketInjectable {

    var market: Market? {

        didSet { demoText.text = market?.name }
    }

    @IBOutlet weak var demoText: UILabel!
}
