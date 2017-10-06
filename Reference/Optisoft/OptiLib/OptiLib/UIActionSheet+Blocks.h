//
//  UIActionSheet+Blocks.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSButtonItem.h"


@interface UIActionSheet (Blocks) <UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)inTitle cancelButtonItem:(DSButtonItem *)inCancelButtonItem destructiveButtonItem:(DSButtonItem *)inDestructiveItem otherButtonItems:(DSButtonItem *)inOtherButtonItems, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButtonItem:(DSButtonItem *)item;

@property (copy, nonatomic) DSButtonItemAction dismissalAction;

@end
