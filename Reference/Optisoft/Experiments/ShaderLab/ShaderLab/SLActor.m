//
//  SLActor.m
//  ShaderLab
//
//  Created by Richard Henry on 26/12/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//

#import "SLActor.h"

@implementation DSActor

- (void)tick { if (self.tickFunction) { _tickFunction(self); } }

@end
    
@implementation SLActor

@end
