//
//  IFSpoilerViewController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <StoreKit/StoreKit.h>


@class IFRootViewController;

@interface IFSpoilerViewController : UIViewController <SKStoreProductViewControllerDelegate> {
    
    // Purchase subview
    __weak IBOutlet UIView          *purchaseView;
    __weak IBOutlet UIButton        *purchaseViewCloseButton;
    
    __weak IBOutlet UIButton        *purchaseViewBuyButton;
    __weak IBOutlet UIButton        *dealViewBuyButton;
    
    __weak IBOutlet UIImageView     *purchaseViewBackgroundImage;
    
    // Book selection slider
    __weak IBOutlet UISlider        *bookSlider;
    __weak IBOutlet UIImageView     *bookSliderBackground;
    
    // Book selection graphical buttons
    __weak IBOutlet UIButton        *gotButton;
    __weak IBOutlet UIButton        *cokButton;
    __weak IBOutlet UIButton        *sosButton;
    __weak IBOutlet UIButton        *ffcButton;
    __weak IBOutlet UIButton        *dwdButton;
    
    // Fake category selection buttons
    __weak IBOutlet UIButton        *peopleButton;
    __weak IBOutlet UIButton        *housesButton;
    __weak IBOutlet UIButton        *placesButton;
    __weak IBOutlet UIButton        *mapsButton;
    
    // Close button is swapped with above
    __weak IBOutlet UIButton        *closeButton;
    
    // Purchase all view may need hiding
    __weak IBOutlet UIView          *purchaseAllView;
}

// Actions
- (IBAction)filterButtonTouched:(id)sender;

- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;
- (IBAction)grow:(id)sender;

- (IBAction)bookIconSelected:(UIButton *)sender;

- (IBAction)viewGeorgesPageInBookstore:(id)sender;

- (IBAction)purchaseViewToggle:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)restorePurchases:(id)sender;

@property (weak, nonatomic) IFRootViewController *rootViewController;

@end
