//
//  IFAppStoreController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "VerificationController.h"


extern NSString *kIFAppstoreControllerTransactionFailNotification;
extern NSString *kIFAppstoreControllerTransactionSuccessNotification;


@interface IFAppStoreController : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, IFVerificationControllerDelegate>

- (void)requestProductDataForProductsInArray:(NSArray *)purchasesArray;
- (void)purchase:(NSString *)productID;
- (void)restorePurchases;

- (void)registerForAppStoreNotifications:(id)obj;

@end
