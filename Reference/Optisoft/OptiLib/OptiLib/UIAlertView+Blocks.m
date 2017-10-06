//
//  UIAlertView+Blocks.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>


static NSString *kDSButtonAssociatedObjectKey = @"mobi.dogstar.buttons";

@implementation UIAlertView (Blocks)

-(id)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(DSButtonItem *)inCancelButtonItem otherButtonItems:(DSButtonItem *)inOtherButtonItems, ... {

    if ((self = [self initWithTitle:inTitle message:inMessage delegate:self cancelButtonTitle:inCancelButtonItem.label otherButtonTitles:nil])) {

        NSMutableArray *buttonsArray = [NSMutableArray array];

        DSButtonItem *eachItem;
        va_list argumentList;
        if (inOtherButtonItems) {

            [buttonsArray addObject: inOtherButtonItems];

            va_start(argumentList, inOtherButtonItems);
            while ((eachItem = va_arg(argumentList, DSButtonItem *))) [buttonsArray addObject: eachItem];
            va_end(argumentList);
        }

        for (DSButtonItem *item in buttonsArray) [self addButtonWithTitle:item.label];

        if (inCancelButtonItem) [buttonsArray insertObject:inCancelButtonItem atIndex:0];

        objc_setAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        [self setDelegate:self];
    }
    return self;
}

- (NSInteger)addButtonItem:(DSButtonItem *)item {

    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey);

	NSInteger buttonIndex = [self addButtonWithTitle:item.label];
	[buttonsArray addObject:item];

	return buttonIndex;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    // If the button index is -1 it means we were dismissed with no selection
    if (buttonIndex >= 0) {

        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey);
        DSButtonItem *item = [buttonsArray objectAtIndex:buttonIndex];
        if (item.action)
            item.action();
    }

    objc_setAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
