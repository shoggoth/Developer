//
//  CDSSyncManager.m
//  Idiomatic
//
//  Created by Drew McCormack on 04/03/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreGraphics/CoreGraphics.h>
#import <DropboxSDK/DropboxSDK.h>
#import <Security/Security.h>

#import "CDSSyncManager.h"
#import "CDSMultipeerManager.h"
#import "CDEDropboxCloudFileSystem.h"
#import "CDENodeCloudFileSystem.h"
#import "CDEMultipeerCloudFileSystem.h"

#import "CDSDataStore.h"

NSString * const CDSSyncActivityDidBeginNotification = @"CDSSyncActivityDidBegin";
NSString * const CDSSyncActivityDidEndNotification = @"CDSSyncActivityDidEnd";

NSString * const CDSCloudServiceUserDefaultKey = @"CDSCloudServiceUserDefaultKey";
NSString * const CDSICloudService = @"icloud";
NSString * const CDSDropboxService = @"dropbox";
NSString * const CDSNodeS3Service = @"node";
NSString * const CDSMultipeerService = @"multipeer";

NSString * const CDSNodeS3EmailDefaultKey = @"CDSNodeS3EmailDefaultKey";

// Set these with your account details
NSString * const CDSICloudContainerIdentifier = nil;
NSString * const CDSDropboxAppKey = @"fjgu077wm7qffv0";
NSString * const CDSDropboxAppSecret = @"djibc9zfvppronm";

@interface CDSSyncManager () <CDEPersistentStoreEnsembleDelegate, DBSessionDelegate, CDEDropboxCloudFileSystemDelegate, CDENodeCloudFileSystemDelegate>

@end

@implementation CDSSyncManager {
    id <CDECloudFileSystem> cloudFileSystem;
    NSUInteger activeMergeCount;
    CDECompletionBlock dropboxLinkSessionCompletion;
    CDECompletionBlock nodeCredentialUpdateCompletion;
    DBSession *dropboxSession;
    CDSMultipeerManager *multipeerManager;
}

@synthesize ensemble = ensemble;
@synthesize storePath = storePath;
@synthesize dataStore = dataStore;

+ (instancetype)sharedSyncManager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CDSSyncManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(icloudDidDownload:) name:CDEICloudFileSystemDidDownloadFilesNotification object:nil];

        // Add default store name.
        self.storeName = @"MainStore";
    }
    return self;
}

#pragma mark - Setting Up and Resetting

- (void)setup
{
    [self setupEnsemble];
}

- (void)reset
{
    [multipeerManager stop];
    [multipeerManager.multipeerCloudFileSystem removeAllFiles];
    multipeerManager = nil;

    [self clearNodePassword];
    
    [dropboxSession unlinkAll];
    dropboxSession = nil;
    
    ensemble.delegate = nil;
    ensemble = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CDSCloudServiceUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Connecting to a Backend Service

- (void)connectToSyncService:(NSString *)serviceId withCompletion:(CDECompletionBlock)completion
{
    [[NSUserDefaults standardUserDefaults] setObject:serviceId forKey:CDSCloudServiceUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupEnsemble];
    [self synchronizeWithCompletion:completion];
}

- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion
{
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        [self reset];
        if (completion) completion();
    }];
}

#pragma mark - Persistent Store Ensemble

- (void)setupEnsemble
{
    if (!self.canSynchronize) return;

    cloudFileSystem = [self makeCloudFileSystem];
    if (!cloudFileSystem) return;

    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:self.storeName persistentStoreURL:storeURL managedObjectModelURL:self.modelURL cloudFileSystem:cloudFileSystem];
    ensemble.delegate = self;
}

