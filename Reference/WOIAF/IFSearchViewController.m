//
//  IFSearchViewController.m
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFSearchViewController.h"
#import "IFRootViewController.h"
#import "IFTableViewCell.h"
#import "IFCoreDataStore.h"

#import "Person.h"
#import "Place.h"
#import "House.h"
#import "Map.h"
#import "Fact.h"

#import "ItemBase+LockState.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat kIFSearchLogoButtonOffset = 254;
static CGFloat kIFTableAndFiltersViewOffset = 624;

static NSString *kIFSearchViewShowLockedKey = @"ShowLockedKey";


@interface IFSearchViewController ()

- (void)showKeyboard;
- (void)hideKeyboard;

@end

@implementation IFSearchViewController  {
    
    BOOL                        iPhone;
    
    // State control
    enum { hidden, shown, off } state, footerState;
    BOOL                        stateTransition;
    
    // Result fetching
    IFResultFetcher             *fetcher;
    NSTimer                     *searchTextTimer;
    
    // Centers of subViews
    CGPoint                     logoButtonShownCentre, tableAndFiltersViewShownCentre, infoButtonShownCentre;
    CGPoint                     logoButtonHiddenCentre, tableAndFiltersViewHiddenCentre, infoButtonHiddenCentre;
    CGPoint                     logoButtonOffScreenCentre, tableAndFiltersViewOffScreenCentre;
    
    // Table view resizing
    CGFloat                     tableViewHeight, footerViewHeight;
    
    // Search strings for each category
    NSMutableArray              *searchStrings;
    
    BOOL                        showLocked;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Are we on an iPhone?
    iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    
    const CGRect thisViewFrame = self.view.frame;
    const CGRect rootViewFrame = self.rootViewController.view.frame;
    const float  xCentre = rootViewFrame.size.width * 0.5 - thisViewFrame.size.width * 0.5;
    
    // Centre our view in the superview's frame
    self.view.frame = CGRectApplyAffineTransform(self.view.frame, CGAffineTransformMakeTranslation(xCentre, 0));
    state = hidden;
    
    // Centers of subViews
    logoButtonHiddenCentre = searchLogoButton.center;
    logoButtonShownCentre = CGPointMake(searchLogoButton.center.x, searchLogoButton.center.y - kIFSearchLogoButtonOffset);
    logoButtonOffScreenCentre = CGPointMake(searchLogoButton.center.x, searchLogoButton.center.y - 324);
    tableAndFiltersViewHiddenCentre = tableAndFiltersView.center;
    tableAndFiltersViewShownCentre = CGPointMake(tableAndFiltersView.center.x, tableAndFiltersView.center.y - kIFTableAndFiltersViewOffset);
    tableAndFiltersViewOffScreenCentre = CGPointMake(tableAndFiltersView.center.x, tableAndFiltersView.center.y + 120);
    infoButtonShownCentre = infoButton.center;
    infoButtonHiddenCentre = CGPointMake(infoButtonShownCentre.x, infoButtonShownCentre.y - infoButton.bounds.size.height);
    
    // Storage for search strings
    searchStrings = [NSMutableArray array];
    [self clearFilterSearchTerms];

    // Fetch all initially, with just spoiler control
    self.typeFilter = 0;
    [self reloadTableData];
    
    // Table view height adjust
    tableViewHeight = tableView.frame.size.height;
    footerViewHeight = footerView.frame.size.height;
    
    // Register for keyboard show notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    // Register for application level notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUserDefaults) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreUserDefaults) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    // Remove us as an observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Release any retained subviews of the main view.
    [searchTextTimer invalidate];
    searchTextTimer = nil;
    
    searchStrings = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (iPhone) ? (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) : YES;
}

#pragma mark - Actions

- (void)filterButtonTouched:(UIButton *)sender {

    [self.rootViewController filterButtonTouched:sender];
    [searchBar resignFirstResponder];
}

- (void)homeButtonTouched:(UIButton *)sender {
    
    [self.rootViewController homeButtonTouched:sender];
}

- (IBAction)lockButtonTouched:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    showLocked = sender.selected;
    [self reloadTableData];
}

- (void)infoButtonTouched:(UIButton *)sender {
    
    [self.rootViewController showInfoViewController:sender];
}


#pragma mark - Animation

- (void)hide:(id)sender {
    
    if (state == hidden || stateTransition) return;
    
    [self hideKeyboard];
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         searchBar.hidden = YES;
                         
                         searchLogoButton.center = logoButtonHiddenCentre;
                         tableAndFiltersView.center = tableAndFiltersViewHiddenCentre;
                         infoButton.center = infoButtonShownCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         infoButton.userInteractionEnabled = YES;
                         state = hidden;
                     }];
}

- (void)show:(id)sender {
    
    if (state == shown || stateTransition) return;
    
    infoButton.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         searchLogoButton.center =  logoButtonShownCentre;
                         tableAndFiltersView.center = tableAndFiltersViewShownCentre;
                         infoButton.center = infoButtonHiddenCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         searchBar.hidden = NO;
                         state = shown;
                     }];
}

- (void)offscreen:(id)sender {
    
    if (state == off || stateTransition) return;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         searchLogoButton.center =  logoButtonOffScreenCentre;
                         tableAndFiltersView.center = tableAndFiltersViewOffScreenCentre;
                     }
                     completion:^(BOOL finished) {
                         
                         searchBar.hidden = YES;
                         state = off;
                     }];
}

- (void)hideFooter:(id)sender {
    
    if (footerState == hidden) return;
    
    // Animate the footer view off the screen
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                                                  
                         // Animate to off-screen position
                         footerView.center = CGPointMake(160 + 57, 768 + 23);
                         
                         // MF - Increase the height of the tableView
                         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableViewHeight);
                     }
                     completion:^(BOOL finished) { footerState = hidden; }];
}

