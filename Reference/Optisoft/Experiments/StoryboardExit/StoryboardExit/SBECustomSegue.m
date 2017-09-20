//
//  SECustomSegue.m
//  StoryboardExit
//
//  Created by Optisoft Ltd on 14/10/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import "SBECustomSegue.h"


@implementation SBECustomSegue

- (void)perform {
    
    NSLog(@"Segue with source %@ destination %@ unwind %d", self.sourceViewController, self.destinationViewController, self.unwind);
    
    UIViewController *src = self.sourceViewController;
    UIViewController *dst = self.destinationViewController;
    
    src.view.transform = CGAffineTransformMakeTranslation(0, 0);
    dst.view.transform = CGAffineTransformMakeTranslation(0, -480);
    
    [UIView animateWithDuration:2.0 animations:^ {
    
        src.view.transform = CGAffineTransformMakeTranslation(0, 480);
        dst.view.transform = CGAffineTransformMakeTranslation(0, 0);
        
    } completion:^(BOOL finished) {
        
        [src presentViewController:dst animated:NO completion:^{ NSLog(@"Segue perform complete"); }];
    }];
}

@end
