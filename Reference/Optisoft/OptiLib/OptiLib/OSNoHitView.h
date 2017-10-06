//
//  OSNoHitView.h
//  OptiLib
//
//  Created by Richard Henry on 31/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//


typedef enum { kOSDontIgnoreHits, kOSIgnoreHitsUsingPointInsideTest, kOSIgnoreHitsUsingHitTest } OSHitIgnoreType;

@interface OSNoHitView : UIView

@property(nonatomic) OSHitIgnoreType hitIgnoreType;

@end
