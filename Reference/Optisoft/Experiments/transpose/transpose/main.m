//
//  main.m
//  transpose
//
//  Created by Optisoft Ltd on 25/09/2013.
//  Copyright (c) 2013 Optisoft Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

static void print_usage(void);


int main(int argc, const char *argv[]) {

    @autoreleasepool {
        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        if (arguments.count != 4) { print_usage(); return -1; }
        
        float sph  = [[arguments objectAtIndex:1] floatValue];
        float cyl  = [[arguments objectAtIndex:2] floatValue];
        float axis = [[arguments objectAtIndex:3] floatValue];
        
        sph += cyl;
        cyl = -cyl;
        
        if (cyl > 0) axis -= 90; else axis += 90;
        
        NSLog(@"sph: %.2f cyl: %.2f axis: %.2f (%@ cyl form)", sph, cyl, axis, (cyl > 0) ? @"Plus" : @"Minus");
    }
    
    return 0;
}

void print_usage(void) {
    
    NSLog(@"Usage : transpose sphere cyl axis");
}