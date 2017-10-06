//
//  IDRecordFetcher.m
//  iDispense
//
//  Created by Richard Henry on 14/11/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDRecordFetcher.h"
#import "IDDispensingDataStore.h"

@implementation IDRecordFetcher {

    NSString                    *cacheName;
    NSFetchedResultsController  *fetchedResultsController;
}

- (instancetype)initWithEntityName:(NSString *)eName sortDescriptors:(NSArray *)sortDesc {

    if ((self = [super init])) {

        // Initialisation
        self.entityName = eName;
        self.sortingDescriptors = sortDesc;
    }

    return self;
}

- (id)init {

    if ((self = [super init])) {

        // Make a unique cache name for this fetcher.
        cacheName = [NSString stringWithFormat:@"RecordFetcher-%lu-cache", (unsigned long)self.hash];
    }

    return self;
}

- (NSArray *)fetch {

    NSError *error;

    // Perform the fetch
    if (![self.fetchedResultsController performFetch:&error]) {

        NSLog(@"Error fetching data from Core Data store: %@, %@", error, [error userInfo]);
        return nil;
    }

    return self.fetchedResultsController.fetchedObjects;
}

- (void)deleteCache {

    [NSFetchedResultsController deleteCacheWithName:cacheName];
}

#pragma mark Properties

- (void)setPredicate:(NSPredicate *)pred {

    // Delete the previous cache
    [self deleteCache];

    // Set the predicate
    self.fetchedResultsController.fetchRequest.predicate = pred;

    // Fetch results that have the predicate we just applied set.
    [self fetch];
}

- (NSFetchedResultsController *)fetchedResultsController {

    if (fetchedResultsController) return fetchedResultsController;

    // Create and configure a fetch request with an entity type to fetch.
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:[IDDispensingDataStore defaultDataStore].managedObjectContext];
    fetchRequest.entity = entity;

    // We are going to be using the results of the fetch in a table so let's have a small batch size
    fetchRequest.fetchBatchSize = 23;

    // Find out how we want to sort the records that are returned when the fetch happens.
    fetchRequest.sortDescriptors = self.sortingDescriptors;

    // Create and initialize the fetch results controller.
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[IDDispensingDataStore defaultDataStore].managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];

    return fetchedResultsController;
}

@end
