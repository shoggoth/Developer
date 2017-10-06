//
//  UIHelpers.swift
//  iDispense
//
//  Created by Richard Henry on 16/09/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

import UIKit

extension UITextField {

    var decimalNumber: NSDecimalNumber {

        get {

            var decimal = NSDecimalNumber.zero

            if let text = self.text {

                let sanitisedNumber: (_ num: NSDecimalNumber) -> NSDecimalNumber = { (num: NSDecimalNumber) in return (num.isEqual(to: NSDecimalNumber.notANumber)) ? NSDecimalNumber.zero : num }

                if (!text.isEmpty) { decimal = sanitisedNumber(NSDecimalNumber(string: text)) }
            }

            return decimal
        }

        set {
            if newValue == NSDecimalNumber.zero { self.text = "" }

            else {
                let numberFormatter = NumberFormatter()

                numberFormatter.numberStyle = .currency
                numberFormatter.currencySymbol = ""
                numberFormatter.locale = Locale.current
                
                self.text = numberFormatter.string(from: newValue)
            }
        }
    }
}
