//
//  ItemBase+LockState.m
//  WOIAF
//
//  Created by Richard Henry on 22/10/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "ItemBase+LockState.h"
#import "IFCoreDataStore.h"


@implementation ItemBase (LockState)

- (BOOL)isPurchaseLocked { return (self.book.integerValue > [IFCoreDataStore defaultDataStore].lastBookAllowed); }

- (BOOL)isSpoilerLocked { return (self.book.integerValue > [IFCoreDataStore defaultDataStore].lastBookRead); }

@end
