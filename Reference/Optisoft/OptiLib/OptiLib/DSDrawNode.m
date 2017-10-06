//
//  DSDrawNode.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSDrawNode.h"
#import "DSDrawContext.h"


#pragma mark Draw node

@implementation DSDrawNode

- (id)init {
    
    if ((self = [super init])) {
        
        child = group = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    self.child = nil;
    self.group = nil;
    
    [super dealloc];
}

#pragma mark Drawing functions

- (void)draw:(DSDrawContext *)context {
    
    [child draw:context];
    [group draw:context];
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | child: %@ group: %@>", [self class], (unsigned)self, child, group];
}

#pragma mark Properties

@synthesize child, group;

@end

#pragma mark - Transformation node

@implementation DSTransformNode

@synthesize transform;
@synthesize cullRadius;

- (void)dealloc {
    
    self.transform = nil;
    
    [super dealloc];
}

#pragma mark Drawing functions

- (void)draw:(DSDrawContext *)context {
    
    if (child) {
        
        // Get the context's current transform
        DS4DMatrix oldTransform = context.transformMatrix;
        
        // Get this node's transform
        DS4DMatrix ourTransform = transform.transformMatrix;
        
        // Check if this transform needs to be culled
        if (!context.frustumCulling || cullRadius == 0.0 || [context frustumContainsSphereAtPos:DS4DMatrixGetTranslate(&ourTransform) radius:cullRadius]) {
            
            // Multiply by our node's transform
            context.transformMatrix = DS4DMatrixMultiply(&oldTransform, &ourTransform);
            
            // Draw the children of this node with the transform applied
            [child draw:context];
            
            // Restore the previous transform
            context.transformMatrix = oldTransform;
        }
    }
    
    // Draw the group (not affected by this transform)
    [group draw:context];
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | trans: %@>", [self class], (unsigned)self, transform];
}

@end

#pragma mark - Multi-draw node

@implementation DSMultiDrawNode

- (id)init {
    
    if ((self = [super init])) {
        
        transformArray = [NSMutableArray new];
        assert(transformArray);
    }
    
    return self;
}

- (void)dealloc {
    
    [transformArray release];
    
    [super dealloc];
}

#pragma mark Drawing functions

- (void)draw:(DSDrawContext *)context {
    
    if (child) {
        
        // Get the context's current transform
        DS4DMatrix oldTransform = context.transformMatrix;
        
        for (DSTransform *transform in transformArray) {
            
            // Multiply by the new transform
            DS4DMatrix newTransform = transform.transformMatrix;
            context.transformMatrix = DS4DMatrixMultiply(&oldTransform, &newTransform);
            
            // Draw the children of this node with the transform applied
            [child draw:context];
        }
        
        // Restore the previous transform
        context.transformMatrix = oldTransform;
    }
    
    // Draw the group (not affected by this transform)
    [group draw:context];
}

#pragma mark Transform storage

- (void)addTransform:(DSTransform *)d {
    
    [transformArray addObject:d];
}

- (void)remTransform:(DSTransform *)d {
    
    [transformArray removeObject:d];
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | array: %@>", [self class], (unsigned)self, transformArray];
}

@end

#pragma mark - Array draw node

@implementation DSDrawArrayNode

- (id)init {
    
    if ((self = [super init])) {
        
        drawArray = [NSMutableArray new];
        assert(drawArray);
    }
    
    return self;
}

- (void)dealloc {
    
    [drawArray release];
    
    [super dealloc];
}

#pragma mark Drawing functions

- (void)draw:(DSDrawContext *)context {
    
    [drawArray makeObjectsPerformSelector:@selector(draw:) withObject:context];
}

#pragma mark Drawable object storage

- (void)addDrawable:(NSObject <DSDrawable> *)d {
    
    [drawArray addObject:d];
}

- (void)remDrawable:(NSObject <DSDrawable> *)d {
    
    [drawArray removeObject:d];
}

#pragma mark Object description

- (NSString*)description {
    
    return [NSString stringWithFormat:@"<%@: 0x%x | array: %@>", [self class], (unsigned)self, drawArray];
}

@end
