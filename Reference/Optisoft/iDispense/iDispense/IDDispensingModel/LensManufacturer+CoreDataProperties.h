//
//  LensManufacturer+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LensManufacturer.h"

NS_ASSUME_NONNULL_BEGIN

@interface LensManufacturer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Lens *> *lenses;
@property (nullable, nonatomic, retain) NSSet<LensTreatment *> *treatments;

@end

@interface LensManufacturer (CoreDataGeneratedAccessors)

- (void)addLensesObject:(Lens *)value;
- (void)removeLensesObject:(Lens *)value;
- (void)addLenses:(NSSet<Lens *> *)values;
- (void)removeLenses:(NSSet<Lens *> *)values;

- (void)addTreatmentsObject:(LensTreatment *)value;
- (void)removeTreatmentsObject:(LensTreatment *)value;
- (void)addTreatments:(NSSet<LensTreatment *> *)values;
- (void)removeTreatments:(NSSet<LensTreatment *> *)values;

@end

NS_ASSUME_NONNULL_END
