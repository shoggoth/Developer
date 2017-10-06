//
//  IFPin.h
//  MappingTest
//
//  Created by Richard Henry on 18/09/2012.
//  Copyright (c) 2012 Smashing Ideas. All rights reserved.
//


@class MapLocation;
@class IFPinView;

@protocol IFPin <NSObject>

@property (weak) IFPinView  *view;
@property CGPoint pos;

@end


@interface IFPin : NSObject <IFPin>

@property (weak) MapLocation *location;

@end


@interface IFPinGroup : NSObject <IFPin>

@property (strong) NSMutableArray *pins;

- (void)recalculateAveragePosition;

@end

extern BOOL isPinMultiple(id <IFPin> pin);