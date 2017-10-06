//
//  Frame+CoreDataProperties.h
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Frame.h"

NS_ASSUME_NONNULL_BEGIN

@interface Frame (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *measurements;
@property (nullable, nonatomic, retain) NSString *style;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) FrameOrder *order;

@end

NS_ASSUME_NONNULL_END
