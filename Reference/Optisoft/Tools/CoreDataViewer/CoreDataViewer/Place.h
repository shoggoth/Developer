//
//  Place.h
//  CoreDataViewer
//
//  Created by Richard Henry on 20/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Thing.h"

@class Person;

@interface Place : Thing

@property (nonatomic, retain) NSNumber * secret;
@property (nonatomic, retain) NSSet *people;
@end

@interface Place (CoreDataGeneratedAccessors)

- (void)addPeopleObject:(Person *)value;
- (void)removePeopleObject:(Person *)value;
- (void)addPeople:(NSSet *)values;
- (void)removePeople:(NSSet *)values;

@end
