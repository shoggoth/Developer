//
//  IFSearchViewController.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class IFRootViewController;
@class IFResultFetcher;

@interface IFSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    // Table control subview
    __weak IBOutlet UIView          *tableAndFiltersView;
    __weak IBOutlet UITableView     *tableView;
    
    // Search control subview
    __weak IBOutlet UIButton        *searchLogoButton;
    __weak IBOutlet UISearchBar     *searchBar;
    
    // Item control subview
    __weak IBOutlet UIView          *footerView;
    
    // Item control buttons
    __weak IBOutlet UIButton        *homeButton;
    
    // Filter buttons
    __weak IBOutlet UIButton        *allFilterButton;
    __weak IBOutlet UIButton        *peopleFilterButton;
    __weak IBOutlet UIButton        *housesFilterButton;
    __weak IBOutlet UIButton        *placesFilterButton;
    __weak IBOutlet UIButton        *mapsFilterButton;
    
    // Other buttons
    __weak IBOutlet UIButton        *showLockedButton;
    __weak IBOutlet UIButton        *infoButton;
}

// Actions
- (IBAction)filterButtonTouched:(id)sender;
- (IBAction)homeButtonTouched:(id)sender;
- (IBAction)lockButtonTouched:(id)sender;
- (IBAction)infoButtonTouched:(id)sender;

- (IBAction)hide:(id)sender;
- (IBAction)show:(id)sender;
- (IBAction)offscreen:(id)sender;

- (IBAction)hideFooter:(id)sender;
- (IBAction)showFooter:(id)sender;

@property (weak, nonatomic) IFRootViewController *rootViewController;

// Fetch properties
@property (assign, nonatomic) NSUInteger typeFilter;
@property (assign, nonatomic) NSUInteger bookRead;

// Reload data
- (void)reloadTableData;

// Set the selected filter to be selected
- (void)setFilterButtonAsSelected:(int)tag;

// Setting of search term
- (void)saveFilterSearchTerm;
- (void)clearFilterSearchTerms;

@end
