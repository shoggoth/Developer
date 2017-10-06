//
//  Supplier+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Supplier.h"

NS_ASSUME_NONNULL_BEGIN

@interface Supplier (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *accountNumber;
@property (nullable, nonatomic, retain) NSString *emailAddress;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Order *> *orders;

@end

@interface Supplier (CoreDataGeneratedAccessors)

- (void)addOrdersObject:(Order *)value;
- (void)removeOrdersObject:(Order *)value;
- (void)addOrders:(NSSet<Order *> *)values;
- (void)removeOrders:(NSSet<Order *> *)values;

@end

NS_ASSUME_NONNULL_END
