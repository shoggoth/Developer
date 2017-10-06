//
//  Order+CoreDataProperties.m
//  iDispense
//
//  Created by Richard Henry on 17/05/2016.
//  Copyright © 2016 Optisoft Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Order+CoreDataProperties.h"

@implementation Order (CoreDataProperties)

@dynamic charges;
@dynamic chargesDescription;
@dynamic comments;
@dynamic date;
@dynamic dateModified;
@dynamic orderNumber;
@dynamic orderPrefix;
@dynamic status;
@dynamic uuid;
@dynamic adjustments;
@dynamic dispensingOpt;
@dynamic frameOrder;
@dynamic lensOrder;
@dynamic patient;
@dynamic supplier;

@end
