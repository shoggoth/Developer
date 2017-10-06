//
//  PurchaseDetailsView.swift
//  iDispense
//
//  Created by Richard Henry on 12/06/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

internal class PurchaseDetailsView : UIView {

    // MARK: Properties

    var enabled: Bool {

        get { return detailField.isEnabled }
        set { detailField.isEnabled = newValue || alwaysEnabled; priceField.isHidden = !newValue && lockButton?.unlocked ?? false }
    }

    var purchase: Bool = false

    @IBInspectable var noSelectionString: String = "No Selection"
    @IBInspectable var alwaysEnabled: Bool = false

    @IBOutlet weak var detailField: UILabel!
    @IBOutlet weak var priceField: UILabel!

    @IBOutlet weak var parentPurchase: PurchaseDetailsView?
    @IBOutlet weak var lockButton: LockButton?

    // MARK: Setup

    func setupFromPurchase(_ purchase: Purchase?) {

        let unlocked = lockButton?.unlocked ?? true

        if let p = purchase {

            enabled = unlocked
            self.purchase = true

            detailField.text = p.nameString
            priceField.text = p.priceString

        } else {

            self.purchase = false

            if let pp = parentPurchase { enabled = lockButton?.unlocked ?? pp.purchase } else { enabled = false }

            detailField.text = noSelectionString
            priceField.text = ""
        }
    }
}

