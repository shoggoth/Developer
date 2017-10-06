//
//  Lens+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Lens.h"

NS_ASSUME_NONNULL_BEGIN

@interface Lens (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *material;
@property (nullable, nonatomic, retain) NSNumber *visionType;
@property (nullable, nonatomic, retain) NSSet<LensOrder *> *leftOrders;
@property (nullable, nonatomic, retain) LensManufacturer *manufacturer;
@property (nullable, nonatomic, retain) NSSet<LensOrder *> *rightOrders;

@end

@interface Lens (CoreDataGeneratedAccessors)

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
