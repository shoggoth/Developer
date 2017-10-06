//
//  IDMugshotDecoration.h
//  iDispense
//
//  Created by Richard Henry on 29/01/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//


//
//  interface IDMugshotDecoration
//
//  CALayer decorations can be applied with this class.
//

@interface IDMugshotDecoration : NSObject

+ (void)decorateImage:(UIImage *)image withFilmPerforationsAndAddToLayer:(CALayer *)layer;
+ (void)decorateImage:(UIImage *)image withSnapPerforationsAndAddToLayer:(CALayer *)layer;

@end
