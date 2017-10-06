//
//  Prescription+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Prescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface Prescription (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *comment;
@property (nullable, nonatomic, retain) NSDate *examDate;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) EyePrescription *left;
@property (nullable, nonatomic, retain) Patient *patient;
@property (nullable, nonatomic, retain) EyePrescription *right;

@end

NS_ASSUME_NONNULL_END
