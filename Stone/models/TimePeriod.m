//
//  TimePeriod.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimePeriod.h"
#import "NSDate+Motive.h"

static NSString * const kStartDateKey = @"kStartDateKey";
static NSString * const kEndDateKey = @"kEndDateKey";

@implementation TimePeriod

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize rawInterval;

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

- (NSInteger)rawInterval {
    if (![_startDate isToday] && ![_endDate isToday]) {
        return 0; // don't calculate another days for raw view
    }
    return [_endDate timeIntervalSinceDate:_startDate];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _startDate = [coder decodeObjectForKey:kStartDateKey];
        _endDate = [coder decodeObjectForKey:kEndDateKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_startDate forKey:kStartDateKey];
    [coder encodeObject:_endDate forKey:kEndDateKey];
}

@end
