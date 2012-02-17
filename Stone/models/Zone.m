//
//  Zone.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Zone.h"
#import "TimePeriod.h"

static NSString * const kNameKey = @"kNameKey";
static NSString * const kColorName = @"kColorName";
static NSString * const kPeriodsName = @"kPeriodsName";
static const CGFloat kMinimalShowValue = 300;

@interface Zone ()

@property (assign) NSInteger summaryIntervalToday;

+ (NSMutableArray *)_allZones;
- (void)_registrate;
- (void)_calculateCaches;

@end

@implementation Zone

@synthesize name = _name;
@synthesize color = _color;
@synthesize periods = _periods;
@synthesize currentPeriod = _currentPeriod;
@synthesize summaryIntervalToday = _summaryIntervalToday;

static NSMutableArray *__availableZones = nil;
+ (NSMutableArray *)_allZones {
    if (!__availableZones) {
        __availableZones = [[NSMutableArray alloc] init];
    }
    return __availableZones;
}

+ (void)loadApplicationData {
    
    // COPY & PASTE!
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *applicationDataFilePath = [documentsDirectory stringByAppendingPathComponent:@"stones.dat"];
    
    NSArray *root = [NSKeyedUnarchiver unarchiveObjectWithFile:applicationDataFilePath];
    
    __availableZones = [NSMutableArray arrayWithArray:[root objectAtIndex:0]];
}

+ (void)saveApplicationData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *applicationDataFilePath = [documentsDirectory stringByAppendingPathComponent:@"stones.dat"];
    
    [NSKeyedArchiver archiveRootObject:[NSArray arrayWithObject:__availableZones] toFile:applicationDataFilePath];
}

- (void)_calculateCaches {
    NSInteger interval = 0;
    
    for (TimePeriod *period in self.periods) {
        interval = period.rawInterval;
    }
    
    self.summaryIntervalToday = interval;
    [[NSNotificationCenter defaultCenter] postNotificationName:kZoneNameChanged object:nil];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:kNameKey];
        _color = [coder decodeObjectForKey:kColorName];
        _periods = [coder decodeObjectForKey:kPeriodsName];
        _currentPeriod = nil;
        [self _calculateCaches];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:kNameKey];
    [coder encodeObject:_color forKey:kColorName];
    [coder encodeObject:_periods forKey:kPeriodsName];
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
    [self _calculateCaches];
}

- (NSString *)description {
    if (self.summaryIntervalToday < kMinimalShowValue) {
        return self.name;
    } else {
        return [NSString stringWithFormat:@"(%@) %@", FormatInterval(self.summaryIntervalToday, YES), self.name];
    }
}


@end
