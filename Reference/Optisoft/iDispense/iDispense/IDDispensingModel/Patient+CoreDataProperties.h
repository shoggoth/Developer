//
//  Patient+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Patient.h"

NS_ASSUME_NONNULL_BEGIN

@interface Patient (CoreDataProperties)

@property (nullable, nonatomic, retain) NSSet<Order *> *orders;
@property (nullable, nonatomic, retain) NSSet<Prescription *> *prescriptions;

@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addOrdersObject:(Order *)value;
- (void)removeOrdersObject:(Order *)value;
- (void)addOrders:(NSSet<Order *> *)values;
- (void)removeOrders:(NSSet<Order *> *)values;

- (void)addPrescriptionsObject:(Prescription *)value;
- (void)removePrescriptionsObject:(Prescription *)value;
- (void)addPrescriptions:(NSSet<Prescription *> *)values;
- (void)removePrescriptions:(NSSet<Prescription *> *)values;

@end

NS_ASSUME_NONNULL_END
