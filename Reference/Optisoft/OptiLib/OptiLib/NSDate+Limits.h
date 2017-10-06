//
//  NSDate+Limits.h
//  OptiLib
//
//  Created by Richard Henry on 28/07/2015.
//  Copyright (c) 2015 Optisoft. All rights reserved.
//

@import Foundation;

@interface NSDate (Limits)

- (NSDate *)firstDayOfYear;
- (NSDate *)lastDayOfYear;

- (NSDate *)firstDayOfMonth;
- (NSDate *)lastDayOfMonth;

- (NSDate *)firstDayOfWeek;
- (NSDate *)lastDayOfWeek;

- (NSDate *)today;
- (NSDate *)tomorrow;

@end
