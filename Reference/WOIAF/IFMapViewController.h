//
//  IFMapViewController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFPinView.h"


@class Map;
@class IFRootViewController;

@interface IFMapViewController : UIViewController <UIScrollViewDelegate, IFPinViewDelegate> {
    
    // Views we're controlling
    __weak IBOutlet UIScrollView    *scrollView;
    __weak IBOutlet UIImageView     *mapView;
    __weak IBOutlet UIView          *multiLocationView;
    
    __weak IBOutlet UITableView     *tableView;
}

// Operations
- (void)loadMap:(Map *)map;

// Actions
- (IBAction)hideMultipinOverlay:(id)sender;

@property (weak, nonatomic) IFRootViewController *rootViewController;

@property (assign, nonatomic) CGPoint mapOrigin;

@end
