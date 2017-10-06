//
//  IFSpoilerViewController.m
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFSpoilerViewController.h"
#import "IFRootViewController.h"
#import "IFAppStoreController.h"
#import "IFCoreDataStore.h"


@interface SKProduct (FormattedPrice)

@property (readonly) NSString *priceString;

@end


@implementation SKProduct (FormattedPrice)

- (NSString *)priceString {
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.locale = self.priceLocale;

    return [numberFormatter stringFromNumber:self.price];
}

@end


@interface IFSpoilerViewController ()

- (void)alterSpoilerButtonSelections:(NSUInteger)selectionLevel;

- (void)showProductPageForProductID:(NSInteger)productID;

@end

@implementation IFSpoilerViewController {
    
    BOOL                            iPhone;
    
    // Main view states
    CGPoint                         spoilerViewCentres[3];
    
    // Purchase view states
    CGPoint                         purchaseViewCentre[2];
    unsigned                        purchaseViewState;
    
    // State control
    enum { hidden, shown, grown }   state;
    BOOL                            stateTransition;
    
    // Purchase related
    IFAppStoreController            *appStoreController;
    NSArray                         *purchasesArray;
    NSArray                         *validProducts;
    int                             purchasePage;
    BOOL                            foundPurchases;
    BOOL                            lookingForPurchases;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialise in-app purchase as soon as possible
    appStoreController = [IFAppStoreController new];
    [appStoreController registerForAppStoreNotifications:self];
    
    // Are we on an iPhone?
    iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    
    // Initialise members
    foundPurchases = NO;
    lookingForPurchases = NO;
    
    // Initialise positioning centres
    const CGFloat x = self.rootViewController.view.bounds.size.width * 0.5;
    const CGFloat rootViewHeight = self.rootViewController.view.bounds.size.height;
    const CGFloat spoilerViewCentre = self.view.frame.size.height * 0.5;
    const CGFloat kIFSpoilerHeaderHeight = 74;
    
    spoilerViewCentres[hidden] = CGPointMake(x, rootViewHeight + spoilerViewCentre);
    spoilerViewCentres[shown]  = CGPointMake(x, spoilerViewCentres[hidden].y - kIFSpoilerHeaderHeight);
    spoilerViewCentres[grown]  = CGPointMake(x, rootViewHeight - spoilerViewCentre);
    
    // Spoiler view is initially in 'shown' state
    self.view.center = spoilerViewCentres[shown];
    state = shown;
    
    // Set up book spoiler slider
    UIImage *sliderThumbImage = [UIImage imageNamed:@"book_selector.png"];
    UIImage *sliderMinimumImage = [[UIImage imageNamed:@"slider_background.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImage *sliderMaximumImage = [[UIImage imageNamed:@"slider_background.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    [bookSlider setMinimumTrackImage:sliderMinimumImage forState:UIControlStateNormal];
    [bookSlider setMaximumTrackImage:sliderMaximumImage forState:UIControlStateNormal];
    [bookSlider setThumbImage:sliderThumbImage forState:UIControlStateNormal];
    [bookSlider setThumbImage:sliderThumbImage forState:UIControlStateHighlighted];
    
    [self adjustSpoilerLevelsAfterPurchase];
    
    // Purchase view positioning centres
    const CGFloat px = self.view.frame.size.width * 0.5;
    purchaseViewCentre[hidden] = CGPointMake(px, self.view.frame.size.height + purchaseView.bounds.size.height * 0.5);
    purchaseViewCentre[shown]  = CGPointMake(px, self.view.frame.size.height * 0.5);
    purchaseViewState = hidden;
    
    purchaseView.center = purchaseViewCentre[purchaseViewState];
}

- (void)viewDidUnload {
    
    // Remove us as an observer fro the app store controller
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    appStoreController = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (iPhone) ? (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) : YES;
}

#pragma mark - Actions

- (void)filterButtonTouched:(UIButton *)sender {
    
    [self.rootViewController filterButtonTouched:sender];
}

- (void)hide:(id)sender {
        
    if (state == hidden || stateTransition) return;
    
    // Hide the 'fake' buttons
    peopleButton.hidden = YES;
    housesButton.hidden = YES;
    placesButton.hidden = YES;
    mapsButton.hidden = YES;
    
    // Hide the close button
    closeButton.hidden = YES;
    
    // Animate the view onto the screen
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         stateTransition = YES;
                         
                         // Animate to off-screen position
                         self.view.center = spoilerViewCentres[hidden];
                     }
                     completion:^(BOOL finished) {
                         
                         stateTransition = NO;
                         state = hidden;
                     }];
}

