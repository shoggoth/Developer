//
//  IFCoreDataStore.h
//  WOIAF
//
//  Created by Richard Henry on 04/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@interface IFResultFetcher : NSObject

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (copy, nonatomic)   NSString *entityName;
@property (copy, nonatomic)   NSString *searchString;
@property (assign, nonatomic) NSUInteger bookRead;

- (NSArray *)fetch;

@end


@interface IFCoreDataStore : NSObject <NSFetchedResultsControllerDelegate>

// Core data components
@property (readonly, strong, nonatomic) NSManagedObjectContext       *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel         *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// User default properties
@property (assign, nonatomic) NSUInteger lastBookRead;
@property (assign, nonatomic) NSUInteger lastChapterRead;
@property (assign, nonatomic) NSUInteger lastBookAllowed;

// Singleton
+ (IFCoreDataStore *)defaultDataStore;

// Fetching and saving
- (id)fetchItemWithUID:(NSString *)uid;
- (id)fetchItemWithTypeName:(NSString *)typeName uid:(NSString *)uid;

- (void)saveUserDefaults;
- (void)refreshBookLimits;

// History operations
- (void)addItemToHistory:(id)item;

- (id)historyBack;
- (id)historyForward;

- (NSUInteger)historyBackCount;
- (NSUInteger)historyForwardCount;

- (void)clearHistory;
@end
