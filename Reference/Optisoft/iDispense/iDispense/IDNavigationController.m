//
//  IDNavigationController.m
//  iDispense
//
//  Created by Richard Henry on 04/03/2014.
//  Copyright (c) 2014 Optisoft Ltd. All rights reserved.
//

#import "IDNavigationController.h"


@implementation IDNavigationController

- (BOOL)shouldAutomaticallyForwardRotationMethods { return YES; }

- (NSUInteger)supportedInterfaceOrientations{ return UIInterfaceOrientationMaskAll; }

@end
