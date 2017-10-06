//
//  DSTime.h
//  Dogstar Engine 2.0.14
//
//  Created by Richard Henry on 01/01/2014.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//


typedef int64_t DSTime;

// Conversion constants
extern const DSTime kDSTimeToMicroseconds;
extern const DSTime kDSTimeToMilliseconds;
extern const DSTime kDSTimeToSeconds;

// Convenience constants
extern const DSTime kDSTimeZero;


//
//  DSTimer class interface
//
//  High resolution timing services
//

@interface DSTimer : NSObject

// Class messages for getting current time
+ (DSTime)nanoTime;
+ (DSTime)microTime;
+ (DSTime)milliTime;

// Sleep current thread
+ (void)sleep:(DSTime)nanos;

// Timer control
- (void)reset;

@property(nonatomic, readonly) DSTime time;

@end
