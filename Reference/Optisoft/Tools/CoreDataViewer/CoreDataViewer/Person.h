//
//  Person.h
//  CoreDataViewer
//
//  Created by Richard Henry on 25/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Thing.h"

@class Place;

@interface Person : Thing

@property (nonatomic, retain) NSData * mugshot;
@property (nonatomic, retain) NSString * nick;
@property (nonatomic, retain) NSNumber * beheaded;
@property (nonatomic, retain) Place *place;

@end