- (void)show:(id)sender {
    
    if (state == shown || stateTransition) return;

    if (purchaseViewState == shown) [self purchaseViewToggle:nil];
    
    [self.rootViewController lightenHomeScreen:(state == grown)];

    // Animate the view onto the screen
    [UIView animateWithDuration:.5
                          delay:0
                        options:(state == hidden) ? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         stateTransition = YES;
                         self.view.center = spoilerViewCentres[shown];
                         closeButton.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         
                         // Show the 'fake' buttons
                         peopleButton.hidden = NO;
                         housesButton.hidden = NO;
                         placesButton.hidden = NO;
                         mapsButton.hidden = NO;
                         
                         // Hide the close button
                         closeButton.hidden = YES;
                         
                         stateTransition = NO;
                         state = shown;
                     }];
}

- (void)grow:(id)sender {
    
    if (state == grown || stateTransition) return;
    
    [self.rootViewController darkenHomeScreen:^(BOOL finished) {} andSearchLogo:YES];
    
    // Select initial condition
    NSUInteger lastBookRead = [IFCoreDataStore defaultDataStore].lastBookRead;
    [bookSlider setValue:lastBookRead animated:NO];
    [self alterSpoilerButtonSelections:lastBookRead];

    // Hide the 'fake' buttons
    peopleButton.hidden = YES;
    housesButton.hidden = YES;
    placesButton.hidden = YES;
    mapsButton.hidden = YES;

    closeButton.hidden = NO;
    closeButton.alpha = 0;

    // Animate the view onto the screen
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         stateTransition = YES;
                         
                         self.view.center = spoilerViewCentres[grown];
                         
                         closeButton.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         
                         closeButton.hidden = NO;
                         
                         stateTransition = NO;
                         state = grown;
                     }];
}

#pragma mark Purchase view

- (IBAction)purchaseViewToggle:(UIView *)sender {
    
    stateTransition = YES;
    
    if (purchaseViewState == hidden) {
        
        static NSString *imageNames[] = { @"popup_gameofthrones.png", @"popup_clashofkings.png", @"popup_stormofswords.png", @"popup_feastforcrows.png", @"popup_dancewithdragons.png" };
                
        purchasePage = sender.tag - 1;
        purchaseViewBackgroundImage.image = [UIImage imageNamed:imageNames[purchasePage]];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{ purchaseView.center = purchaseViewCentre[shown]; }
                         completion:^(BOOL finished) {
                             [self refreshPurchases];
                             purchaseViewCloseButton.hidden = NO;
                             purchaseViewState = shown;
                             stateTransition = NO;
                         }];
        
    } else {
        
        purchaseViewCloseButton.hidden = YES;
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{ purchaseView.center = purchaseViewCentre[hidden]; }
                         completion:^(BOOL finished) { purchaseViewState = hidden; stateTransition = NO; }];
    }
}

- (IBAction)purchase:(UIButton *)sender {
    
    NSInteger buttonTag = sender.tag;
    
    [appStoreController purchase:[purchasesArray objectAtIndex:(buttonTag) ? buttonTag : purchasePage]];
}

- (IBAction)restorePurchases:(id)sender {
    
    [appStoreController restorePurchases];
}

#pragma mark - Store Kit

