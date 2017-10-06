//
//  IDDataFetchController.m
//  iDispense
//
//  Created by Richard Henry on 06/04/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "IDDataFetchController.h"
#import "IDDispensingDataStore.h"

static UITableViewRowAnimation rowAnimation = UITableViewRowAnimationAutomatic;

@interface IDDataFetchController () <NSFetchedResultsControllerDelegate>

@end

@implementation IDDataFetchController {

    UITableView     *tableView;
    NSString        *cacheName;
}

#pragma mark Properties

- (NSPredicate *)predicate { return _fetchedResultsController.fetchRequest.predicate; }

- (void)setPredicate:(NSPredicate *)predicate { _fetchedResultsController.fetchRequest.predicate = predicate; }

#pragma mark Lifecycle

- (instancetype)initWithTableView:(UITableView *)tv entityName:(NSString *)en sortDescriptors:(NSArray<NSSortDescriptor *> *)sd cacheName:(NSString *)cn sectionNameKeyPath:(NSString *)sk mocToObserve:(NSManagedObjectContext *)moc   {

    if ((self = [super init])) {

        // Keep the table view that the fetch is associated with and the cache name.
        tableView = tv;
        cacheName = cn;

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:({

            NSFetchRequest *fetchRequest = [NSFetchRequest new];

            // Create and configure a fetch request with an entity type to fetch.
            fetchRequest.entity = [NSEntityDescription entityForName:en inManagedObjectContext:moc];
            fetchRequest.sortDescriptors = sd;

            // We are going to be using the results of the fetch in a table so let's have a small batch size
            fetchRequest.fetchBatchSize = 23;

            fetchRequest;

        }) managedObjectContext:moc sectionNameKeyPath:sk cacheName:cn];

        _fetchedResultsController.delegate = self;
    }

    return self;
}

- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd cacheName:(NSString *__nullable)cn sectionNameKeyPath:(NSString *__nullable)sk {

    return [self initWithTableView:tv entityName:en sortDescriptors:sd cacheName:cn sectionNameKeyPath:sk mocToObserve:IDDispensingDataStore.defaultDataStore.managedObjectContext];
}

- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd cacheName:(NSString *__nullable)cn {

    return [self initWithTableView:tv entityName:en sortDescriptors:sd cacheName:cn sectionNameKeyPath:nil];
}

- (nonnull instancetype)initWithTableView:(UITableView *__nonnull)tv entityName:(NSString *__nonnull)en sortDescriptors:(NSArray<NSSortDescriptor *> *__nonnull)sd {

    return [self initWithTableView:tv entityName:en sortDescriptors:sd cacheName:nil];
}

#pragma mark Data fetch

- (void)fetchWithCompletion:(void (^)(NSArray *))completion {

    [_fetchedResultsController.managedObjectContext performBlock:^{

        NSError *err; [_fetchedResultsController performFetch:&err];

        if (err) NSLog(@"Error fetching %@", err);

        else if (completion) {

            dispatch_async(dispatch_get_main_queue(), ^{ completion(_fetchedResultsController.fetchedObjects); });
        }
    }];
}

#pragma mark Fetched results updates

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

    if (!_updatesAreUserDriven) { dispatch_async(dispatch_get_main_queue(), ^{ [tableView beginUpdates]; }); }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if (_updatesAreUserDriven) return;

    dispatch_async(dispatch_get_main_queue(), ^{

        switch (type) {

            case NSFetchedResultsChangeInsert:
                // FIXME: Xcode 7.0.1 / Swift 2.0  EXCEPTION BUG running iOS 8.x. Workaround from https://forums.developer.apple.com/message/59082#59082
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:rowAnimation];
                break;

            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                break;

            case NSFetchedResultsChangeUpdate:
                if (self.cellUpdateBlock) self.cellUpdateBlock([tableView cellForRowAtIndexPath:indexPath], anObject);
                break;

            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:rowAnimation];
                break;
        }
    });
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    if (_updatesAreUserDriven) _updatesAreUserDriven = NO;

    else { dispatch_async(dispatch_get_main_queue(), ^{

        [tableView endUpdates];

        if (_tableUpdateCompletionBlock) {

            if (_tableUpdateCompletionBlock(tableView)) self.tableUpdateCompletionBlock = nil;
        }
    });}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    if (_updatesAreUserDriven) return;

    dispatch_async(dispatch_get_main_queue(), ^{

        switch (type) {

            case NSFetchedResultsChangeInsert:
                [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
                break;

            case NSFetchedResultsChangeDelete:
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
                break;

            case NSFetchedResultsChangeUpdate:
            case NSFetchedResultsChangeMove:
                break;
        }
    });
}
@end
