//
//  main.m
//  foundationCL
//
//  Created by Optisoft Ltd on 24/09/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "MyExternalObject.h"

#import <Foundation/Foundation.h>


typedef void (^MyVoidReturningFunction)(void);
typedef NSString *(^MyStringReturningFunction)(void);

@interface MyObject : NSObject

@property (nonatomic, copy) MyVoidReturningFunction assignedPropertyFunc;

@end


@implementation MyObject

+ (void (^)(id))classMethodReturningBlock { return ^(NSObject *obj) { NSLog(@"classMethodReturningThisBlock:%@", obj);};};

- (id)init {
    
    if ((self = [super init])) {
        
        self.assignedPropertyFunc = ^{ NSLog(@"bar"); };
        self.assignedPropertyFunc = [self returnedFunc];
        self.assignedPropertyFunc = [self returnedFuncWithObject:self];
        self.assignedPropertyFunc = [self returnedFuncWithObject:self and:[self returnedStringFunc]()];
        self.assignedPropertyFunc = [self returnedFuncWithObject:self and:[self returnedStringFuncWithString:@"This is embedded"]()];
    }
    
    return self;
}

- (MyVoidReturningFunction)returnedFunc { return ^{ NSLog(@"This was returned from returnedFunc"); }; }

- (MyVoidReturningFunction)returnedFuncWithObject:(NSObject *)obj { return ^{ NSLog(@"This was returned from returnedFuncWithObject:%@", obj); }; }

- (MyVoidReturningFunction)returnedFuncWithObject:(NSObject *)ob1 and:(NSObject *)ob2 { return ^{ NSLog(@"This was returned from returnedFuncWithObject:%@ and:%@", ob1, ob2); }; }

- (MyStringReturningFunction)returnedStringFunc { return ^{ return [NSString stringWithFormat:@"This was returned from returnedStringFunc in %@", self]; }; }

- (MyStringReturningFunction)returnedStringFuncWithString:(NSString *)str { return ^{ return [NSString stringWithFormat:@"Embedding <<%@>>", str]; }; }

- (NSString *)description { return [NSString stringWithFormat:@"MyObject %p", self]; }

@end


int main(int argc, const char *argv[]) {
    
    @autoreleasepool {
        
        NSMutableArray *array = [NSMutableArray array];
        NSDictionary   *dict  = @{ @0 : @"Void", @1 : @"Unity", @2 : @"Duality", @3 : @"Magic", @5 : @"Chaos", @7 : @"Luck", @9 : @"Godhead" };
        
        for (int i = 0, c = 0; c < dict.count; i++) {
            
            id element = dict[@(i)];
            
            NSLog(@"%d represents %@", i, element);
            
            if (element) c++;
        }
        
        [array addObject:[MyObject new]];
        
        for (NSObject *object in array) NSLog(@"Object - %@", object);
        for (MyObject *object in array) object.assignedPropertyFunc();
        
        MyExternalObject *ext = [MyExternalObject new];
        [ext howMuchCanBeStripped];
        
        [MyObject classMethodReturningBlock](ext);
    }
    
    return 0;
}