- (void)showProductPageForProductID:(NSInteger)productID {
        
    SKStoreProductViewController *storeProductViewController = [SKStoreProductViewController new];
    
    if (storeProductViewController) {
        
        // iOS 6
        storeProductViewController.delegate = self;
        
        NSDictionary *product = @{ SKStoreProductParameterITunesItemIdentifier: @(productID)};
        
        [storeProductViewController loadProductWithParameters:product completionBlock:^(BOOL result, NSError *error) {
            
            if (result)
                
                [self presentModalViewController:storeProductViewController animated:YES];
            else {
                
                //product not found, handle appropriately
                NSLog(@"Product ID %d not found", productID);
            }
        }];
        
    } else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-books://itunes.apple.com/book/id%d", productID]]];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UI control methods

- (IBAction)viewGeorgesPageInBookstore:(UIButton *)sender {
    
    // Books 1,2,3,4,5,bundle,graphic novel
    //static unsigned productIDsUK[] = { 410872932, 416722949, 422050872, 422047821, 435202115 };
    //static unsigned productIDsUS[] = { 419935229, 419935303, 419935315, 419935414, 424007351, 558103363, 479756437 };
    
    [self showProductPageForProductID:2067983];
    
}

- (IBAction)bookIconSelected:(UIButton *)sender {
    
    NSInteger bookNumber = sender.tag;
    
    if (bookNumber <= bookSlider.maximumValue) {
        
//        [bookSlider setValue:bookNumber animated:YES];
//        [self alterSpoilerButtonSelections:bookNumber];
//        [IFCoreDataStore defaultDataStore].lastBookRead = bookNumber;
//        self.rootViewController.refreshNeeded = YES;
        
    } else if (bookNumber == bookSlider.maximumValue + 1) {
        
        [self purchaseViewToggle:sender];
        
    } else {
        
        // Books 1,2,3,4,5,bundle,graphic novel
        //static unsigned productIDsUK[] = { 410872932, 416722949, 422050872, 422047821, 435202115 };
        static unsigned productIDsUS[] = { 419935229, 419935303, 419935315, 419935414, 424007351, 558103363, 479756437 };
        [self showProductPageForProductID:productIDsUS[bookNumber - 1]];
    }
    

    /* Bundle info packs GOT, COK, SOS, FFC, DWD, Bundle
     static unsigned addonBundleIDs[] = { 570016365, 570017182, 570020359, 570022519, 570024021, 570024703 };
     [self showProductPageForProductID:addonBundleIDs[bookNumber - 1]];*/
}

- (IBAction)bookSliderChanged:(id)sender {
    
    static int lastSnappedSliderValue = -1;
    float snappedSliderValue = floorf(bookSlider.value);
    
    if (snappedSliderValue != lastSnappedSliderValue) {
        
        [self alterSpoilerButtonSelections:snappedSliderValue];
        [IFCoreDataStore defaultDataStore].lastBookRead = snappedSliderValue;
        self.rootViewController.refreshNeeded = YES;
        
        lastSnappedSliderValue = snappedSliderValue;
    }
}

- (IBAction)bookSliderEndedChanges:(id)sender {
    
    float unsnappedSliderValue = bookSlider.value;
    float snappedSliderValue = roundf(unsnappedSliderValue);
    
    [bookSlider setValue:snappedSliderValue animated:YES];
    
    [self alterSpoilerButtonSelections:snappedSliderValue];
    [IFCoreDataStore defaultDataStore].lastBookRead = snappedSliderValue;
    self.rootViewController.refreshNeeded = YES;
}

#pragma mark Action utility callouts

- (void)refreshPurchases {
    
    lookingForPurchases = YES;
    
    // Get purchase ID numbers from our product plist
    purchasesArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WOIAF-Products" ofType:@"plist"]];
    // Start fetch of product data
    [appStoreController requestProductDataForProductsInArray:purchasesArray];
}

- (void)alterSpoilerButtonSelections:(NSUInteger)selectionLevel {
    
    unsigned lba = [IFCoreDataStore defaultDataStore].lastBookAllowed;
    
    gotButton.enabled = YES;
    cokButton.enabled = (lba > 0);
    sosButton.enabled = (lba > 1);
    ffcButton.enabled = (lba > 2);
    dwdButton.enabled = (lba > 3);
    
    gotButton.selected = (lba == 0);
    cokButton.selected = (lba == 1);
    sosButton.selected = (lba == 2);
    ffcButton.selected = (lba == 3);
    dwdButton.selected = (lba == 4);
}

- (void)adjustSpoilerLevelsAfterPurchase {
    
    static const unsigned int maxBookPoints[] = { 0, 87, 136, 185, 234, 280 };
    unsigned maxBook = [IFCoreDataStore defaultDataStore].lastBookAllowed;
    
    bookSlider.maximumValue = maxBook;
    
    CGRect frame = bookSlider.frame;
    frame.size.width = maxBookPoints[maxBook];
    bookSlider.frame = frame;
    
    bookSliderBackground.image = [UIImage imageNamed:[NSString stringWithFormat:@"book%d.png", maxBook]];
    
    [self alterSpoilerButtonSelections:maxBook];
    
    purchaseAllView.hidden = (maxBook > 0);
}

#pragma mark - App. store notifications

- (void)appStoreControllerFoundProductsNotification:(NSNotification *)notification {
    
    // Save the valid products
    validProducts = [notification.userInfo objectForKey:@"validProducts"];
    
    foundPurchases = YES;
    
    NSString *requiredProductID = [purchasesArray objectAtIndex:purchasePage];
    NSString *dealProductID = [purchasesArray objectAtIndex:5];
    SKProduct *requiredProduct = nil;
    SKProduct *dealProduct = nil;
    
    for (SKProduct *product in validProducts) {
        
        if ([product.productIdentifier compare:requiredProductID] == NSOrderedSame) {
            
            requiredProduct = product;
            break;
        }
    }
    
    for (SKProduct *product in validProducts) {
        
        if ([product.productIdentifier compare:dealProductID] == NSOrderedSame) {
            
            dealProduct = product;
            break;
        }
    }
    
    if (requiredProduct) {
        
        [purchaseViewBuyButton setTitle:requiredProduct.priceString forState:UIControlStateNormal];
        purchaseViewBuyButton.enabled = YES;
        
    } else {
        purchaseViewBuyButton.enabled = NO;
    }
    
    if (dealProduct) {
        
        [dealViewBuyButton setTitle:dealProduct.priceString forState:UIControlStateNormal];
        dealViewBuyButton.enabled = YES;
        
    } else {
        dealViewBuyButton.enabled = NO;
    }
}

- (void)appStoreControllerTransactionSuccess:(NSNotification *)notification {
    
    [[IFCoreDataStore defaultDataStore] refreshBookLimits];
    
    // Deal with views
    if (purchaseViewState == shown) [self purchaseViewToggle:nil];
    [self adjustSpoilerLevelsAfterPurchase];
    
    // Error!
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase success."
                                                    message:@"Your purchase was successful and the new content has been activated. Adjust the spoiler levels to reveal your newly purchased content."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
