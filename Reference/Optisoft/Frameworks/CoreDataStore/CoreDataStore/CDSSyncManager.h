//
//  CDSSyncManager.h
//  CoreDataStore
//
//  Created by Drew McCormack on 04/03/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ensembles/Ensembles.h>

extern NSString * const CDSSyncActivityDidBeginNotification;
extern NSString * const CDSSyncActivityDidEndNotification;

extern NSString * const CDSCloudServiceUserDefaultKey;
extern NSString * const CDSICloudService;
extern NSString * const CDSDropboxService;
extern NSString * const CDSNodeS3Service;
extern NSString * const CDSMultipeerService;

@class CDSDataStore;

@interface CDSSyncManager : NSObject

@property(nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property(nonatomic, readwrite, strong) CDSDataStore *dataStore;
@property(nonatomic, readwrite, copy) NSString *storePath;
@property(nonatomic, strong) NSURL *modelURL;
@property(nonatomic, strong) NSString *storeName;

+ (instancetype)sharedSyncManager;

- (void)connectToSyncService:(NSString *)serviceId withCompletion:(CDECompletionBlock)completion;
- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion;

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;
- (BOOL)canSynchronize;

- (void)setup;
- (void)reset;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)storeNodeCredentials;
- (void)cancelNodeCredentialsUpdate;

@end
