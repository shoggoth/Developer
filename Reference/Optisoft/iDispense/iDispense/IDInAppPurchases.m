//
//  IDInAppPurchases.m
//  iDispense
//
//  Created by Richard Henry on 02/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "IDInAppPurchases.h"

NSString *IDIAPProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

NSString *IDIAPLiteUserProductIdentifier = @"uk.co.optisoft.iDispense.unlockLiteUser";
NSString *IDIAPSingleUserProductIdentifier = @"uk.co.optisoft.iDispense.unlockSingleUser";
NSString *IDIAPMultiUserProductIdentifier = @"uk.co.optisoft.iDispense.unlockMultiUser";

NSString *IDIAPUpgradeFromLiteToMultiUserProductIdentifier = @"uk.co.optisoft.iDispense.upgradeFromLiteToMultiUser";
NSString *IDIAPUpgradeFromLiteToSingleUserProductIdentifier = @"uk.co.optisoft.iDispense.upgradeFromLiteToSingleUser";
NSString *IDIAPUpgradeFromSingleToMultiUserProductIdentifier = @"uk.co.optisoft.iDispense.upgradeFromSingleToMultiUser";

@interface IDInAppPurchases () <SKProductsRequestDelegate>

@property(nonatomic, nonnull, readonly) NSSet <NSString *> *availableProducts;
@property(nonatomic, nonnull, readonly) NSSet <NSString *> *purchasedProducts;

@end

@implementation IDInAppPurchases {

    IDProductRequestCompletionBlock     requestCompletionBlock;
    SKProductsRequest                   *productsRequest;
    NSMutableSet                        *purchasedProds;
}

+ (instancetype)sharedIAPStore {

    static dispatch_once_t onceToken;
    static IDInAppPurchases *sharedIAPStore;

    dispatch_once(&onceToken, ^{

        sharedIAPStore = [[[self class] alloc] initWithProducts:[NSSet setWithObjects:
                                                                 IDIAPLiteUserProductIdentifier, IDIAPSingleUserProductIdentifier, IDIAPMultiUserProductIdentifier,
                                                                 IDIAPUpgradeFromLiteToMultiUserProductIdentifier, IDIAPUpgradeFromLiteToSingleUserProductIdentifier, IDIAPUpgradeFromSingleToMultiUserProductIdentifier,
                                                                 nil]];
    });

    return sharedIAPStore;
}

- (instancetype)initWithProducts:(NSSet *)products {

    if ((self = [super init])) {

        // Initialisation code here
        purchasedProds = [NSMutableSet set];

        _availableProducts = products;
        _purchasedProducts = purchasedProds;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // See if any of the products have already been purchased.
        for (NSString *productID in products) {

            if ([defaults boolForKey:productID]) [purchasedProds addObject:productID];
        }
    }

    return self;
}

#pragma mark Properties

- (BOOL)liteUserUnlocked {

    return [self hasProductBeenPurchased:IDIAPLiteUserProductIdentifier] || self.singleUserUnlocked;
}

- (BOOL)singleUserUnlocked {

    return [self hasProductBeenPurchased:IDIAPSingleUserProductIdentifier] || [self hasProductBeenPurchased:IDIAPUpgradeFromLiteToSingleUserProductIdentifier] || self.multiUserUnlocked;
}

- (BOOL)multiUserUnlocked {

    // Has we been upgraded from single user?
    BOOL upgraded = [self hasProductBeenPurchased:IDIAPUpgradeFromSingleToMultiUserProductIdentifier];

    // Either the user has purchased the multi user unlock or it's followed a valid upgrade path.
    return upgraded || [self hasProductBeenPurchased:IDIAPMultiUserProductIdentifier];
}

#pragma mark Purchasing

- (void)purchaseProduct:(NSString *)productID {

    if (![purchasedProds containsObject:productID]) {

        [self requestProductsWithCompletionBlock:^(BOOL success, NSArray *products) {

            if (success) for (SKProduct *product in products) {

                if ([product.productIdentifier isEqualToString:productID]) {

                    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
                }
            }
        }];
    }
}

- (void)restorePurchases {

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark Purchase Info

- (void)requestProductsWithCompletionBlock:(IDProductRequestCompletionBlock)completionBlock {

    // Create a store request for the product fetch.
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.availableProducts];

    requestCompletionBlock = completionBlock;
    productsRequest.delegate = self;

    // Start the fetch of the products
    [productsRequest start];
}

- (BOOL)hasProductBeenPurchased:(NSString *)productID {

#if defined(IAP_DISABLED)
#warning In App Purchases are all enabled for the purposes of debugging.
    return YES;
#endif
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:productID];
}

#pragma mark <SKProductsRequestDelegate>

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    if (requestCompletionBlock) requestCompletionBlock(YES, response.products);

    [self clearRequest];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {

    if (requestCompletionBlock) requestCompletionBlock(NO, nil);

    [self clearRequest];
}

#pragma mark <SKPaymentTransactionObserver>

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray <SKPaymentTransaction *> *)transactions {

    for (SKPaymentTransaction *transaction in transactions) {

        switch (transaction.transactionState) {

            case SKPaymentTransactionStateFailed: [self failedTransaction:transaction]; break;

            case SKPaymentTransactionStatePurchased: [self completedTransaction:transaction]; break;

            case SKPaymentTransactionStateRestored: [self restoredTransaction:transaction]; break;

            default: break;
        }
    }
}

#pragma mark Transaction handling

- (void)completedTransaction:(SKPaymentTransaction *)transaction {

    [self provideContentForPurchase:transaction.payment.productIdentifier];

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoredTransaction:(SKPaymentTransaction *)transaction {

    [self provideContentForPurchase:transaction.originalTransaction.payment.productIdentifier];

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {

    if (transaction.error) NSLog(@"Transaction failed %ld %@", (long)transaction.error.code, transaction.error.localizedDescription);

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark Helpers

- (void)provideContentForPurchase:(NSString *)purchaseIdentifier {

    // Add to the set of purchased products.
    [purchasedProds addObject:purchaseIdentifier];

    // Set the user defaults
    NSUserDefaults *standardUserdefaults = [NSUserDefaults standardUserDefaults];
    [standardUserdefaults setBool:YES forKey:purchaseIdentifier];
    [standardUserdefaults synchronize];

    // Notify the interested parties.
    [[NSNotificationCenter defaultCenter] postNotificationName:IDIAPProductPurchasedNotification object:purchaseIdentifier];
}

#pragma mark Private

- (void)clearRequest {

    requestCompletionBlock = nil;
    productsRequest = nil;
}

@end
