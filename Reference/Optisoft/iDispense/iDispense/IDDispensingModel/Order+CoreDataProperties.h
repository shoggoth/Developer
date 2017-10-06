//
//  Order+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Order.h"

NS_ASSUME_NONNULL_BEGIN

@interface Order (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDecimalNumber *charges;
@property (nullable, nonatomic, retain) NSString *chargesDescription;
@property (nullable, nonatomic, retain) NSString *comments;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSNumber *orderNumber;
@property (nullable, nonatomic, retain) NSString *orderPrefix;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSSet<Adjustment *> *adjustments;
@property (nullable, nonatomic, retain) DO *dispensingOpt;
@property (nullable, nonatomic, retain) FrameOrder *frameOrder;
@property (nullable, nonatomic, retain) LensOrder *lensOrder;
@property (nullable, nonatomic, retain) Patient *patient;
@property (nullable, nonatomic, retain) Supplier *supplier;

@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addAdjustmentsObject:(Adjustment *)value;
- (void)removeAdjustmentsObject:(Adjustment *)value;
- (void)addAdjustments:(NSSet<Adjustment *> *)values;
- (void)removeAdjustments:(NSSet<Adjustment *> *)values;

@end

NS_ASSUME_NONNULL_END
