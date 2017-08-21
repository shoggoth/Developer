//
//  AutoLayoutViewController.swift
//  Experiments
//
//  Created by Rich Henry on 26/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class AutoLayoutViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {

        super.viewDidLoad()

        // In iOS10 there is new constant called UICollectionViewFlowLayoutAutomaticSize.
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class AutoLayoutCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {

        heightConstraint.constant = 320
        widthConstraint.constant = 320
    }

//    override func prepareForReuse() {
//
//        print(contentView)
//    }
}
