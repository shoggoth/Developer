//
//  DSRandom.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


//
//  interface DSRandom
//
//  Generates random numbers. Auto-seeding on first use.
//  Uses the standard c lib. rand() function.
//

@interface DSRandom : NSObject

// Random integers
+ (unsigned long)random;
+ (unsigned long)randomUintBetween:(unsigned int)low and:(unsigned int)high;
+ (int)randomIntBetween:(int)low and:(int)high;

// Random floats
+ (float)randomFloat;
+ (float)randomFloatBetween:(float)low and:(float)high;

@end
