//
//  Thing.h
//  CoreDataViewer
//
//  Created by Richard Henry on 20/08/2015.
//  Copyright (c) 2015 Optisoft Ltd. All rights reserved.
//

@import CoreData;

#import "Thing.h"
#import "Person.h"
#import "Place.h"

@interface Person (Private)

@property (nonatomic, readonly, nonnull) NSString *shoutyName;

@end

@implementation Person (Private)

- (nonnull NSString *) shoutyName { return self.name.uppercaseString; }

@end