//
//  IFAppStoreController.m
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFAppStoreController.h"

#import "ItemBase.h"

// Define a couple of notifications sent out when the transaction completes
NSString *kIFAppstoreControllerTransactionFailNotification = @"kIFAppstoreControllerTransactionFail";
NSString *kIFAppstoreControllerTransactionSuccessNotification = @"kIFAppstoreControllerTransactionSuccess";


@interface IFAppStoreController ()

@end

@implementation IFAppStoreController {
    
    NSArray         *validProducts, *invalidProducts;
}

- (id)init {
    
    if ((self = [super init])) {
        
        if ([SKPaymentQueue canMakePayments]) {

            // Verification controller delegate
            [VerificationController sharedInstance].delegate = self;
            
            // Restarts any purchases if they were interrupted last time the app was open
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
    }
    
    return self;
}

#pragma mark - Interface

- (void)requestProductDataForProductsInArray:(NSArray *)purchasesArray {
    
    if (purchasesArray && purchasesArray.count) {
        
        // Request the purchases from the app store
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:purchasesArray]];
        request.delegate = self;
        
        [request start];
    }
}

- (void)purchase:(NSString *)productID {
    
    for (SKProduct *product in validProducts) {
        
        if ([productID compare:product.productIdentifier] == NSOrderedSame) {
            
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
            break;
        }
    }
}

- (void)restorePurchases {
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)registerForAppStoreNotifications:(id)observer {
    
    // Found products notification
    SEL selector = @selector(appStoreControllerFoundProductsNotification:);
    if ([observer respondsToSelector:selector])
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"appStoreControllerFoundProducts" object:self];
    
    // Found products notification
    selector = @selector(appStoreControllerPurchasedProduct:);
    if ([observer respondsToSelector:selector])
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"appStoreControllerPurchasedProduct" object:self];
    
    // Transaction succeeded notification
    selector = @selector(appStoreControllerTransactionSuccess:);
    if ([observer respondsToSelector:selector])
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:kIFAppstoreControllerTransactionSuccessNotification object:self];
}

#pragma mark - Transaction state handling

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    
    // Save the transaction receipt to disk
    [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enableContent:(NSString *)productId {
    
    // Enable the purchased feature
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//
// Remove the transaction from the queue and post a notification with the transaction result
//

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = @{ @"transaction" : transaction };
    
    if (wasSuccessful)

        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kIFAppstoreControllerTransactionSuccessNotification object:self userInfo:userInfo];

    else

        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kIFAppstoreControllerTransactionFailNotification object:self userInfo:userInfo];

}

#pragma mark Updated transaction handling

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    // OMG Hax!11!! Verification is required for iOS 5.1
    if ([[VerificationController sharedInstance] verifyPurchase:transaction]) {
        
        [self recordTransaction:transaction];
        [self enableContent:transaction.payment.productIdentifier];
        [self finishTransaction:transaction wasSuccessful:YES];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    // OMG Hax!11!! Verification is required for iOS 5.1
    if ([[VerificationController sharedInstance] verifyPurchase:transaction]) {
        
        [self recordTransaction:transaction.originalTransaction];
        [self enableContent:transaction.originalTransaction.payment.productIdentifier];
        [self finishTransaction:transaction wasSuccessful:YES];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled) {

        // Error!
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase failed"
                                                        message:@"There was an error while processing your purchase"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"App store transaction error %@", transaction.error);
        [self finishTransaction:transaction wasSuccessful:NO];
    
    } else

        // OK, fine: the user just rage-quit (or cancelled) so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - StoreKit delegate conformance
#pragma mark SKProductsRequestDelegate conformance

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    validProducts = response.products;
    invalidProducts = response.invalidProductIdentifiers;
    
    NSDictionary *userInfo = @{ @"validProducts" : response.products, @"invalidProducts" : response.invalidProductIdentifiers };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appStoreControllerFoundProducts" object:self userInfo:userInfo];
}

#pragma mark SKPaymentTransactionObserver conformance

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark IFVerificationControllerDelegate conformance

- (void)transaction:(NSString *)response verifiedWithAppStore:(BOOL)isOK {
    
    NSLog(@"Transaction %@ ver %d", response, isOK);
}

@end
