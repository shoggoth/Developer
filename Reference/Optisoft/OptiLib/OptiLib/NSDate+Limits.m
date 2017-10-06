//
//  NSDate+Limits.m
//  OptiLib
//
//  Created by Richard Henry on 28/07/2015.
//  Copyright (c) 2015 Optisoft. All rights reserved.
//

#import "NSDate+Limits.h"

@implementation NSDate (Limits)

- (NSDate *)firstDayOfYear {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];

    // First day of this year
    components.year = 1;

    return [[NSCalendar currentCalendar] dateFromComponents: components];

}

- (NSDate *)lastDayOfYear {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];

    // Zeroth day of the following year
    components.day = 0;
    components.month = 0;
    components.year = components.year + 1;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

- (NSDate *)firstDayOfMonth {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];

    // First day of this month
    components.day = 1;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

- (NSDate *)lastDayOfMonth {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];

    // Zeroth day of the following month
    components.day = 0;
    components.month = components.month + 1;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

- (NSDate *)firstDayOfWeek {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearForWeekOfYearCalendarUnit | NSYearCalendarUnit| NSMonthCalendarUnit| NSWeekCalendarUnit| NSWeekdayCalendarUnit fromDate:self];

    // First day of this week… Sunday is day 1 and so monday is day 2
    components.weekday = 2;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

- (NSDate *)lastDayOfWeek {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearForWeekOfYearCalendarUnit | NSYearCalendarUnit| NSMonthCalendarUnit| NSWeekCalendarUnit| NSWeekdayCalendarUnit fromDate:self];

    // Last day of this week
    components.weekday = 7;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

- (NSDate *)today {

    return [[NSCalendar currentCalendar] startOfDayForDate:self];
}

- (NSDate *)tomorrow {

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];

    // Add one day to find tomorrow at midnight.
    components.day = components.day + 1;

    return [[NSCalendar currentCalendar] dateFromComponents: components];
}

@end
