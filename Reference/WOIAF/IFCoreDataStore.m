//
//  IFCoreDataStore.m
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFCoreDataStore.h"
#import "ItemBase.h"


#pragma mark class IFResultFetcher

@implementation IFResultFetcher {
    
    NSFetchedResultsController  *fetchedResultsController;
}

@synthesize fetchedResultsController;

- (id)init {
    
    if ((self = [super init])) {
        
        self.entityName = @"ItemBase";
        self.searchString = nil;
        self.bookRead = [IFCoreDataStore defaultDataStore].lastBookRead;
    }
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController) return fetchedResultsController;
    
    // Create and configure a fetch request with an entity type to fetch.
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:[IFCoreDataStore defaultDataStore].managedObjectContext];
    fetchRequest.entity = entity;
    
    // Configure the fetch request with the required fetch predicates.
    NSPredicate *spoilerPredicate = [NSPredicate predicateWithFormat:@"book <= %@", @(self.bookRead)];
    
    if (self.searchString && [self.searchString compare:@""] != NSOrderedSame) {
        
        NSPredicate *searchPredicate  = [NSPredicate predicateWithFormat:@"ANY keywords.word CONTAINS[c] %@", self.searchString];
        fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[spoilerPredicate, searchPredicate]];
    
    } else fetchRequest.predicate = spoilerPredicate;
    
    // Create the sort descriptors array.
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[nameDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[IFCoreDataStore defaultDataStore].managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    return fetchedResultsController;
}

- (NSArray *)fetch {
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        return nil;
    }
    
    NSArray *array = self.fetchedResultsController.fetchedObjects;
    
    return array;
}

@end

static NSString *kIFLastBookReadKey = @"lastBookReadKey";
static NSString *kIFLastChapterReadKey = @"lastChapterReadKey";
static NSString *kIFBackHistoryKey = @"backHistoryKey";
static NSString *kIFForwardHistoryKey = @"forwardHistoryKey";

#pragma mark - class IFCoreDataStore

@interface IFCoreDataStore ()

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation IFCoreDataStore {
    
    // History
    id                  currentItem;
    NSMutableArray      *forwardHistory, *backHistory;
}

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

+ (IFCoreDataStore *)defaultDataStore {
    
    static IFCoreDataStore *defaultCoreDataStore;
    
    @synchronized(self) {
        
        if (!defaultCoreDataStore) defaultCoreDataStore = [IFCoreDataStore new];
    }
    
    return defaultCoreDataStore;
}

- (id)init {
    
    if ((self = [super init])) {
        
        // Spoiler protection initialisation
        self.lastBookRead = [[NSUserDefaults standardUserDefaults] integerForKey:kIFLastBookReadKey];
        self.lastChapterRead = [[NSUserDefaults standardUserDefaults] integerForKey:kIFLastChapterReadKey];
                
        // History initialisation
        currentItem = nil;
        backHistory = [NSMutableArray new];
        forwardHistory = [NSMutableArray new];
        
        NSArray *historyUIDs = [[NSUserDefaults standardUserDefaults] objectForKey:kIFForwardHistoryKey];
        
        for (NSString *uid in historyUIDs) {
            
            ItemBase *item = [self fetchItemWithUID:uid];
            
            if (item) [forwardHistory addObject:item];
        }
        
        historyUIDs = [[NSUserDefaults standardUserDefaults] objectForKey:kIFBackHistoryKey];
        
        for (NSString *uid in historyUIDs) {
            
            ItemBase *item = [self fetchItemWithUID:uid];
            
            if (item) [backHistory addObject:item];
        }
        
        [self refreshBookLimits];
    }
    
    return self;
}

- (void)dealloc {
    
    backHistory = nil;
    forwardHistory = nil;
}

#pragma mark - Interface

- (id)fetchItemWithUID:(NSString *)uid {
    
    // Prepare entity description
    NSEntityDescription *entityDescription  = [NSEntityDescription entityForName:@"ItemBase" inManagedObjectContext:self.managedObjectContext];
    if (!entityDescription) return nil;
    
    // Prepare fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    fetchRequest.entity = entityDescription;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid like %@", uid];
    
    // Execute fetch
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Prepare to return found item
    id item = nil;
    
    // Handle exceptions
    if (error)  NSLog(@"Item fetch error %@", error);
    
    else if (!array || !array.count) NSLog(@"Item with uid %@ not found.", uid);
    
    else item = [array lastObject];
    
    return item;
}

