//
//  DSFactory.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSFactory.h"


@implementation DSFactory {

    NSMutableSet            *active;
    NSMutableDictionary     *recycleDictionary;
}

- (instancetype)init {
    
    if ((self = [super init])) {
        
        recycleDictionary = [NSMutableDictionary new];
        active = [NSMutableSet new];
    }
    
    return self;
}

- (void)dealloc {
    
    recycleDictionary = nil;
    active = nil;
}

#pragma mark Factory object creation

- (id)supplyObjectOfClass:(Class)classType {
    
    id object = nil;
    
    // Look in the pool for objects of the class we want
    NSMutableSet *recycled = [recycleDictionary objectForKey:classType];
    
    if ([recycled count]) {
        
        // Move one of the objects found from the returned set to the active.
        object = [recycled anyObject];
        
        [recycled removeObject:object];
        
    } else {
        
        // Create and initialise a new object
        object = [classType new];
    }
    
    // Move object to the active list.
    assert(object);
    [active addObject:object];
    
    return object;
}

- (id)supplyObjectOfClassNamed:(NSString *)className {
    
    return [self supplyObjectOfClass:NSClassFromString(className)];
}

- (id)supplyObjectOfClassNamed:(NSString *)className withCompletionBlock:(id (^)(id suppliedObject))completionBlock {

    id obj = [self supplyObjectOfClassNamed:className];

    return completionBlock(obj);
}

#pragma mark Access

- (void)enumerateActiveObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block {

    [active enumerateObjectsUsingBlock:block];
}

- (NSSet *)activeObjectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate {

    return [active objectsPassingTest:predicate];
}

#pragma mark Recycling

- (void)recycle:(id)object {
    
    if ([active containsObject:object]) {
        
        Class objectClass = [object class];
        
        // Move the object from the active set to the returned.
        NSMutableSet *recycled = [recycleDictionary objectForKey:objectClass];
        
        if (!recycled) {
            
            recycled = [NSMutableSet new];
            assert(recycled);
            
            [recycleDictionary setObject:recycled forKey:(id <NSCopying>)objectClass];
        }
        
        [recycled addObject:object];
        [active removeObject:object];
    }
}

- (NSString*)description { return [NSString stringWithFormat:@"<%@: 0x%x | active: %@ recycled: %@>", [self class], (unsigned)self, active, recycleDictionary]; }

@end
