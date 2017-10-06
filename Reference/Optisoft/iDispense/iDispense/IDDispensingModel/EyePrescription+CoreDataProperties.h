//
//  EyePrescription+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EyePrescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface EyePrescription (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *add;
@property (nullable, nonatomic, retain) NSNumber *addCentres;
@property (nullable, nonatomic, retain) NSNumber *axis;
@property (nullable, nonatomic, retain) NSNumber *centres;
@property (nullable, nonatomic, retain) NSNumber *cyl;
@property (nullable, nonatomic, retain) NSNumber *direction;
@property (nullable, nonatomic, retain) NSNumber *prism;
@property (nullable, nonatomic, retain) NSNumber *segHeight;
@property (nullable, nonatomic, retain) NSNumber *segSize;
@property (nullable, nonatomic, retain) NSNumber *sph;
@property (nullable, nonatomic, retain) Prescription *left;
@property (nullable, nonatomic, retain) Prescription *right;

@end

NS_ASSUME_NONNULL_END