- (id)fetchItemWithTypeName:(NSString *)typeName uid:(NSString *)uid {
    
    // Prepare entity description
    NSEntityDescription *entityDescription;
    
    if ([typeName caseInsensitiveCompare:@"Person"] == NSOrderedSame)
        entityDescription  = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
    else if ([typeName caseInsensitiveCompare:@"Place"] == NSOrderedSame)
        entityDescription  = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    else if ([typeName caseInsensitiveCompare:@"House"] == NSOrderedSame)
        entityDescription  = [NSEntityDescription entityForName:@"House" inManagedObjectContext:self.managedObjectContext];
    else if ([typeName caseInsensitiveCompare:@"Map"] == NSOrderedSame)
        entityDescription  = [NSEntityDescription entityForName:@"Map" inManagedObjectContext:self.managedObjectContext];
    else entityDescription  = [NSEntityDescription entityForName:@"ItemBase" inManagedObjectContext:self.managedObjectContext];
    
    if (!entityDescription) return nil;
    
    // Prepare fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    
    fetchRequest.entity = entityDescription;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"uid like %@", uid];
    
    // Execute fetch
    NSError *error = nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Prepare to return found item
    id item = nil;
    
    // Handle exceptions
    if (error)  NSLog(@"Item fetch error %@", error);
    
    else if (!array || !array.count) NSLog(@"Item of type %@ and uid %@ not found.", typeName, uid);
    
    else item = [array lastObject];
    
    return item;
}

- (void)saveUserDefaults {
    
    // Save spoilers
    [[NSUserDefaults standardUserDefaults] setInteger:self.lastBookRead forKey:kIFLastBookReadKey];
    [[NSUserDefaults standardUserDefaults] setInteger:self.lastChapterRead forKey:kIFLastChapterReadKey];
    
    // Save history
    NSMutableArray *array = [NSMutableArray new];
    
    for (ItemBase *item in backHistory) [array addObject:item.uid];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kIFBackHistoryKey];
    
    [array removeAllObjects];
    for (ItemBase *item in forwardHistory) [array addObject:item.uid];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:kIFForwardHistoryKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshBookLimits {
    
    self.lastBookAllowed = 0;
    
    NSArray *purchaseChecks = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"WOIAF-Products" ofType:@"plist"]];

    unsigned book = 0;
    for (NSString *purchaseID in purchaseChecks) {
        
        NSLog(@"checking %@", purchaseID);
        
        if (book < 5) book++;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:purchaseID]) { self.lastBookAllowed = book; NSLog(@"found!"); }
    }

#if 0
    self.lastBookAllowed = 5;
#endif

    [self saveUserDefaults];
}

#pragma mark History specific

// History operations
- (void)addItemToHistory:(ItemBase *)item {
    
    if (currentItem) {
        
        // Check to see if the item is already in the history, remove it if so
        ItemBase *itemToBeRemovedFromHistory = nil;
        for (ItemBase *historyItem in backHistory) { if ([historyItem.uid compare:item.uid] == NSOrderedSame) itemToBeRemovedFromHistory = historyItem; break; }
        if (itemToBeRemovedFromHistory) [backHistory removeObject:itemToBeRemovedFromHistory];
        
        for (ItemBase *historyItem in forwardHistory) { if ([historyItem.uid compare:item.uid] == NSOrderedSame) itemToBeRemovedFromHistory = historyItem; break; }
        if (itemToBeRemovedFromHistory) [forwardHistory removeObject:itemToBeRemovedFromHistory];
        
        // Add the object to the history
        [backHistory addObject:currentItem];
        
        // Notify interested parties that a history item was added.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kIFItemAddedToHistory" object:self];
    }
    
    currentItem = item;
}

- (id)historyBack {
    
    int count = backHistory.count;
    if (!count) return nil;
    
    if (currentItem) [forwardHistory addObject:currentItem];
    
    currentItem = [backHistory objectAtIndex:count - 1];
    [backHistory removeObject:currentItem];
    
    return currentItem;
}

- (id)historyForward {
    
    int count = forwardHistory.count;
    if (!count) return nil;

    if (currentItem) [backHistory addObject:currentItem];

    currentItem = [forwardHistory objectAtIndex:count - 1];
    [forwardHistory removeObject:currentItem];
    
    return currentItem;
}

- (NSUInteger)historyBackCount { return backHistory.count; }
- (NSUInteger)historyForwardCount { return forwardHistory.count; }

- (void)clearHistory {
    
    currentItem = nil;
    [forwardHistory removeAllObjects];
    [backHistory removeAllObjects];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    if (!managedObjectContext) {
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        
        if (coordinator) {
            
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            managedObjectContext.persistentStoreCoordinator = coordinator;
        }
    }
    
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    
    if (!managedObjectModel) {
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WOIAF" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    
    if (!persistentStoreCoordinator) {
        
#ifdef IF_COPY_STORE_TO_DOCUMENTS_FOLDER
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WOIAF.sqlite"];

        // Set up the store.
        // Provide a pre-populated default store.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // If the expected store doesn't exist, copy the default store.
        if (![fileManager fileExistsAtPath:[storeURL path]]) {
            
            NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"WOIAF" withExtension:@"sqlite"];
            if (defaultStoreURL) [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
        }
#else
        NSURL *storeURL = [[NSBundle mainBundle] URLForResource:@"WOIAF" withExtension:@"sqlite"];
#endif
        
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES, NSReadOnlyPersistentStoreOption : @YES };
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSError *error = nil;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            
            NSLog(@"Unresolved error (Persistent store coordinator) %@, %@", error, [error userInfo]);
            
            return nil;
        }
    }
    
    return persistentStoreCoordinator;
}

#pragma mark Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    // Returns the URL to the application's Documents directory.
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Fetch request

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    //[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    /*UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }*/
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    /*switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }*/
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    //[self.tableView endUpdates];
}

@end
