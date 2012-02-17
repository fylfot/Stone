//
//  TimePeriod.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimePeriod : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (assign, readonly) NSInteger rawInterval;

+ (TimePeriod *)createTimePeriod;
- (void)start;
- (void)stop;

@end
