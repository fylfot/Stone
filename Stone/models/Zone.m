//
//  Zone.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Zone.h"
#import "TimePeriod.h"
#import "NSDate+Motive.h"

static NSString * const kNameKey = @"kNameKey";
static NSString * const kColorName = @"kColorName";
static NSString * const kPeriodsName = @"kPeriodsName";
static NSString * const kDocumentFileName = @"stones.dat";


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

+ (NSArray *)periodsForDate:(NSDate *)date {
    NSDate *beginOfDate = [date startOfDay];
    NSDate *endOfDate = [beginOfDate dateByAddingTimeInterval:kSecondsInDay - 1];
    
    NSMutableArray *periods = [[NSMutableArray alloc] init];
    for (Zone *zone in [self _allZones]) {
        for (TimePeriod *period in zone.periods) {
            if ([period inDates:beginOfDate endDate:endOfDate]) {
                [periods addObject:period];
            }
        }
    }
    return periods;
}

+ (void)loadApplicationData {
    
    // COPY & PASTE!
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *applicationDirPath = [documentsDirectory stringByAppendingPathComponent:kApplicationName];
    NSString *applicationDataFilePath = [applicationDirPath stringByAppendingPathComponent:kDocumentFileName];
    if (![[NSFileManager defaultManager] isReadableFileAtPath:applicationDataFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:applicationDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:applicationDataFilePath contents:[NSData data] attributes:nil];
        __availableZones = [NSMutableArray array];
    } else {
    
        NSArray *root = [NSKeyedUnarchiver unarchiveObjectWithFile:applicationDataFilePath];
    
        __availableZones = [NSMutableArray arrayWithArray:[root objectAtIndex:0]];
    }
}

+ (void)saveApplicationData {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *applicationDataFilePath = [[documentsDirectory  stringByAppendingPathComponent:kApplicationName] stringByAppendingPathComponent:kDocumentFileName];
    
    [NSKeyedArchiver archiveRootObject:[NSArray arrayWithObject:__availableZones] toFile:applicationDataFilePath];
}

- (void)_calculateCaches {
    NSInteger interval = 0;
    
    for (TimePeriod *period in self.periods) {
        interval = period.rawInterval;
    }
    
    //NSLog(@">>> %ld", interval);
    self.summaryIntervalToday = interval;
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:kZoneNameChanged object:self];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:kNameKey];
        _color = [coder decodeObjectForKey:kColorName];
        _periods = [coder decodeObjectForKey:kPeriodsName];
        
        for (TimePeriod *period in self.periods) {
            period.zone = self;
        }
        
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
    [self saveApplicationData]; // Sometimes crashes
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
    [self stopPeriod];
    _currentPeriod = [[TimePeriod alloc] init];
    [self.currentPeriod start];
    [self.periods addObject:self.currentPeriod];
    self.currentPeriod.zone = self;
}

- (void)stopPeriod {
    [self.currentPeriod stop];
    _currentPeriod = nil;
    [self _calculateCaches];
}

- (NSString *)description {
    return self.name;
}


@end
