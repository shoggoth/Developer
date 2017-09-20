//
//  MDAppDelegate.h
//  MasterDetail
//
//  Created by Optisoft Ltd on 15/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
