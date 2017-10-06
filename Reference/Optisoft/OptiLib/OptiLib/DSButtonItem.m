//
//  DSButtonItem.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSButtonItem.h"


@implementation DSButtonItem

@synthesize label;
@synthesize action;

+ (id)item {

    return [self new];
}

+ (id)itemWithLabel:(NSString *)label {

    DSButtonItem *newItem = [self item];
    newItem.label = label;

    return newItem;
}

+ (id)itemWithLabel:(NSString *)label action:(DSButtonItemAction)action {

    DSButtonItem *newItem = [self itemWithLabel:label];
    newItem.action = action;

    return newItem;
}

@end

