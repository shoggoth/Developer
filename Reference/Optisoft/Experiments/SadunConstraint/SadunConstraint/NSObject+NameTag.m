//
//  NSObject+NameTag.m
//  SadunConstraint
//
//  Created by Richard Henry on 07/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "NSObject+NameTag.h"
#import <objc/runtime.h>


@implementation NSObject (NameTag)

// NameTag getter
- (id)nameTag { return objc_getAssociatedObject(self, @selector(nameTag)); }

// NameTag setter
- (void)setNameTag:(NSString *)tag { objc_setAssociatedObject(self, @selector(nameTag), tag, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

@end
