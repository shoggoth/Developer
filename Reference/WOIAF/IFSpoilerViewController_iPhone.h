//
//  IFSpoilerViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class IFRootViewController_iPhone;

@interface IFSpoilerViewController_iPhone : UIViewController <SKStoreProductViewControllerDelegate> {
    
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
    __weak IBOutlet UIButton        *restorePurchasesButton;
    
    // Labels with custom fonts
    __weak IBOutlet UILabel         *spoilerTitleLabel;
    
    // Purchase all view may need hiding
    __weak IBOutlet UIView          *purchaseAllView;
}

// Actions
- (IBAction)filterButtonTouched:(id)sender;

- (void) initialHide;

- (IBAction)hidden:(id)sender;
- (IBAction)shown:(id)sender;
- (IBAction)offscreen:(id)sender;

- (IBAction)bookIconSelected:(UIButton *)sender;

- (IBAction)viewGeorgesPageInBookstore:(id)sender;

- (IBAction)purchaseViewToggle:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)restorePurchases:(id)sender;

@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;

@end
