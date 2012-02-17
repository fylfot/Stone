//
//  Zone.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Zone.h"
#import "TimePeriod.h"

@interface Zone ()

+ (NSMutableArray *)_allZones;
- (void)_registrate;

@end

@implementation Zone

@synthesize name = _name;
@synthesize color = _color;
@synthesize periods = _periods;
@synthesize currentPeriod = _currentPeriod;

static NSMutableArray *__availableZones = nil;
+ (NSMutableArray *)_allZones {
    if (!__availableZones) {
        __availableZones = [[NSMutableArray alloc] init];
    }
    return __availableZones;
}

+ (NSArray *)availableZones {
    return [NSArray arrayWithArray:[self _allZones]];
}

+ (void)addNewZone {
    [[[Zone alloc] init] _registrate];
}

- (void)_registrate {
    [[Zone _allZones] addObject:self];
    
    // TODO: sorting?
    
}

- (id)init {
    self = [super init];
    if (self) {
        self.name = kNewNameString;
        self.color = [NSColor colorWithDeviceRed:FRAND() green:FRAND() blue:FRAND() alpha:1];
        _periods = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startPeriod {
    _currentPeriod = [[TimePeriod alloc] init];
    [self.currentPeriod start];
    [self.periods addObject:self.currentPeriod];
}

- (void)stopPeriod {
    [self.currentPeriod stop];
    _currentPeriod = nil;
}

- (NSString *)description {
    return self.name;
}


@end
