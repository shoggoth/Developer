//
//  DSFactory.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


//
//  interface DSFactory
//
//  A generic object factory.
//  
//  Objects to be created can be specified by their class or by the name of their class.
//  
//  Recycled objects can optionally be sent to a recycling store which is organised by class.
//  If an object of a certain class is requested from the factory, the store will first
//  be checked and supplied if found.
//

@interface DSFactory : NSObject

- (id)supplyObjectOfClass:(Class)classType;
- (id)supplyObjectOfClassNamed:(NSString *)className;
- (id)supplyObjectOfClassNamed:(NSString *)className withCompletionBlock:(id (^)(id suppliedObject))completionBlock;

- (void)enumerateActiveObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;
- (NSSet *)activeObjectsPassingTest:(BOOL (^)(id object, BOOL *stop))predicate;

- (void)recycle:(id)object;

@end
