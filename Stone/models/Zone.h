//
//  Zone.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimePeriod;
@interface Zone : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong, readonly) NSMutableArray *periods;
@property (nonatomic, strong, readonly) TimePeriod *currentPeriod;

+ (NSArray *)availableZones;
+ (void)addNewZone;
- (void)startPeriod;
- (void)stopPeriod;

@end
