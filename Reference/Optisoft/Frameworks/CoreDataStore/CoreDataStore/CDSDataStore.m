//
//  CDSDataStore.m
//  CoreDataStore
//
//  Created by Richard Henry on 20/04/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import "CDSDataStore.h"
#import "CDSSyncManager.h"

#import <UIKit/UIKit.h>

@interface CDSDataStore ()

@property(nonatomic, readonly, nonnull) NSString *dmName;

// Core data
@property(nonatomic, readonly, nonnull) NSManagedObjectModel *mom;
@property(nonatomic, readonly, nonnull) NSPersistentStoreCoordinator *psc;

@property(nonatomic, readonly, nonnull) CDSSyncManager *syncManager;

@end

#pragma mark - Base Data Store

@implementation CDSDataStore {

    NSManagedObjectModel *mom;
    NSPersistentStoreCoordinator *psc;

    @protected
    NSManagedObjectContext *moc;
    CDSSyncManager *esm;
}

- (instancetype)init {

    return [self initWithDataModelName:@"CDSModel"];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDataModelName:(NSString *)dataModelName {

    if ((self = [super init])) {

        // Save parameters
        _dmName = [dataModelName copy];

        // Create the directory structure if it doesn't exist already
        [[NSFileManager defaultManager] createDirectoryAtURL:self.storeDirectoryURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL];

        // Ensembles logging. If this is a release build then just log errors.
#if defined(DEBUG)
        CDESetCurrentLoggingLevel(CDELoggingLevelVerbose);
#else
        CDESetCurrentLoggingLevel(CDELoggingLevelError);
#endif
    }

    return self;
}

#pragma mark Properties

- (NSManagedObjectContext *)moc {

    @synchronized (self) {

        if (!moc) {

            // Create a context which will use the main queue for data operations.
            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

            moc.persistentStoreCoordinator = self.psc;
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

            // Undo manager setup
            moc.undoManager = [NSUndoManager new];
        }
    }

    return moc;
}

- (NSManagedObjectModel *)mom {

    @synchronized (self) {

        if (!mom) {

            // Get the object model
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.dmName withExtension:@"momd"];
            mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        }
    }
    
    return mom;
}

- (NSPersistentStoreCoordinator *)psc {

    @synchronized (self) {

        if (!psc) {

            // Create the store coordinator.
            NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES };
            psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.mom];

            NSError *err;
            [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:options error:&err];
        }
    }
    
    return psc;
}

- (CDSSyncManager *)syncManager {

    @synchronized (self) {

        if (!esm) {

            // Create an Ensembles Sync Manager
            esm = [CDSSyncManager sharedSyncManager];
            esm.dataStore = self;
            esm.storePath = self.storeURL.path;
            esm.modelURL = [[NSBundle mainBundle] URLForResource:self.dmName withExtension:@"momd"];

            // Do sync manager setup
            [esm setup];

            // Create notifications
            [self createSyncNotifications];
        }
    }
    
    return esm;
}

#pragma mark Operations

- (void)performBlock:(CDSContextBlock)contextBlock withCompletion:(CDSCompletionBlock)completionBlock {

    //NSAssert([NSThread isMainThread], @"CDSDataStore performBlock:withCompletion: called off main thread.");

    if (contextBlock) {

        [self.moc performBlockAndWait:^ {

            id value = contextBlock(self);

            if (completionBlock) completionBlock(value);
        }];

    } else if (completionBlock) completionBlock(nil);
}

#pragma mark Sync

- (BOOL)usingSync {

    return self.syncManager.canSynchronize;
}

- (void)setUsingSync:(BOOL)usingSync {

    if (usingSync) {

        [self.syncManager connectToSyncService:CDSICloudService withCompletion:^(NSError *err) {

            if (err) NSLog(@"CDSDataStore: Error: Connect to sync service error = %@.", err);
        }];

    } else [self.syncManager disconnectFromSyncServiceWithCompletion:nil];
}

#pragma mark Notifications

- (void)createSyncNotifications {

    // Observe application events
    //    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
    //                                                      object:nil
    //                                                       queue:nil
    //                                                  usingBlock:^(NSNotification *note) { [self startSavingInBackground]; }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) { [esm synchronizeWithCompletion:NULL]; }];
    // Observe data saves
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:self.moc
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) { [esm synchronizeWithCompletion:NULL]; }];
}

#pragma mark Saving

