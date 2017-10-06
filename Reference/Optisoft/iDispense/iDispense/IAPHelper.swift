//
//  IAPHelper.swift
//  iDispense
//
//  Created by Richard Henry on 14/01/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

import StoreKit

// Product identifiers are unique strings registered on the app store.
public typealias ProductIdentifier = String

// Completion handler called when products are fetched.
public typealias IAPHelperRequestProductsCompletionBlock = (success: Bool, products: [SKProduct]) -> ()

public class IAPHelper : NSObject  {

    // Notification that is generated when a product is purchased.
    public static let productPurchasedNotification = "IAPHelperProductPurchasedNotification"
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()

    // Used by SKProductsRequestDelegate
    private var productsRequest: SKProductsRequest?
    private var completionHandler: IAPHelperRequestProductsCompletionBlock?

    public init(productIdentifiers: Set<ProductIdentifier>) {

        // Set up the product identifiers
        self.productIdentifiers = productIdentifiers
        for productIdentifier in productIdentifiers {

            guard NSUserDefaults.standardUserDefaults().boolForKey(productIdentifier) else { continue }
            purchasedProductIdentifiers.insert(productIdentifier)
        }

        super.init()

        // Add ourselves as an observer to app store transactions
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }

    // Gets the list of SKProducts from the Apple server and calls the handler with the list of products.
    public func requestProductsWithCompletionHandler(handler: IAPHelperRequestProductsCompletionBlock) {

        completionHandler = handler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    // Initiates purchase of a product.

    public func purchaseProduct(product: ProductIdentifier) {

        self.requestProductsWithCompletionHandler { success, products in

            if success {

                // Print out the products
                for p in products where p.productIdentifier == product {

                    let payment = SKPayment(product: p)
                    SKPaymentQueue.defaultQueue().addPayment(payment)
                }
            }
        }
    }

    // Given the product identifier, returns true if that product has been purchased.
    public func isProductPurchased(productIdentifier: ProductIdentifier) -> Bool {

        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    // If the state of whether purchases have been made is lost  (e.g. the
    // user deletes and reinstalls the app) this will recover the purchases.
    public func restoreCompletedTransactions() {

        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
}

// MARK: - IAPHelper Extensions

extension IAPHelper : SKProductsRequestDelegate, SKPaymentTransactionObserver {

    // MARK: <SKProductsRequestDelegate>

    public func request(request: SKRequest, didFailWithError error: NSError) {

        print("Failed to load list of products.")
        print("Error: \(error)")

        clearRequest()
    }

    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {

        completionHandler?(success: true, products: response.products)
        clearRequest()
    }

    // MARK: <SKPaymentTransactionObserver>

    /// This is a function called by the payment queue, not to be called directly.
    /// For each transaction act accordingly, save in the purchased cache, issue notifications,
    /// mark the transaction as complete.
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {

            switch (transaction.transactionState) {

            case .Purchased: completeTransaction(transaction); break
            case .Failed:    failedTransaction(transaction); break
            case .Restored:  restoreTransaction(transaction); break
            case .Deferred,.Purchasing: break
            }
        }
    }

    private func completeTransaction(transaction: SKPaymentTransaction) {

        print("completeTransaction...")
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }

    private func restoreTransaction(transaction: SKPaymentTransaction) {

        defer { SKPaymentQueue.defaultQueue().finishTransaction(transaction) }

        if let productIdentifier = transaction.originalTransaction?.payment.productIdentifier {

            print("restoreTransaction... \(productIdentifier)")
            provideContentForProductIdentifier(productIdentifier)
        }
    }

    // Helper: Saves the fact that the product has been purchased and posts a notification.
    private func provideContentForProductIdentifier(productIdentifier: ProductIdentifier) {

        purchasedProductIdentifiers.insert(productIdentifier)

        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()

        NSNotificationCenter.defaultCenter().postNotificationName(IAPHelper.productPurchasedNotification, object: productIdentifier)
    }

    private func failedTransaction(transaction: SKPaymentTransaction) {

        defer { SKPaymentQueue.defaultQueue().finishTransaction(transaction) }
        guard let err = transaction.error where err.code == SKErrorPaymentCancelled else { return }

        print("Transaction error: \(err.localizedDescription)")
    }

    // MARK: Utility

    private func clearRequest() {

        productsRequest = nil
        completionHandler = nil
    }
}

// MARK: - IAP Products

public enum IAPProducts : ProductIdentifier {

    case unlockFullVersion, unusedThing

    public static let store = IAPHelper(productIdentifiers: Set(productIdentifiers.map({ appNamePrefix + $0.rawValue })))

    static func isFeatureUnlocked(feature: IAPProducts) -> Bool {

        return NSUserDefaults.standardUserDefaults().boolForKey(appNamePrefix + feature.rawValue)
    }

    static func unlockFeature(feature: IAPProducts) {

        if !isFeatureUnlocked(feature) { store.purchaseProduct(appNamePrefix + feature.rawValue) }
    }

    private static let appNamePrefix = "uk.co.optisoft.iDispense."
    private static let productIdentifiers = [unlockFullVersion]
}
