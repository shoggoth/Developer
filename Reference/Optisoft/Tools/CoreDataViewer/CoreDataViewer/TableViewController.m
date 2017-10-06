//
//  TableViewController.m
//  CloudStorage
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "TableViewController.h"

@implementation TableViewController

#pragma mark Fetch

- (void)performFetch {

    if (self.frc) {

        [self.frc.managedObjectContext performBlockAndWait:^{

            NSError *error;

            if (![self.frc performFetch:&error]) NSLog(@"Failed to perform fetch: %@", error);

            [self.tableView reloadData];
        }];
    }
}

#pragma mark Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.frc.sections.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {

    return self.frc.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

    return [self.frc sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [[self.frc.sections objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.frc.sections objectAtIndex:section] numberOfObjects];
}

#pragma mark Delegate (NSFetchedResultsController)

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tv = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            if (!newIndexPath) {

                [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

            } else {

                [tv deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tv insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;

        case NSFetchedResultsChangeMove:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        default:
            NSLog(@"Warning: (CloudStorage.TableViewController) Move and update section not implemented");
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self.tableView endUpdates];
}

@end
