//
//  UIActionSheet+Blocks.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

static NSString *kDSButtonAssociatedObjectKey = @"mobi.dogstar.buttons";
static NSString *kDSDismissalActionKey = @"mobi.dogstar.dismissal_action";


@implementation UIActionSheet (Blocks)

-(id)initWithTitle:(NSString *)inTitle cancelButtonItem:(DSButtonItem *)inCancelButtonItem destructiveButtonItem:(DSButtonItem *)inDestructiveItem otherButtonItems:(DSButtonItem *)inOtherButtonItems, ... {

    if ((self = [self initWithTitle:inTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil])) {

        NSMutableArray *buttonsArray = [NSMutableArray array];
        
        DSButtonItem *eachItem;
        va_list argumentList;
        if (inOtherButtonItems) {

            [buttonsArray addObject: inOtherButtonItems];
            va_start(argumentList, inOtherButtonItems);
            while ((eachItem = va_arg(argumentList, DSButtonItem *))) {

                [buttonsArray addObject: eachItem];
            }
            va_end(argumentList);
        }
        
        for (DSButtonItem *item in buttonsArray) {

            [self addButtonWithTitle:item.label];
        }
        
        if (inDestructiveItem) {

            [buttonsArray addObject:inDestructiveItem];
            NSInteger destIndex = [self addButtonWithTitle:inDestructiveItem.label];
            [self setDestructiveButtonIndex:destIndex];
        }

        if (inCancelButtonItem) {

            [buttonsArray addObject:inCancelButtonItem];
            NSInteger cancelIndex = [self addButtonWithTitle:inCancelButtonItem.label];
            [self setCancelButtonIndex:cancelIndex];
        }
        
        objc_setAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey, buttonsArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return self;
}

- (NSInteger)addButtonItem:(DSButtonItem *)item {

    NSMutableArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey);
	
	NSInteger buttonIndex = [self addButtonWithTitle:item.label];
	[buttonsArray addObject:item];
	
	return buttonIndex;
}

- (void)setDismissalAction:(DSButtonItemAction)dismissalAction {

    objc_setAssociatedObject(self, (__bridge const void *)kDSDismissalActionKey, nil, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, (__bridge const void *)kDSDismissalActionKey, dismissalAction, OBJC_ASSOCIATION_COPY);
}

- (DSButtonItemAction)dismissalAction {

    return objc_getAssociatedObject(self, (__bridge const void *)kDSDismissalActionKey);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    // Action sheets pass back -1 when they're cleared for some reason other than a button being
    // pressed.
    if (buttonIndex >= 0)
    {
        NSArray *buttonsArray = objc_getAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey);
        DSButtonItem *item = [buttonsArray objectAtIndex:buttonIndex];
        if (item.action)
            item.action();
    }
    
    if (self.dismissalAction) self.dismissalAction();
    
    objc_setAssociatedObject(self, (__bridge const void *)kDSButtonAssociatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge const void *)kDSDismissalActionKey, nil, OBJC_ASSOCIATION_COPY);
}

@end

