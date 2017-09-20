//
//  SLActor.h
//  ShaderLab
//
//  Created by Richard Henry on 26/12/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//


@interface DSActor : NSObject

@property(nonatomic, copy) void(^tickFunction)(DSActor *actor);

- (void)tick;

@end

@interface SLActor : DSActor

@property(nonatomic, copy) NSString *slName;

@end
