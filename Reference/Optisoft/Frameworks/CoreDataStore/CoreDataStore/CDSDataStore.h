//
//  CDSDataStore.h
//  CoreDataStore
//
//  Created by Richard Henry on 20/04/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

//
//  interface CDSDataStore
//
//  An oscillator which provides various common waveforms.
//

@class CDSDataStore;

typedef id __nullable (^CDSContextBlock)(CDSDataStore *__nonnull);
typedef void (^CDSCompletionBlock)(id __nullable);

@interface CDSDataStore : NSObject

- (nonnull instancetype)initWithDataModelName:(nonnull NSString *)dataModelName;

// Properties
@property(nonatomic) BOOL usingSync;
@property(nonatomic, readonly, nonnull) NSManagedObjectContext *moc;

// Operations
- (void)performBlock:(nullable CDSContextBlock)contextBlock withCompletion:(nullable CDSCompletionBlock)completionBlock;

// Saving
- (void)saveWithCompletion:(nullable CDSCompletionBlock)completionBlock;
- (void)undoWithCompletion:(nullable CDSCompletionBlock)completionBlock;
- (void)rollbackWithCompletion:(nullable CDSCompletionBlock)completionBlock;

// Sync
- (void)sync;

@end

//
//  interface CDSAsyncDataStore
//
//  An oscillator which provides various common waveforms.
//

@interface CDSAsyncDataStore : CDSDataStore

@end

//
//  interface CDSDeferredDataStore
//
//  An oscillator which provides various common waveforms.
//

@interface CDSDeferredDataStore : CDSAsyncDataStore

@end
