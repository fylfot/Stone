//
//  ReportDayView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportDayView.h"
#import "NSDate+Motive.h"
#import "TimePeriod.h"
#import "Zone.h"
#import "ReportPeriodView.h"

static NSString * const kGradientImageName = @"report_gradient.png";

// Look http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns
static NSString * const kReportDayViewDateFormat = @"EEEE (dd/MM/yyyy)";

@interface ReportDayView ()

@property (nonatomic, strong, readonly) NSImage *gradientImage;
@property (nonatomic, strong, readonly) NSMutableArray *periodViews;

- (void)_recalculatePeriods;
- (void)_updatePeriods:(NSNotification *)notification;

@end

@implementation ReportDayView

@synthesize label = _label;
@synthesize gradientImage = _gradientImage;
@synthesize zonePeriods = _zonePeriods;
@synthesize date = _date;
@synthesize periodViews = _periodViews;

- (void)_updatePeriods:(NSNotification *)notification {
    [self _recalculatePeriods];
}

- (id)initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        _gradientImage = [NSImage imageNamed:kGradientImageName];
        _label = [[NSTextField alloc] initWithFrame:self.frame];
        _date = [[date startOfDay] dateByAddingTimeInterval:kLengthOf8HoursInSeconds];
        NSString *dayLabel = [[self.date stringWithFormat:kReportDayViewDateFormat] capitalizedString];
        [self.label setTitleWithMnemonic:dayLabel];
        self.label.editable = NO;
        self.label.bordered = NO;
        self.label.drawsBackground = NO;
        self.label.textColor = [NSColor whiteColor];
        self.label.font = [NSFont systemFontOfSize:16];
        [self addSubview:self.label];
        self.label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self _recalculatePeriods];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updatePeriods:) name:kReportsNeedUpdate object:nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_recalculatePeriods {
    
    for (ReportPeriodView *periodView in self.periodViews) {
        [periodView removeFromSuperview];
    }
    
    NSArray *periodsForDay = [Zone periodsForDate:self.date];
    _periodViews = [[NSMutableArray alloc] init];
    for (TimePeriod *period in periodsForDay) {
        ReportPeriodView *periodView = [[ReportPeriodView alloc] initWithColor:period.zone.color];
        periodView.autoresizingMask = NSViewHeightSizable;
        periodView.period = period;
        [self.periodViews addObject:periodView];
        [self addSubview:periodView];
    }
    
    [self setNeedsLayout:YES];
}


- (void)layout {
    self.label.font = [NSFont systemFontOfSize:((NSInteger)self.frame.size.height) / 2];
    self.label.frame = NSMakeRect(10, 10, self.frame.size.width - 20, self.frame.size.height - 20);
    
    CGFloat secondToPixelSize = self.frame.size.width / (CGFloat)kSecondsInWorkDay;
    
    for (ReportPeriodView *periodView in self.periodViews) {
        CGFloat x = [periodView.period intervalToBeginSinceDate:self.date] * secondToPixelSize;
        CGFloat w = [periodView.period time] * secondToPixelSize;
        
        if (w < 1) {
            w = 1;
        }
        
        periodView.frame = NSMakeRect(x, 2, (NSInteger)w, self.frame.size.height - 4);
    }
    
    [super layout];
}

- (void)drawRect:(NSRect)dirtyRect {
//    [NSGraphicsContext saveGraphicsState];
    [_gradientImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
//    [super drawRect:dirtyRect];
//    [NSGraphicsContext restoreGraphicsState];
}

- (NSString *)infoForX:(CGFloat)x {
    for (ReportPeriodView *periodView in self.periodViews) {
        if (periodView.frame.origin.x > x || periodView.frame.size.width + periodView.frame.origin.x < x) {
            continue;
        } else {
            return [periodView description];
        }
    }
    
    return nil;
}

@end
