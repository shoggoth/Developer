//
//  IDLensViewControllers.m
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensViewControllers.h"
#import "IDDispensingDataStore.h"

#pragma mark Master

@implementation IDLensMasterViewController

#pragma mark Cell Configuration

- (UITableViewCell *)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    Order       *order = [self.dataFetcher.fetchedResultsController objectAtIndexPath:indexPath];
    IDLensCell  *orderCell = (IDLensCell *)cell;

    // Configure the cell with the order data
    orderCell.orderNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)order.guid];
    orderCell.nameLabel.text = [NSString stringWithFormat:@"%@, %@", order.patient.surName, order.patient.firstName];
    orderCell.dateLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:order.date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    orderCell.priceLabel.text = [NSString stringWithFormat:@"%.2f", order.total];

    // Lens data
    Lens *lens = [order.lenses anyObject];
    orderCell.lensLabel.text = lens.name;

    // Frame data
    orderCell.frameLabel.text = order.frame.type;

    return orderCell;
}

#pragma mark Tableview Delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.selectedOrder = [self.dataFetcher.fetchedResultsController objectAtIndexPath:indexPath];

    return indexPath;
}

#pragma mark Tableview Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell  = [self.tableView dequeueReusableCellWithIdentifier:@"LensCell"];

    // Configure the cell with the order data
    return [self configureCell:cell atIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

#pragma mark Search bar

- (NSPredicate *)predicateForSearchMode:(NSInteger)mode withString:(NSString *)searchString {

    NSPredicate *predicate = nil;

    // Configure the fetch request with the required fetch predicates.
    if (searchString && [searchString compare:@""] != NSOrderedSame) {

        if (mode == 0) {        // GUID search

            predicate = [NSPredicate predicateWithFormat:@"guid = %@", searchString];
        }

        else if (mode == 1) {   // Patient surname search

            predicate  = [NSPredicate predicateWithFormat:@"ANY patient.surName CONTAINS[c] %@", searchString];
        }
    }

    return predicate;
}

- (UIKeyboardType)keyboardTypeForSearchScope:(NSInteger)scope {

    return (scope) ? UIKeyboardTypeNumberPad : UIKeyboardTypeDefault;
}

#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    // Find the order that's to be displayed in the detail view controller.
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        
        //objectContextTrackingDisabled = YES;
        
        // The user has asked for a new order:
        self.selectedOrder = [[IDDispensingDataStore defaultDataStore] createOrder];
        //objectContextTrackingDisabled = NO;

        // TODO: put this in a callback
        [self scrollToBottom];
    }
    
    // Set up the order detail view controller.
    IDLensDetailViewController *detailViewController = segue.destinationViewController;
    
    detailViewController.detailOrder = self.selectedOrder;

    detailViewController.doneBlock = ^(Order *order) { NSLog(@"Done %@", order); };
    detailViewController.cancelBlock = ^(Order *order) { NSLog(@"Cancel %@", order); };
}

@end

#pragma mark - Detail

@interface IDLensDetailViewController ()

// UI General Section
@property(nonatomic, weak) IBOutlet UILabel         *guidLabel;

@end

@implementation IDLensDetailViewController {

    BOOL            datePickerIsShown;
}

#pragma mark Lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    // Set up the immutable view details
    self.navigationItem.title = [NSString stringWithFormat:@"Lens %lld", self.detailOrder.guid];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    // End editing
    [self.view endEditing:YES];

    NSLog(@"Send changes back to caller = %@", self);
}

#pragma mark UITableViewDelegate conformance

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && indexPath.row == 2 && !datePickerIsShown) return 0;

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && indexPath.row == 1) {

        datePickerIsShown ^= YES;

        [tableView reloadData];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

#pragma mark - Cell

@implementation IDLensCell

- (void)awakeFromNib {

    // Initialization
    // self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

