//
//  LensOrder+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LensOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface LensOrder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *leftBlankSize;
@property (nullable, nonatomic, retain) NSNumber *rightBlankSize;
@property (nullable, nonatomic, retain) Lens *left;
@property (nullable, nonatomic, retain) NSSet<LensTreatment *> *leftTreatments;
@property (nullable, nonatomic, retain) Order *order;
@property (nullable, nonatomic, retain) Lens *right;
@property (nullable, nonatomic, retain) NSSet<LensTreatment *> *rightTreatments;

@end

@interface LensOrder (CoreDataGeneratedAccessors)

- (void)addLeftTreatmentsObject:(LensTreatment *)value;
- (void)removeLeftTreatmentsObject:(LensTreatment *)value;
- (void)addLeftTreatments:(NSSet<LensTreatment *> *)values;
- (void)removeLeftTreatments:(NSSet<LensTreatment *> *)values;

- (void)addRightTreatmentsObject:(LensTreatment *)value;
- (void)removeRightTreatmentsObject:(LensTreatment *)value;
- (void)addRightTreatments:(NSSet<LensTreatment *> *)values;
- (void)removeRightTreatments:(NSSet<LensTreatment *> *)values;

@end

NS_ASSUME_NONNULL_END
