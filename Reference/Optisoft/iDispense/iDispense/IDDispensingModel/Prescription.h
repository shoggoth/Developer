//
//  Prescription.h
//  iDispense
//
//  Created by Richard Henry on 18/02/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EyePrescription, Patient;

NS_ASSUME_NONNULL_BEGIN

@interface Prescription : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Prescription+CoreDataProperties.h"
