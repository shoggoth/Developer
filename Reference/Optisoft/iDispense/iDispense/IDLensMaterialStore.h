//
//  IDLensMaterialStore.h
//  iDispense
//
//  Created by Richard Henry on 18/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLens.h"

//
//  interface IDLensMaterialStore
//
//  Unused in the current implementation.
//

@interface IDLensMaterialStore : NSObject

+ (instancetype)defaultLensMaterialStore;

- (NSUInteger)materialCountForFilterIndex:(NSInteger)index;

- (NSString *)materialNameForFilterIndex:(NSInteger)filterIndex index:(NSInteger)index;
- (IDLensMaterial)materialForFilterIndex:(NSInteger)filterIndex index:(NSInteger)index;

@end
