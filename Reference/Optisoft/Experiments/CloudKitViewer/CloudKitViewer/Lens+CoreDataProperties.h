//
//  Lens+CoreDataProperties.h
//  CloudKitViewer
//
//  Created by Richard Henry on 04/11/2015.
//  Copyright © 2015 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Lens.h"

NS_ASSUME_NONNULL_BEGIN

@interface Lens (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSNumber *sph;

@end

NS_ASSUME_NONNULL_END
