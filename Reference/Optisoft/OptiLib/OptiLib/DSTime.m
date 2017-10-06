//
//  DSTime.m
//  Dogstar Engine 2.0.14
//
//  Created by Richard Henry on 01/01/2014.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTime.h"

#if TARGET_OS_IPHONE
#import <mach/mach_time.h>

static mach_timebase_info_data_t machTimebaseInfo;
static double gTimebaseConvert = 0.0;

#endif


// Conversion constants
const DSTime kDSTimeToMicroseconds = 1000LL;
const DSTime kDSTimeToMilliseconds = 1000000LL;
const DSTime kDSTimeToSeconds = 1000000000LL;

// Convenience constants
const DSTime kDSTimeZero = 0;

// Startup base time
static uint64_t gDSBaseTime = 0;


@implementation DSTimer {

    DSTime          baseTime;
}

+ (void)initialize {

#if TARGET_OS_IPHONE
    mach_timebase_info(&machTimebaseInfo);
    gDSBaseTime = mach_absolute_time();
    gTimebaseConvert = (double)machTimebaseInfo.numer / (double)machTimebaseInfo.denom;
#else
    gDSBaseTime = (DSTime)UnsignedWideToUInt64(UpTime());
#endif
}

- (instancetype)init {

    if ((self = [super init])) {

        // Initialise timebase
        baseTime = [DSTimer nanoTime];
    }

    return self;
}

#pragma mark Time access

+ (DSTime)nanoTime {
    
#if TARGET_OS_IPHONE
    uint64_t timeNow = mach_absolute_time() - gDSBaseTime;
        
    timeNow *= gTimebaseConvert;
#else
    DSTime timeNow = (DSTime)UnsignedWideToUInt64(UpTime()) - gDSBaseTime;
#endif
    
    assert((DSTime)timeNow > 0);
    
    return timeNow;
}

+ (DSTime)microTime {
    
    return [DSTimer nanoTime] / kDSTimeToMicroseconds;
}

+ (DSTime)milliTime {
    
    return [DSTimer nanoTime] / kDSTimeToMilliseconds;
}

#pragma mark Thread sleep

+ (void)sleep:(DSTime)t {
    
    struct timespec         ts;
    int64_t                 seconds = t / kDSTimeToSeconds;
    int64_t                 nanos   = t % kDSTimeToSeconds;
    
    ts.tv_sec  = (long)seconds;
    ts.tv_nsec = (long)nanos;
    
    nanosleep(&ts, NULL);
}

#pragma mark Timer control

- (void)reset { baseTime = [DSTimer nanoTime]; }

#pragma mark Properties

- (DSTime)time { return [DSTimer nanoTime] - baseTime; }

@end
