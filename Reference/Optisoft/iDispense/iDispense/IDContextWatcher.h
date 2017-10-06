//
//  IDContextWatcher.h
//  CloudStorage
//
//  Created by Richard Henry on 16/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

@import CoreData;

//
//  interface IDContextWatcher
//
//  Listens for changes in the context to which it's attached, dependant on the entity and predicate specified.
//

@interface IDContextWatcher : NSObject

- (nonnull instancetype)initWithManagedObjectContextToWatch:(NSManagedObjectContext *__nullable)context;

// Delegate block.
@property(nonatomic, copy, nullable) void (^updateBlock)(NSDictionary *__nonnull);

// Specify the entities we want to watch for changes.
- (void)addEntityToWatch:(nonnull NSString *)entityName withPredicate:(nullable NSPredicate *)predicate;

@end