- (id <CDECloudFileSystem>)makeCloudFileSystem
{
    NSString *cloudService = [[NSUserDefaults standardUserDefaults] stringForKey:CDSCloudServiceUserDefaultKey];
    id <CDECloudFileSystem> newSystem = nil;
    if ([cloudService isEqualToString:CDSICloudService]) {
        newSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:CDSICloudContainerIdentifier];
    }
    else if ([cloudService isEqualToString:CDSDropboxService]) {
        dropboxSession = [[DBSession alloc] initWithAppKey:CDSDropboxAppKey appSecret:CDSDropboxAppSecret root:kDBRootAppFolder];
        dropboxSession.delegate = self;
        CDEDropboxCloudFileSystem *newDropboxSystem = [[CDEDropboxCloudFileSystem alloc] initWithSession:dropboxSession];
        newDropboxSystem.delegate = self;
        newSystem = newDropboxSystem;
    }
    else if ([cloudService isEqualToString:CDSNodeS3Service]) {
        NSURL *url = [NSURL URLWithString:@"https://ensembles.herokuapp.com"];
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:CDSNodeS3EmailDefaultKey] ? : @"";
        NSString *password = [self retrieveNodePassword];
        CDENodeCloudFileSystem *newNodeFileSystem = [[CDENodeCloudFileSystem alloc] initWithBaseURL:url];
        newNodeFileSystem.delegate = self;
        newNodeFileSystem.username = username;
        newNodeFileSystem.password = password;
        newSystem = newNodeFileSystem;
    }
    else if ([cloudService isEqualToString:CDSMultipeerService]) {
        multipeerManager = [[CDSMultipeerManager alloc] init];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths.lastObject stringByAppendingPathComponent:@"Idiomatic/Multipeer"];
        CDEMultipeerCloudFileSystem *multipeerCloudFileSystem = [[CDEMultipeerCloudFileSystem alloc] initWithRootDirectory:path multipeerConnection:multipeerManager];
        multipeerManager.multipeerCloudFileSystem = multipeerCloudFileSystem;
        [multipeerManager start];
        
        newSystem = multipeerCloudFileSystem;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didImportFiles) name:CDEMultipeerCloudFileSystemDidImportFilesNotification object:nil];
    }
    
    return newSystem;
}

#pragma mark - Sync Methods

- (void)icloudDidDownload:(NSNotification *)notif
{
    [self synchronizeWithCompletion:NULL];
}

- (BOOL)canSynchronize
{
    NSString *cloudService = [[NSUserDefaults standardUserDefaults] stringForKey:CDSCloudServiceUserDefaultKey];
    return cloudService != nil;
}

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion
{
    if (!self.canSynchronize) return;

    [self incrementMergeCount];
    if (!ensemble.isLeeched) {
        [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if (error && !ensemble.isLeeched) {
                NSLog(@"Could not leech to ensemble: %@", error);
                [self disconnectFromSyncServiceWithCompletion:^{
                    if (completion) completion(error);
                }];
            }
            else {
                if (completion) completion(error);
            }
        }];
    }
    else {
        [ensemble mergeWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            [multipeerManager syncFilesWithAllPeers];
            if (error) NSLog(@"Error merging: %@", error);
            if (completion) completion(error);
        }];
    }
}

