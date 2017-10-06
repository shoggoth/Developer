//
//  ItemBase+LockState.h
//  WOIAF
//
//  Created by Richard Henry on 22/10/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "ItemBase.h"


@interface ItemBase (LockState)

@property (readonly) BOOL isPurchaseLocked;
@property (readonly) BOOL isSpoilerLocked;

@end
