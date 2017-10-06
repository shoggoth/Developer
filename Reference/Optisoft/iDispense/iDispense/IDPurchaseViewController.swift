//
//  IDPurchaseViewController.swift
//  iDispense
//
//  Created by Richard Henry on 23/08/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import UIKit

class IDPurchaseViewController: UIViewController {

    @IBOutlet var litePurchaseButton: UIButton!
    @IBOutlet var singleUserPurchaseButton: UIButton!
    @IBOutlet var multiUserPurchaseButton: UIButton!

    fileprivate lazy var decorateButton: ((_ button: UIButton) -> Void) = { (button: UIButton) in

        button.layer.borderWidth = 0.8
        button.layer.borderColor = button.isEnabled ? UIColor.red.cgColor : UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5
    }

    // MARK: Lifecycle

    override func viewDidLoad() {

        super.viewDidLoad()

        // Set up the purchase buttons' initial state and register for purchase notifications.
        setupPurchaseButtons()

        litePurchaseButton.setTitle("Purchased", for: .disabled)
        singleUserPurchaseButton.setTitle("Purchased", for: .disabled)
        multiUserPurchaseButton.setTitle("Purchased", for: .disabled)

        NotificationCenter.default.addObserver(self, selector: #selector(IDPurchaseViewController.purchaseTookPlace(_:)), name: NSNotification.Name.IDIAPProductPurchased, object: nil)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Actions

    @IBAction func purchaseButtonPressed(_ button: UIButton) {

        let appStore = IDInAppPurchases.sharedIAPStore()

        switch button.tag {

        case 1: // Purchase Lite
            appStore.purchaseProduct(IDIAPLiteUserProductIdentifier)
            break

        case 2: // Purchase Single
            if appStore.liteUserUnlocked { appStore.purchaseProduct(IDIAPUpgradeFromLiteToSingleUserProductIdentifier) } else { appStore.purchaseProduct(IDIAPSingleUserProductIdentifier) }
            break

        case 3: // Purchase Multi user abilities.
            if appStore.singleUserUnlocked {

                // As an upgrade from the single user licence.
                appStore.purchaseProduct(IDIAPUpgradeFromSingleToMultiUserProductIdentifier)

            } else if appStore.liteUserUnlocked {

                // As an upgrade from the lite user licence.
                appStore.purchaseProduct(IDIAPUpgradeFromLiteToMultiUserProductIdentifier)

            } else { appStore.purchaseProduct(IDIAPMultiUserProductIdentifier) }

            break

        default:break
        }
    }

    // MARK: Purchases

    func setupPurchaseButtons() {

        let appStore = IDInAppPurchases.sharedIAPStore()

        let multiUserPurchased = appStore.multiUserUnlocked
        let singleUserPurchased = multiUserPurchased || appStore.singleUserUnlocked
        let litePurchased = singleUserPurchased || appStore.liteUserUnlocked

        appStore.requestProducts{ (success: Bool, products: [Any]?) in

            if let products = products as? [SKProduct] {

                let productPriceString: (_ product: SKProduct) -> String = { (product: SKProduct) in return NumberFormatter.localizedString(from: product.price, number: .currency) }

                for product in products {

                    switch product.productIdentifier {

                    case IDIAPLiteUserProductIdentifier:

                        if !litePurchased { self.litePurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    case IDIAPSingleUserProductIdentifier:

                        if !singleUserPurchased && !litePurchased { self.singleUserPurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    case IDIAPMultiUserProductIdentifier:

                        if !multiUserPurchased && !singleUserPurchased && !litePurchased { self.multiUserPurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    case IDIAPUpgradeFromLiteToMultiUserProductIdentifier:

                        if !multiUserPurchased && !singleUserPurchased && litePurchased { self.multiUserPurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    case IDIAPUpgradeFromLiteToSingleUserProductIdentifier:

                        if !singleUserPurchased && litePurchased { self.singleUserPurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    case IDIAPUpgradeFromSingleToMultiUserProductIdentifier:

                        if !multiUserPurchased && singleUserPurchased { self.multiUserPurchaseButton.setTitle(productPriceString(product), for: UIControlState()) }
                        break
                        
                    default:break
                    }
                }
            }
        }

        // Set up purchase controls
        litePurchaseButton.isEnabled = !litePurchased
        singleUserPurchaseButton.isEnabled = !singleUserPurchased
        multiUserPurchaseButton.isEnabled = !multiUserPurchased

        // Apply control decorations.
        decorateButton(litePurchaseButton)
        decorateButton(singleUserPurchaseButton)
        decorateButton(multiUserPurchaseButton)
    }

    func purchaseTookPlace(_ note: Notification) {

        setupPurchaseButtons()
    }
}
