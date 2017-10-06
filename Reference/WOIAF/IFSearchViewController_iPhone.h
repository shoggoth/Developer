//
//  IFSearchViewController_iPhone.h
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IFRootViewController_iPhone;
@class IFResultFetcher;

@interface IFSearchViewController_iPhone : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    // Table control subview
    __weak IBOutlet UIView          *tableAndFiltersView;
    __weak IBOutlet UITableView     *tableView;
    
    // Search control subview
    __weak IBOutlet UISearchBar     *searchBar;
    
    // Item control subview
    __weak IBOutlet UIView          *footerView;
    
    // Item control buttons
    __weak IBOutlet UIButton        *homeButton;
    __weak IBOutlet UIButton        *bookmarksButton;
    
    // Filter buttons
    __weak IBOutlet UIButton        *allFilterButton;
    __weak IBOutlet UIButton        *peopleFilterButton;
    __weak IBOutlet UIButton        *housesFilterButton;
    __weak IBOutlet UIButton        *placesFilterButton;
    __weak IBOutlet UIButton        *mapsFilterButton;
    
    // Other buttons
    __weak IBOutlet UIButton        *showLockedButton;
    __weak IBOutlet UIButton        *infoButton;
    
    __weak IBOutlet UIView          *lockedView;
}

// Actions
- (IBAction)filterButtonTouched:(id)sender;
- (IBAction)homeButtonTouched:(id)sender;
- (IBAction)bookmarksButtonTouched:(id)sender;
- (IBAction)lockButtonTouched:(id)sender;
- (IBAction)infoButtonTouched:(id)sender;

- (IBAction)hide:(id)sender;

- (void) initialHide;

- (IBAction)show:(id)sender;

@property (weak, nonatomic) IFRootViewController_iPhone *rootViewController;

// Fetch properties
@property (assign, nonatomic) NSUInteger typeFilter;
@property (assign, nonatomic) NSUInteger bookRead;

@property (copy, nonatomic)   NSString   *searchString;

// Reload data
- (void)reloadTableData;

// Set the selected filter to be selected
- (void)setFilterButtonAsSelected:(int)tag;

// Setting of search term
- (void)saveFilterSearchTerm;
- (void)clearFilterSearchTerms;

@end