- (void)saveWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    [self.moc performBlock:^{

        if (self.moc.hasChanges) {

            NSError *err;
            if (![self.moc save:&err]) NSLog(@"CDSDataStore: Error: Saving MOC changes to %@\n%@", self.moc, err);
            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(err); });
        }

        [moc.undoManager removeAllActions];
    }];
}

- (void)undoWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    dispatch_async(dispatch_get_main_queue(), ^{

        [self.moc performBlock:^{

            [moc.undoManager undo];

            if (completionBlock) completionBlock(nil);
        }];
    });
}

- (void)rollbackWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    [self.moc performBlock:^{

        if (self.moc.hasChanges) {

            [self.moc rollback];

            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(nil); });

            [moc.undoManager removeAllActions];
        }
    }];
}

#pragma mark Sync

- (void)sync {

    if (self.syncManager.canSynchronize) [self.syncManager synchronizeWithCompletion:nil];
}

#pragma mark Core Data Stack

- (NSURL *)storeDirectoryURL {

    NSError *err;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:YES
                                                                    error:&err];

    return [directoryURL URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier isDirectory:YES];
}

- (NSURL *)storeURL { return [self.storeDirectoryURL URLByAppendingPathComponent:@"store.sqlite"]; }

@end


#pragma mark - Async Data Store

//
//  CDSAsyncDataStore
//
//  An oscillator which provides various common waveforms
//

@implementation CDSAsyncDataStore

#pragma mark Properties

- (NSManagedObjectContext *)moc {

    @synchronized (self) {

        if (!moc) {

            // Create a context which will use the main queue for data operations.
            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

            moc.persistentStoreCoordinator = self.psc;
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

            // Undo manager setup
            moc.undoManager = [NSUndoManager new];
        }
    }
    
    return moc;
}

#pragma mark Operations

- (void)performBlock:(CDSContextBlock)contextBlock withCompletion:(CDSCompletionBlock)completionBlock {

    //NSAssert([NSThread isMainThread], @"CDSAsyncDataStore performBlock:withCompletion: called off main thread.");

    if (contextBlock) {

        [self.moc performBlock:^ {

            id value = contextBlock(self);

            if (completionBlock) dispatch_sync(dispatch_get_main_queue(), ^{ completionBlock(value); });
        }];

    } else if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(nil); });
}

#pragma mark Notifications

- (void)createSyncNotifications {

    // Observe application events
    //    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
    //                                                      object:nil
    //                                                       queue:nil
    //                                                  usingBlock:^(NSNotification *note) { [self startSavingInBackground]; }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) { dispatch_async(dispatch_get_main_queue(), ^{ [esm synchronizeWithCompletion:NULL]; }); }];
    // Observe data saves
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:self.moc
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) { dispatch_async(dispatch_get_main_queue(), ^{ [esm synchronizeWithCompletion:NULL]; }); }];
}

#pragma mark Saving

- (void)saveWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    [self.moc performBlockAndWait:^{

        if (self.moc.hasChanges) {

            NSError *err;
            if (![self.moc save:&err]) NSLog(@"CDSDataStore: Error: Saving MOC changes to %@\n%@", self.moc, err);
            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(err); });
        }

        [moc.undoManager removeAllActions];
    }];
}

- (void)undoWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    dispatch_async(dispatch_get_main_queue(), ^{

        [self.moc performBlock:^{

            [moc.undoManager undo];

            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(nil); });
        }];
    });
}

- (void)rollbackWithCompletion:(nullable CDSCompletionBlock)completionBlock {

    [self.moc performBlockAndWait:^{

        if (self.moc.hasChanges) {

            [self.moc rollback];

            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(nil); });
        }
    }];
}

@end

#pragma mark - Deferred Data Store

//
//  CDSDeferredDataStore
//
//  An oscillator which provides various common waveforms
//

@implementation CDSDeferredDataStore {

    NSManagedObjectContext *parentContext;
}

#pragma mark Properties

- (NSManagedObjectContext *)moc {

    @synchronized (self) {

        if (!moc) {

            // Create a context which will use a parent queue for deferred data operations.
            parentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            parentContext.persistentStoreCoordinator = self.psc;

            // Create a context which will use the main queue for data operations.
            moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

            moc.parentContext = parentContext;
            moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

            // Undo manager setup
            moc.undoManager = [NSUndoManager new];
        }
    }
    
    return moc;
}

#pragma mark Sync

- (BOOL)usingSync { return NO; }

- (void)setUsingSync:(BOOL)usingSync {

    if (usingSync) NSLog(@"CDSDeferredDataStore: Error: Can't use Ensembles sync");
}

@end
