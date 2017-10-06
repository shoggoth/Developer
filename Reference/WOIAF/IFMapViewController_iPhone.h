//
//  IFMapViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFPinView.h"

@class Map;
@class IFRootViewController_iPhone;

@interface IFMapViewController_iPhone : UIViewController <UIScrollViewDelegate, IFPinViewDelegate> {
    
    // Views we're controlling
    __weak IBOutlet UIScrollView    *scrollView;
    __weak IBOutlet UIImageView     *mapView;
    __weak IBOutlet UIView          *multiLocationView;
    
    __weak IBOutlet UITableView     *tableView;
    
    __weak IBOutlet UIView          *lockedView;
}

// Operations
- (void)loadMap:(Map *)map;

@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;

@property (assign, nonatomic) CGPoint mapOrigin;

@end
