//
//  LockStateController.swift
//  iDispense
//
//  Created by Richard Henry on 11/06/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

internal class LockButton : UIButton {

    var unlocked: Bool {

        get { return isSelected }
        set { isSelected = newValue }
    }
    
    var locked: Bool {

        get { return !isSelected }
        set { isSelected = !newValue }
    }
}

class LockStateController: NSObject {

    // MARK: Properties

    var order: LensOrder!
    var lockStateChangedBlock: ((_ newState: Bool) -> Void)?

    @IBOutlet var lensDetailViews: [PurchaseDetailsView]!
    @IBOutlet var lensBlankSizeLabels: [UILabel]!
    @IBOutlet var lockButton: LockButton!

    // MARK: Actions

    @IBAction func lensUnlockPressed(_ sender: LockButton) {

        sender.locked = sender.unlocked

        if sender.locked { copyLockedParameters() } else { order.leftLens = nil }

        formatLensLabels()

        lockStateChangedBlock?(sender.locked)
    }

    func setupLockButtonState() {

        lockButton.locked = order.leftLens == order.rightLens
    }

    func copyLockedParameters() {

        if lockButton.locked {

            order.leftLens = order.rightLens
            order.leftTreatments = order.rightTreatments
            order.leftBlankSize = order.rightBlankSize

            // Mark the order as having been modified.
            order.order?.dateModified = Date()
        }
    }

    func formatLensLabels() {

        let nullBlankSizeString = "No Blank Size Selected"

        lensDetailViews[0].setupFromPurchase(order.rightLens)
        lensDetailViews[1].setupFromPurchase(order.treatment(.Tint))
        lensDetailViews[2].setupFromPurchase(order.treatment(.Coat))
        lensDetailViews[3].setupFromPurchase(order.treatment(.Finish))

        lensBlankSizeLabels[0].isEnabled = lensDetailViews[0].purchase
        var blankSize = order.rightBlankSize ?? 0
        lensBlankSizeLabels[0].text = blankSize == 0 ? nullBlankSizeString : "Blank \(blankSize) mm"

        lensDetailViews[4].setupFromPurchase(order.leftLens)
        lensDetailViews[5].setupFromPurchase(order.treatment(.Tint, onLeft: true))
        lensDetailViews[6].setupFromPurchase(order.treatment(.Coat, onLeft: true))
        lensDetailViews[7].setupFromPurchase(order.treatment(.Finish, onLeft: true))

        lensBlankSizeLabels[1].isEnabled = lensDetailViews[4].purchase && lockButton.unlocked
        blankSize = order.leftBlankSize ?? 0
        lensBlankSizeLabels[1].text = blankSize == 0 ? nullBlankSizeString : "Blank \(blankSize) mm"
    }
}
