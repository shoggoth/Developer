//
//  DO+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DO.h"

NS_ASSUME_NONNULL_BEGIN

@interface DO (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSSet<Order *> *orders;
@property (nullable, nonatomic, retain) Practice *practice;

@end

@interface DO (CoreDataGeneratedAccessors)

- (void)addOrdersObject:(Order *)value;
- (void)removeOrdersObject:(Order *)value;
- (void)addOrders:(NSSet<Order *> *)values;
- (void)removeOrders:(NSSet<Order *> *)values;

@end

NS_ASSUME_NONNULL_END
