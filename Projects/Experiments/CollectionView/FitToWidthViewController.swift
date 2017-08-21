//
//  FitToWidthViewController.swift
//  Experiments
//
//  Created by Rich Henry on 26/07/2017.
//  Copyright © 2017 Dogstar Industries. All rights reserved.
//

import UIKit

class FitToWidthViewController: UIViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    deinit {

        print("deinit \(self)")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // UIView.setAnimationsEnabled(false)
        navigationItem.prompt = "This has got a prompt"
        // UIView.setAnimationsEnabled(true)

        // Animate the prompt out after a certain time has elapsed.
        let fadeTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: fadeTime) { self.navigationItem.prompt = nil }

        // Flow layout will become dynamic in nature once you set the estimatedItemSize property.
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
    }
}

class FitToWidthCellCollectionViewCell : UICollectionViewCell {

    var isHeightCalculated: Bool = false

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        if !isHeightCalculated {

            setNeedsLayout()
            layoutIfNeeded()

            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)

            var newFrame = layoutAttributes.frame
            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
            layoutAttributes.frame = newFrame

            isHeightCalculated = true
        }

        return layoutAttributes
    }
}