- (void)decrementMergeCount
{
    activeMergeCount--;
    if (activeMergeCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CDSSyncActivityDidEndNotification object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)incrementMergeCount
{
    activeMergeCount++;
    if (activeMergeCount == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CDSSyncActivityDidBeginNotification object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

#pragma mark - Persistent Store Ensemble Delegate

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification
{
    [dataStore performBlock:^(CDSDataStore *ds) {

        [ds.moc mergeChangesFromContextDidSaveNotification:notification];

        return ds;

    } withCompletion:nil];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects
{
    return [objects valueForKeyPath:@"uuid"];
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error
{
    NSLog(@"Store did deleech with error: %@", error);
    [self reset];
}

#pragma mark - Dropbox Session

- (BOOL)handleOpenURL:(NSURL *)url {
    if ([dropboxSession handleOpenURL:url]) {
		if ([dropboxSession isLinked]) {
            if (dropboxLinkSessionCompletion) dropboxLinkSessionCompletion(nil);
		}
        else {
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeAuthenticationFailure userInfo:nil];
            if (dropboxLinkSessionCompletion) dropboxLinkSessionCompletion(error);
        }
        dropboxLinkSessionCompletion = NULL;
		return YES;
    }
    return NO;
}

- (void)linkSessionForDropboxCloudFileSystem:(CDEDropboxCloudFileSystem *)fileSystem completion:(CDECompletionBlock)completion
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    dropboxLinkSessionCompletion = [completion copy];
    [dropboxSession linkFromController:window.rootViewController];
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
}

#pragma mark - Node-S3 Backend Delegate Methods

- (void)nodeCloudFileSystem:(CDENodeCloudFileSystem *)fileSystem updateLoginCredentialsWithCompletion:(CDECompletionBlock)completion
{
    [self decrementMergeCount];
    [self clearNodePassword];
    nodeCredentialUpdateCompletion = [completion copy];

    // Present the node settings view
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nodeSettingsNavController = [storyboard instantiateViewControllerWithIdentifier:@"NodeSettingsNavigationController"];

    [window.rootViewController presentViewController:nodeSettingsNavController animated:YES completion:NULL];
}

#pragma mark - Storing Node Credentials

- (void)storeNodeCredentials
{
    [self incrementMergeCount];

    CDENodeCloudFileSystem *nodeFileSystem = (id)self.ensemble.cloudFileSystem;
    NSString *email = nodeFileSystem.username;
    NSString *password = nodeFileSystem.password;
    NSError *error = nil;
    if (email && password) {
        [[NSUserDefaults standardUserDefaults] setObject:email forKey:CDSNodeS3EmailDefaultKey];
        [self storeNodePassword:password];
    }
    else {
        NSDictionary *info = @{NSLocalizedDescriptionKey : @"Invalid username or password"};
        error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeAuthenticationFailure userInfo:info];
    }

    if (nodeCredentialUpdateCompletion) nodeCredentialUpdateCompletion(error);
    nodeCredentialUpdateCompletion = NULL;
}

- (void)cancelNodeCredentialsUpdate
{
    [self incrementMergeCount];

    NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeCancelled userInfo:nil];
    if (nodeCredentialUpdateCompletion) nodeCredentialUpdateCompletion(error);
    nodeCredentialUpdateCompletion = NULL;
}

- (NSDictionary *)keychainQuery {
    NSString *serviceName = @"com.mentalfaculty.ensembles.idiosync";
    return @{
             (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
             (__bridge id)kSecAttrService : serviceName,
             (__bridge id)kSecAttrAccount : serviceName,
             (__bridge id)kSecAttrAccessible : (__bridge id)kSecAttrAccessibleAlways
             };
}

- (void)storeNodePassword:(NSString *)newPassword
{
    NSMutableDictionary *keychainQuery = [[self keychainQuery] mutableCopy];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    keychainQuery[(__bridge id)kSecValueData] = [newPassword dataUsingEncoding:NSUTF8StringEncoding];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

- (NSString *)retrieveNodePassword
{
    NSMutableDictionary *keychainQuery = [[self keychainQuery] mutableCopy];
    keychainQuery[(__bridge id)kSecReturnData] = @YES;
    keychainQuery[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    NSString *result = nil;
    CFDataRef data = NULL;
    if (noErr == SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&data)) {
        result = [[NSString alloc] initWithData:(__bridge id)data encoding:NSUTF8StringEncoding];
    }
    if (data) CFRelease(data);

    return result;
}

- (void)clearNodePassword
{
    NSDictionary *keychainQuery = [self keychainQuery];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

#pragma mark - CDEMultipeerCloudFileSystem

- (void)didImportFiles
{
    [self synchronizeWithCompletion:nil];
}

@end
