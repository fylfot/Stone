//
//  TimePeriod.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimePeriod.h"

@implementation TimePeriod

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

+ (TimePeriod *)createTimePeriod {
    TimePeriod *result = [[TimePeriod alloc] init];
    [result start];
    return result;
}

- (void)start {
    if (_startDate) {
        [NSException exceptionWithName:kInmutableException reason:@"Start date already setted" userInfo:nil];
    }
    _startDate = [NSDate date];
}

- (void)stop {
    if (_endDate) {
        [NSException exceptionWithName:kInmutableException reason:@"End date already setted" userInfo:nil];
    }
    _endDate = [NSDate date];
}

@end
