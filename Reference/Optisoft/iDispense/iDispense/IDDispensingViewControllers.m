//
//  IDDispensingViewControllers.m
//  iDispense
//
//  Created by Richard Henry on 08/12/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDDispensingViewControllers.h"
#import "IDDispensingDataStore.h"

#pragma mark Master

@implementation IDDispensingMasterViewController {

    // Table parameters
    CGFloat                             standardRowHeight;

    // Table data
    BOOL                                objectContextTrackingDisabled;
}

#pragma mark Lifecycle

- (instancetype)init {

    // Call the table view controller's designated initialiser.
    // Make sure that we always have a plain style no matter how the initialisation is done.
    return [super initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {

    return [self init];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    // Defaults
    objectContextTrackingDisabled = NO;

    // Initial keyboard type
    self.searchDisplayController.searchBar.keyboardType = [self keyboardTypeForSearchScope:0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // Remember the standard row height
    standardRowHeight = self.tableView.rowHeight;

    // Set up the data store TODO: Remove
    [[IDDispensingDataStore defaultDataStore] createDefaultDataSet];

    // Set up the data fetcher
    _dataFetcher = [IDRecordFetcher new];
    _dataFetcher.entityName = @"Order";
    _dataFetcher.sortingDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"sortingValue" ascending:YES]];
    _dataFetcher.fetchedResultsController.delegate = self;

    // Fetch initial data
    [_dataFetcher fetch];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    // Reload the table data in case another view controller has changed one of the order's contents.
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark Cell operations

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    [NSException raise:@"Missing Override" format:@"Override - configureCell:atIndexPath: to cofigure cell."];

    return nil;
}

#pragma mark Table utility

- (void)scrollToBottom {

    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];

}
#pragma mark UITableView overrides

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];

    // Disable the add button while we're doing the edits.
    self.addButton.enabled = !editing;
}

#pragma mark Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // The number of sections can be got from the fetched results controller.
    return _dataFetcher.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // The number of items in the section can also be gotten from the fetched results controller.
    id <NSFetchedResultsSectionInfo> sectionInfo = [_dataFetcher.fetchedResultsController.sections objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell  = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];

    // Configure the cell with the order data
    return [self configureCell:cell atIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    // Set the tracking to disabled so that the fetcher doesn't try to delete the rows again.
    objectContextTrackingDisabled = YES;

    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Delete the object from the data source
        [[IDDispensingDataStore defaultDataStore] deleteObject:[_dataFetcher.fetchedResultsController objectAtIndexPath:indexPath]];

        // Remove the row from the table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

        // Create a new instance of the appropriate class and add a new row to the table view.
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    // Save and reenable tracking of the object model.
    [[IDDispensingDataStore defaultDataStore] save];

    objectContextTrackingDisabled = NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

    const NSInteger toIndex = toIndexPath.row;
    const NSInteger fromIndex = fromIndexPath.row;

    if (fromIndex != toIndex) {

        double lowerBound, upperBound;

        if (!toIndex) upperBound = 0;

        else {

            NSInteger   upperOffset = (toIndex > fromIndex) ? 0 : 1;
            Order       *order = [_dataFetcher.fetchedResultsController.fetchedObjects objectAtIndex:toIndex - upperOffset];

            upperBound = order.sortingValue;
        }

        if (toIndex == _dataFetcher.fetchedResultsController.fetchedObjects.count - 1) {

            Order *order = [_dataFetcher.fetchedResultsController.fetchedObjects objectAtIndex:toIndex];

            lowerBound = order.sortingValue + [IDDispensingDataStore defaultDataStore].incrementMultiplier * 2;

        } else {

            NSInteger lowerOffset = (toIndex > fromIndex) ? 1 : 0;
            Order *order = [_dataFetcher.fetchedResultsController.fetchedObjects objectAtIndex:toIndex + lowerOffset];

            lowerBound = order.sortingValue;
        }

        // Do the moving of the order
        Order *orderToMove = [_dataFetcher.fetchedResultsController.fetchedObjects objectAtIndex:fromIndex];

        orderToMove.sortingValue = (lowerBound + upperBound) * 0.5;

        // Set the tracking to disabled so that the fetcher doesn't try to delete the rows again.
        objectContextTrackingDisabled = YES;

        // Save and reenable tracking of the object model.
        [[IDDispensingDataStore defaultDataStore] save];

        objectContextTrackingDisabled = NO;
    }
}

#pragma mark UISearchDisplayDelegate conformance

- (UIKeyboardType)keyboardTypeForSearchScope:(NSInteger)scope {

    return UIKeyboardTypeDefault;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {

    switch (selectedScope) {

        case 0:
            searchBar.keyboardType = UIKeyboardTypeNumberPad;
            break;

        default:
            searchBar.keyboardType = UIKeyboardTypeDefault;
            break;
    }

    // Hack: force ui to reflect changed keyboard type
    [searchBar resignFirstResponder];
    [searchBar becomeFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {

    // Match the search result row height to the height of the original table view (the non-filtered version)
    tableView.rowHeight = standardRowHeight;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    _dataFetcher.predicate = [self predicateForSearchMode:controller.searchBar.selectedScopeButtonIndex withString:searchString];

    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {

    _dataFetcher.predicate = [self predicateForSearchMode:searchOption withString:controller.searchBar.text];

    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {

    _dataFetcher.predicate = nil;
}

- (NSPredicate *)predicateForSearchMode:(NSInteger)mode withString:(NSString *)searchString {

    return nil;
}

#pragma mark NSFetchedResultsControllerDelegate conformance

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    // Make sure that user-initiated modifications to the database don't affect the state of the table.
    if (objectContextTrackingDisabled) return;

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    // Make sure that user-initiated modifications to the database don't affect the state of the table.
    if (objectContextTrackingDisabled) return;

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    // Make sure that user-initiated modifications to the database don't affect the state of the table.
    if (objectContextTrackingDisabled) return;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            NSLog(@"Warning: Unknown change type %lu", type);
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // Make sure that user-initiated modifications to the database don't affect the state of the table.
    if (objectContextTrackingDisabled) return;
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end

#pragma mark - Detail

@interface IDDispensingDetailViewController ()

@end

@implementation IDDispensingDetailViewController

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    // Clear selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
}

@end

