//
//  main.m
//  IndexPath
//
//  Created by Richard Henry on 19/11/2013.
//  Copyright (c) 2013 Optisoft. All rights reserved.
//


int main(int argc, const char * argv[]) {

    @autoreleasepool {

        // Prepare a dictionary for indexing
        // We'll use a string for the key and then arrays with multiple levels
        NSDictionary *dict = @{ @"value" : @31337,
                                @"array" : @[ @"one", @2, @"three", @4, @"five" ],
                                @"nest"  : @[ @[ @"00", @"01" ], @[ @"10", @"11" ] ],
                                @"tree"  : @[ @"0 - [0][0]",
                                              @[ @"1 - [0][0]", @"1 - [0][1]", @"1 - [0][2]" ],
                                              @[ @"2 - [1][0]", @"2 - [1][1]", @"2 - [1][2]",
                                                 @[@"3 - [2][0]", @"2 - [2][1]", @"2 - [2][2]"]]
                                              ]
                                };
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:0];

        NSLog(@"Object = %@", dict[@"value"]);
        NSLog(@"Object = %@", dict[path]);
        //NSLog(@"Object = %@", dict[@"nest"][path]);
    }

    return 0;
}

