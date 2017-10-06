//
//  IDMugshotPageViewController.h
//  iDispense
//
//  Created by Richard Henry on 04/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDMugshotCaptureController.h"


//
//  interface IDMugshotPageViewController
//
//  Page view of the mugshot stills and movies that is used instead of the collection view when the user focuses in on one mugshot.
//

@interface IDMugshotPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, IDMugshotCaptureDelegate>

@property(nonatomic, assign) NSArray *mugshots;
@property(nonatomic, assign) NSInteger currentIndex;

@property(nonatomic,copy) void (^completionBlock)(NSArray *add, NSArray *rem);

// View controller data
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSInteger)indexOfViewController:(UIViewController *)viewController;

@end
