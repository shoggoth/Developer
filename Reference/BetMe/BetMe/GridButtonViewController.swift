//
//  GridButtonViewController.swift
//  BetMe
//
//  Created by Rich Henry on 12/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit

@IBDesignable class BetLayButton: UIButton {

    @IBInspectable var borderColor: UIColor = UIColor.clear {

        didSet { layer.borderColor = borderColor.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {

        didSet { layer.borderWidth = borderWidth }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {

        didSet { layer.cornerRadius = cornerRadius }
    }
}

class GridButtonViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var oddsStakeView: UIView!
    @IBOutlet weak var oddsLabel: UILabel!
    @IBOutlet weak var stakeLabel: UILabel!
    
    // MARK: Lifecycle

    deinit {

        print("Deiniting GridButtonViewController \(self)")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Did Load GridButtonViewController")
        oddsLabel.text = "2.0"
    }

    override func viewDidAppear(_ animated: Bool) {

        print("viewDidAppear - isBeingPresented : \(self.isBeingPresented) isBeingDismissed : \(self.isBeingDismissed) isMovingToParentViewController : \(self.isMovingToParentViewController) isMovingFromParentViewController : \(self.isMovingFromParentViewController)")

        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        print("viewWillDisappear - isBeingPresented : \(self.isBeingPresented) isBeingDismissed : \(self.isBeingDismissed) isMovingToParentViewController : \(self.isMovingToParentViewController) isMovingFromParentViewController : \(self.isMovingFromParentViewController)")

        super.viewWillDisappear(animated)
    }

    // MARK: Actions

    @IBAction func tapGestureRecognised(sender: UITapGestureRecognizer) {

        print("You are a tapper")
    }
    
    @IBAction func panGestureRecognised(sender: UIPanGestureRecognizer) {

        switch sender.state {

        case .began:
            view.addSubview(oddsStakeView)

        case .changed:
            let stake = sender.translation(in: sender.view).y * 0.1

            stakeLabel.text = String(format: "£%.2f", stake)

        case .ended:
            oddsStakeView.removeFromSuperview()

        default: break
        }
    }
}
