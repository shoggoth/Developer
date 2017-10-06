//
//  IDLensMaterialStore.m
//  iDispense
//
//  Created by Richard Henry on 18/06/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDLensMaterialStore.h"
#import "IDLens.h"

@interface IDLensMaterialOption : NSObject

- (instancetype)initWithName:(NSString *)name refractiveIndex:(float)ri specificGravity:(float)sg minEdgeThickness:(float)me minCentreThickness:(float)mc;

@property(nonatomic) IDLensMaterial material;
@property(nonatomic, copy) NSString *name;

@end

@implementation IDLensMaterialOption

- (instancetype)initWithName:(NSString *)name refractiveIndex:(float)ri specificGravity:(float)sg minEdgeThickness:(float)me minCentreThickness:(float)mc {

    if ((self = [super init])) {

        // Initialisation
        self.name = name;

        self.material = (IDLensMaterial) { ri, sg, me, mc };
    }

    return self;
}

@end

@implementation IDLensMaterialStore {

    NSArray         *materials;
}

+ (instancetype)defaultLensMaterialStore {

    static IDLensMaterialStore *defaultLensMaterialStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        defaultLensMaterialStore = [IDLensMaterialStore new];
    });

    return defaultLensMaterialStore;
}

- (instancetype)init {

    if ((self = [super init])) {

        // Array initialisation
        NSArray *glass = @[
                           [[IDLensMaterialOption alloc] initWithName:@"1.5 " refractiveIndex:1.5 specificGravity:2.54 minEdgeThickness:3.0 minCentreThickness:3.1],
                           [[IDLensMaterialOption alloc] initWithName:@" 1.6 " refractiveIndex:1.6 specificGravity:2.54 minEdgeThickness:3.2 minCentreThickness:3.2],
                           [[IDLensMaterialOption alloc] initWithName:@" 1.7 " refractiveIndex:1.7 specificGravity:2.54 minEdgeThickness:3.4 minCentreThickness:3.3],
                           [[IDLensMaterialOption alloc] initWithName:@" 1.8 " refractiveIndex:1.8 specificGravity:2.54 minEdgeThickness:3.6 minCentreThickness:3.7],
                           [[IDLensMaterialOption alloc] initWithName:@" 1.9" refractiveIndex:1.9 specificGravity:2.54 minEdgeThickness:3.8 minCentreThickness:3.9]
                           ];
        NSArray *plastic = @[
                             [[IDLensMaterialOption alloc] initWithName:@"CR-39 " refractiveIndex:1.498 specificGravity:2.54 minEdgeThickness:2.99 minCentreThickness:3.99],
                             [[IDLensMaterialOption alloc] initWithName:@" 1.6 " refractiveIndex:1.6 specificGravity:2.41 minEdgeThickness:3.25 minCentreThickness:4.25],
                             [[IDLensMaterialOption alloc] initWithName:@" 1.67 " refractiveIndex:1.67 specificGravity:2.41 minEdgeThickness:3.34 minCentreThickness:4.34],
                             [[IDLensMaterialOption alloc] initWithName:@" 1.74" refractiveIndex:1.74 specificGravity:2.41 minEdgeThickness:3.48 minCentreThickness:4.48]
                              ];
        NSArray *poly = @[
                          [[IDLensMaterialOption alloc] initWithName:@"1.53 Trivex " refractiveIndex:1.53 specificGravity:2.54 minEdgeThickness:3.06 minCentreThickness:3.16],
                          [[IDLensMaterialOption alloc] initWithName:@" 1.59" refractiveIndex:1.59 specificGravity:2.54 minEdgeThickness:3.18 minCentreThickness:3.28]
                          ];

        materials = @[ plastic, poly, glass ];
        
    }

    return self;
}

- (NSUInteger)materialCountForFilterIndex:(NSInteger)filterIndex {

    return [materials[filterIndex] count];

}

- (NSString *)materialNameForFilterIndex:(NSInteger)filterIndex index:(NSInteger)index {

    IDLensMaterialOption *lensMaterial = materials[filterIndex][index];

    return lensMaterial.name;
}

- (IDLensMaterial)materialForFilterIndex:(NSInteger)filterIndex index:(NSInteger)index {

    if (filterIndex > materials.count) filterIndex = 0;

    NSArray *materialArray = materials[filterIndex];
    if (index > materialArray.count) index = 0;
    
    IDLensMaterialOption *lensMaterial = materials[filterIndex][index];

    return lensMaterial.material;
}

@end