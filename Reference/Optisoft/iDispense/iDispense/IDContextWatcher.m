//
//  IDContextWatcher.m
//  CloudStorage
//
//  Created by Richard Henry on 18/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import "IDContextWatcher.h"

@implementation IDContextWatcher {

    NSPredicate                 *rootPredicate;
}

- (instancetype)init {

    return [self initWithManagedObjectContextToWatch:nil];
}

- (instancetype)initWithManagedObjectContextToWatch:(NSManagedObjectContext *)context {

    if ((self = [super init])) {

        // Subscribe to data store save notifications.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeContentsDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
    }

    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Observing

- (void)addEntityToWatch:(NSString *)entityName withPredicate:(NSPredicate *)predicate {

    NSPredicate *entityPredicate = [NSPredicate predicateWithFormat:@"entity.name == %@", entityName];
    NSPredicate *newPredicates = (predicate) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[ entityPredicate, predicate ]] : entityPredicate;

    rootPredicate = (rootPredicate) ? [NSCompoundPredicate orPredicateWithSubpredicates:@[ rootPredicate, newPredicates ]] : newPredicates;
}

#pragma mark Updating

- (void)storeContentsDidSave:(NSNotification *)notification {

    // Get the original Core Data notification from the user info
    NSDictionary *coreDataNotification = notification.userInfo;
    NSManagedObjectContext *context = notification.object;

    // Make mutable copies of the changes to this context.
    NSMutableSet *inserts = [[coreDataNotification objectForKey:NSInsertedObjectsKey] mutableCopy];
    NSMutableSet *deletes = [[coreDataNotification objectForKey:NSDeletedObjectsKey] mutableCopy];
    NSMutableSet *updates = [[coreDataNotification objectForKey:NSUpdatedObjectsKey] mutableCopy];

    // Was a context passed to be used to load objects?
    if (context) {

        // Load objects if needed
        void (^convertManagedObjects)(NSMutableSet *objects) = ^(NSMutableSet *objects) {

            for (NSManagedObjectID *objectID in [objects copy]) {

                if ([objectID isKindOfClass:[NSManagedObjectID class]]) {

                    [objects addObject:[context objectWithID:objectID]];
                    [objects removeObject:objectID];
                }
            }
        };

        if (inserts.count) convertManagedObjects(inserts);
        if (deletes.count) convertManagedObjects(deletes);
        if (updates.count) convertManagedObjects(updates);
    }

    // Filter using the predicate if one has been specified.
    if (rootPredicate) {

        [inserts filterUsingPredicate:rootPredicate];
        [deletes filterUsingPredicate:rootPredicate];
        [updates filterUsingPredicate:rootPredicate];
    }

    // If there are still some changes left after the checks and filters, send them on to the delegate.
    if (inserts.count + deletes.count  + updates.count) {

        NSMutableDictionary *results = [NSMutableDictionary dictionary];

        if (inserts.count) [results setObject:inserts forKey:NSInsertedObjectsKey];
        if (deletes.count) [results setObject:deletes forKey:NSDeletedObjectsKey];
        if (updates.count) [results setObject:updates forKey:NSUpdatedObjectsKey];

        // Call the update block on the main thread.
        if (self.updateBlock) {

            dispatch_async(dispatch_get_main_queue(), ^{ self.updateBlock(results); });
        }
    }
}

@end
