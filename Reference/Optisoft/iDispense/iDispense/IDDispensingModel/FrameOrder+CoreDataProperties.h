//
//  FrameOrder+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FrameOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface FrameOrder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *orderType;
@property (nullable, nonatomic, retain) Frame *frame;
@property (nullable, nonatomic, retain) Order *order;

@end

NS_ASSUME_NONNULL_END