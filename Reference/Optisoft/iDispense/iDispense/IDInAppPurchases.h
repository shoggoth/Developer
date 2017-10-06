//
//  IDInAppPurchases.h
//  iDispense
//
//  Created by Richard Henry on 02/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

@import Foundation;
@import StoreKit;

typedef void (^IDProductRequestCompletionBlock)(BOOL success,  NSArray *__nullable products);

extern NSString *__nonnull IDIAPProductPurchasedNotification;

extern NSString *__nonnull IDIAPLiteUserProductIdentifier;
extern NSString *__nonnull IDIAPSingleUserProductIdentifier;
extern NSString *__nonnull IDIAPMultiUserProductIdentifier;

extern NSString *__nonnull IDIAPUpgradeFromLiteToMultiUserProductIdentifier;
extern NSString *__nonnull IDIAPUpgradeFromLiteToSingleUserProductIdentifier;
extern NSString *__nonnull IDIAPUpgradeFromSingleToMultiUserProductIdentifier;

//
//  interface IDInAppPurchases
//
//  Convenience functions for IAP and wrapper for disclosure of purchased features.
//

@interface IDInAppPurchases : NSObject <SKPaymentTransactionObserver>

+ (nonnull instancetype)sharedIAPStore;

// These are used for checking if features are available.
@property(nonatomic, readonly) BOOL liteUserUnlocked;
@property(nonatomic, readonly) BOOL singleUserUnlocked;
@property(nonatomic, readonly) BOOL multiUserUnlocked;

// Purchasing
- (void)purchaseProduct:(NSString *__nullable)productID;
- (void)restorePurchases;

// Purchase Info
- (void)requestProductsWithCompletionBlock:(nullable IDProductRequestCompletionBlock)completionBlock;
- (BOOL)hasProductBeenPurchased:(NSString *__nonnull)productID;

@end
