//
//  LensTreatment+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LensTreatment.h"

NS_ASSUME_NONNULL_BEGIN

@interface LensTreatment (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSSet<LensOrder *> *leftOrders;
@property (nullable, nonatomic, retain) LensManufacturer *manufacturer;
@property (nullable, nonatomic, retain) NSSet<LensOrder *> *rightOrders;

@end

@interface LensTreatment (CoreDataGeneratedAccessors)

- (void)addLeftOrdersObject:(LensOrder *)value;
- (void)removeLeftOrdersObject:(LensOrder *)value;
- (void)addLeftOrders:(NSSet<LensOrder *> *)values;
- (void)removeLeftOrders:(NSSet<LensOrder *> *)values;

- (void)addRightOrdersObject:(LensOrder *)value;
- (void)removeRightOrdersObject:(LensOrder *)value;
- (void)addRightOrders:(NSSet<LensOrder *> *)values;
- (void)removeRightOrders:(NSSet<LensOrder *> *)values;

@end

NS_ASSUME_NONNULL_END
