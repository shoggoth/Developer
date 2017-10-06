//
//  CustomCellHeightTableViewController.m
//  CoreDataViewer
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "CustomCellHeightTableViewController.h"
#import "DataClasses.h"

@interface CustomCellHeightTableViewController ()

@end

@implementation CustomCellHeightTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;

    [self configureFetch];
    [self performFetch];

    self.clearConfirmActionSheet.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:@"SomethingChanged" object:nil];
}

- (void)configureFetch {

    DataStore *dataStore = [DataStore sharedDataStore];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];

    request.fetchBatchSize = 50;
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"place.name" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                ];

    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   context:dataStore.context
                                                     sectionNameKeyPath:nil cacheName:nil];
    self.frc.delegate = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Person *person = [self.frc objectAtIndexPath:indexPath];

    NSMutableString *title = [NSMutableString stringWithFormat:@"%@ %@ %@", person.name, person.nick, person.place.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"???" options:0 range:NSMakeRange(0, [title length])];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];

    UILabel *label = (UILabel *)[cell viewWithTag:0];

    label.text = title;

    if (person.beheaded.boolValue) {

        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor redColor];
        label.backgroundColor = [UIColor clearColor];

    } else {

        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }

    return cell;
}

@end


@interface DefaultCell : UITableViewCell

@end

@implementation DefaultCell

@end

#pragma mark - Constraint Cells

@interface ProgHeightCell : UITableViewCell

@end

@implementation ProgHeightCell {

    NSLayoutConstraint *heightConstraint;
}

+ (BOOL)requiresConstraintBasedLayout { return YES; }

- (void)updateConstraints {

    if (!heightConstraint) {

        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

        heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
        heightConstraint.active = YES;

        NSLog(@"Adding constraint");

    } else heightConstraint.constant = (rand() % 100) + 46;

    [super updateConstraints];
}

@end


@interface PersonCell : UITableViewCell

@end

@implementation PersonCell

@end


@interface HeightyCell : UITableViewCell

@property(nonatomic, weak, nonnull) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation HeightyCell

- (void)updateConstraints {

    self.heightConstraint.constant = (rand() % 100) + 46;

    [super updateConstraints];
}

@end

