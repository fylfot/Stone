//
//  TimePeriod.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Zone;
@interface TimePeriod : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (assign, readonly) NSInteger rawInterval;
@property (nonatomic, strong) Zone *zone;

+ (TimePeriod *)createTimePeriod;
- (void)start;
- (void)stop;
- (BOOL)inDates:(NSDate *)dateBegin endDate:(NSDate *)dateEnd;
- (NSInteger)intervalToBeginSinceDate:(NSDate *)date;
- (NSInteger)time;

@end