- (void)showFooter:(id)sender {
    
    if (footerState == shown) return;
    
    // Animate the view onto the screen
    [UIView animateWithDuration:.5
                          delay:0
                        options:(footerState == hidden) ? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn
                     animations:^{
                        
                         footerView.center = CGPointMake(160 + 57, 768 - 23);
                     }
                     completion:^(BOOL finished) {
                         
                         footerState = shown;
                         
                         // MF - Reduce the height of the tableView
                         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableViewHeight - footerViewHeight);
                     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {

    // Fetched results controller will provide the number of rows in the section
    if ([fetcher.fetchedResultsController.sections count]) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [fetcher.fetchedResultsController.sections objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
        
    } else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifiers[] = { @"IFTableViewCell-1", @"IFTableViewCell-2", @"IFTableViewCell-3", @"IFTableViewCell-4" };
    
    IFTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifiers[indexPath.row % 4]];
    ItemBase *itemBase = [fetcher.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = itemBase.name;
    
    UIImage *thumbImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tumbnail.png", itemBase.uid]];
    
    // If there's no thumbnail image associated with the item's uid, bung in a default…
    if (!thumbImage) thumbImage = getDefaultThumbImageForItem(itemBase);
    
    // Set up images
    cell.imageView.image = thumbImage;
    
    NSString *cellBackgroundImageName;
    
    if (itemBase.isPurchaseLocked) cellBackgroundImageName = @"_locked";
    else if (itemBase.isSpoilerLocked) cellBackgroundImageName = @"_spoil";
    else cellBackgroundImageName = @"";
    
    ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:[NSString stringWithFormat:@"listbackground%@_%d.png", cellBackgroundImageName, cell.tag]];

    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Unselect immediately
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // Inform the root VC that an item's been selected from the list
    ItemBase *item = [fetcher.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self hideKeyboard];
    
    if (![self.rootViewController showLockViewControllerForItem:item]) {
        
        [self.rootViewController itemSelected:item];
        // Add the item to the history
        [[IFCoreDataStore defaultDataStore] addItemToHistory:item];
    }
}

#pragma mark UISearchBarDelegate conformance

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText {
        
    [searchStrings setObject:searchText atIndexedSubscript:self.typeFilter];
    
    // Search timer on table reload (to reduce query count)
    [searchTextTimer invalidate]; searchTextTimer = nil;
    searchTextTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reloadTableData) userInfo:nil repeats:NO];
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar { [self hideKeyboard]; }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { [self hideKeyboard]; }

#pragma mark - Refresh

- (void)reloadTableData {
    
    static NSString *typeFilters[] = { @"ItemBase", @"Person", @"House", @"Place", @"Map" };
    
    fetcher = [IFResultFetcher new];
    
    // Configure the fetch query
    fetcher.bookRead = (showLocked) ? 23 : [IFCoreDataStore defaultDataStore].lastBookRead;
    fetcher.entityName = typeFilters[self.typeFilter];
    fetcher.searchString = [searchStrings objectAtIndex:self.typeFilter];

    // Refresh table with the data
    [fetcher fetch];
    [tableView reloadData];
}

#pragma mark - Setting for UI

- (void)setFilterButtonAsSelected:(int)tag {
    
    tag == allFilterButton.tag ? [allFilterButton setSelected:YES] : [allFilterButton setSelected:NO];
    tag == peopleFilterButton.tag ? [peopleFilterButton setSelected:YES] : [peopleFilterButton setSelected:NO];
    tag == housesFilterButton.tag ? [housesFilterButton setSelected:YES] : [housesFilterButton setSelected:NO];
    tag == placesFilterButton.tag ? [placesFilterButton setSelected:YES] : [placesFilterButton setSelected:NO];
    tag == mapsFilterButton.tag ? [mapsFilterButton setSelected:YES] : [mapsFilterButton setSelected:NO];
    
    if (allFilterButton.tag == tag) [allFilterButton setSelected:YES];
}

- (void)saveFilterSearchTerm {
    
    searchBar.text = [searchStrings objectAtIndex:self.typeFilter];
}

- (void)clearFilterSearchTerms {
    
    searchBar.text = @"";
    for (int i = 0; i < 5; i++) [searchStrings setObject:@"" atIndexedSubscript:i];
}

#pragma mark Keyboard handling

- (void)showKeyboard { searchBar.text = [searchStrings objectAtIndex:self.typeFilter]; }

- (void)hideKeyboard { [searchBar resignFirstResponder]; }

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // Register for keyboard hide notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect hiddenFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect shownFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    const CGFloat keyboardHeight = hiddenFrame.origin.x - shownFrame.origin.x;    
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationCurve
                     animations:^{
                         
                         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableViewHeight - keyboardHeight);
                     }
                     completion:^(BOOL finished) {}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Register for keyboard show notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationCurve
                     animations:^{
                         
                         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, (footerState == shown) ? tableViewHeight - footerViewHeight : tableViewHeight);
                     }
                     completion:^(BOOL finished) {}];
}

#pragma mark - User default

- (void)saveUserDefaults {
    
    // Search view controller
    [[NSUserDefaults standardUserDefaults] setBool:showLocked forKey:kIFSearchViewShowLockedKey];
}

- (void)restoreUserDefaults {
    
    // Search view controller
    showLocked = [[[NSUserDefaults standardUserDefaults] objectForKey:kIFSearchViewShowLockedKey] boolValue];
    showLockedButton.selected = showLocked;
    [self reloadTableData];
}


@end
