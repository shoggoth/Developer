//
//  IFPin.m
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//

#import "IFPin.h"


@implementation IFPin

@synthesize view;
@synthesize pos;

- (id)init {
    
    if ((self = [super init])) {
        
        self.pos = CGPointMake(0, 0);
    }
    
    return self;
}

- (NSString *)description { return [NSString stringWithFormat:@"[%f, %f]", self.pos.x, self.pos.y]; }

@end


@implementation IFPinGroup

@synthesize view;
@synthesize pos;

- (id)init {
    
    if ((self = [super init])) {
        
        self.pos = CGPointMake(0, 0);
        
        self.pins = [NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    
    self.pins = nil;
}

- (void)recalculateAveragePosition {
    
    CGPoint         averagePos;
    
    for (IFPin *pin in self.pins) {
        
        averagePos.x += pin.pos.x;
        averagePos.y += pin.pos.y;
    }
    
    averagePos.x /= self.pins.count;
    averagePos.y /= self.pins.count;
    
    self.pos = averagePos;
}

- (NSString *)description { return [NSString stringWithFormat:@"[%f, %f %d in group]", self.pos.x, self.pos.y, self.pins.count]; }

@end

BOOL isPinMultiple(id <IFPin> pin) { return([pin isKindOfClass:[IFPinGroup class]]); }
