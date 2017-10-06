//
//  IFSearchViewController_iPhone.m
//  WOIAF
//
//  Created by Simon Hardie on 06/11/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFSearchViewController_iPhone.h"
#import "IFRootViewController_iPhone.h"
#import "IFLockViewController_iPhone.h"
#import "IFTableViewCell.h"
#import "IFCoreDataStore.h"

#import "Person.h"
#import "Place.h"
#import "House.h"
#import "Map.h"
#import "Fact.h"

#import "ItemBase+LockState.h"

#import <QuartzCore/QuartzCore.h>

static NSString *kIFSearchViewShowLockedKey = @"ShowLockedKey";

@interface IFSearchViewController_iPhone ()

- (void)showKeyboard;
- (void)hideKeyboard;

@end

@implementation IFSearchViewController_iPhone  {
    
    // Main view states
    CGPoint                         searchViewCentres[3];
    
    float   centreYDiffs[3];
    
    // State control
    enum { hidden, shown, offscreen } state/*, footerState*/;
    BOOL                        stateTransition;
    
    // Result fetching
    IFResultFetcher             *fetcher;
    NSTimer                     *searchTextTimer;
    
    // Lock subview
    IFLockViewController_iPhone            *lockViewController;
    
    // Table view resizing
    CGFloat                     tableViewHeight;
    
    // Search strings for each category
    NSMutableArray              *searchStrings;
    
    BOOL                        showLocked;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    state = hidden;
    
    centreYDiffs[shown] = 0.0f;
    centreYDiffs[hidden] = self.view.bounds.size.height - 116.0f;
    centreYDiffs[offscreen] = self.view.bounds.size.height;
    
    state = shown;
    
    // Lock view controller
    if (!lockViewController) {
        
        lockViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"lock"];
        lockViewController.rootViewController = self.rootViewController;
        
        // Add the view as a subview if we haven't already
        if (lockViewController.view.superview != self.view) [self.view addSubview:lockViewController.view];
        
        lockViewController.view.center = lockedView.center;
    }


    // Storage for search strings
    searchStrings = [NSMutableArray array];
    [self clearFilterSearchTerms];
    
    // Fetch all initially, with just spoiler control
    self.typeFilter = 0;
    [self reloadTableData];
    
    // Table view height adjust
    tableViewHeight = tableView.frame.size.height;
    
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
    
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
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
    
    [self hide:nil];
    
    [self.rootViewController showInfoViewController:sender];
    [self.rootViewController darkenHomeScreen:^(BOOL finished) {}];
}

- (IBAction)bookmarksButtonTouched:(id)sender {
    
}

- (void) initialHide {
    searchBar.hidden = YES;
    
    self.view.superview.center = CGPointMake(self.view.superview.center.x, self.view.superview.center.y + centreYDiffs[hidden]);

    state = hidden;
}


#pragma mark - Animation

- (void)hide:(id)sender {
    
    if (state == hidden || stateTransition) return;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         
                         searchBar.hidden = YES;
                         
                         self.view.superview.center = CGPointMake(self.view.superview.center.x, self.view.superview.center.y + centreYDiffs[hidden]);
                     }
                     completion:^(BOOL finished) {
                         
                         state = hidden;
                     }];
}

- (void)show:(id)sender {
    
    if (state == shown || stateTransition) return;
    
    [UIView animateWithDuration:.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{

                         self.view.superview.center = CGPointMake(self.view.superview.center.x, self.view.superview.center.y - centreYDiffs[hidden]);
                     }
                     completion:^(BOOL finished) {
                         
                         searchBar.hidden = NO;
                         state = shown;
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
    
    if (![self.rootViewController showLockViewControllerForItem:item]) {
        
        [self.rootViewController itemSelected:item];
        // Add the item to the history
        [[IFCoreDataStore defaultDataStore] addItemToHistory:item];
    }
}

#pragma mark UISearchBarDelegate conformance

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [searchStrings setObject:searchText atIndexedSubscript:self.typeFilter];
    
    // Search timer on table reload (to reduce query count)
    [searchTextTimer invalidate]; searchTextTimer = nil;
    searchTextTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reloadTableData) userInfo:nil repeats:NO];
}

/*- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [self hideKeyboard];
}*/

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar { [self hideKeyboard]; }

#pragma mark - Refresh

- (void)reloadTableData {
    
    static NSString *typeFilters[] = { @"ItemBase", @"Person", @"House", @"Place", @"Map" };
    
    fetcher = [IFResultFetcher new];
    
    fetcher.bookRead = (showLocked) ? 23 : [IFCoreDataStore defaultDataStore].lastBookRead;
    fetcher.entityName = typeFilters[self.typeFilter];
    fetcher.searchString = [searchStrings objectAtIndex:self.typeFilter];
    
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

- (void)showKeyboard {
    
    NSLog(@"Keyboard showing");
    searchBar.text = searchBar.text = [searchStrings objectAtIndex:self.typeFilter];
}

- (void)hideKeyboard {
    
    NSLog(@"Keyboard hiding");
    
    //[searchStrings setObject:searchBar.text atIndexedSubscript:self.typeFilter];
    [searchBar resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    // Register for keyboard hide notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect hiddenFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    //CGRect shownFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //const CGFloat keyboardHeight = hiddenFrame.origin.x - shownFrame.origin.x;
    
    const CGFloat keyboardHeight = hiddenFrame.size.height - 44.0f;
    
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
                         
                         tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableViewHeight);
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
