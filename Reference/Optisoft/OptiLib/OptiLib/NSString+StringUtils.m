//
//  NSString+StringUtils.m
//  OptiLib
//
//  Created by Richard Henry on 04/02/2014.
//  Copyright (c) 2014 Optisoft. All rights reserved.
//

#import "NSString+StringUtils.h"


@implementation NSString (StringUtils)

+ (NSString *)uniqueIdentifierString {

    // Create a CFUUID object - it knows how to create unique identifier strings
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);

    // Create a string from unique identifier
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);

    // Release the CFUUID object now that we have created a string from it.
    CFRelease(newUniqueID);

    return CFBridgingRelease(newUniqueIDString);
}

@end
