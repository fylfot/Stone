//
//  ReportView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportView.h"
#import "Zone.h"
#import "ReportDayView.h"

static const NSInteger kNumberOfDaysInWeek = 7; // Lol

@implementation ReportView

@synthesize dayViews = _dayViews;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSDate *today = [NSDate date];
        _dayViews = [NSArray arrayWithObjects:
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-3 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-2 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-1 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:0 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:1 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:2 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:3 * kSecondsInDay]],
        nil];
        
        for (NSView *view in self.dayViews) {
            [self addSubview:view];
            view.autoresizingMask = NSViewHeightSizable;
        }
        
    }
    
    return self;
}

- (void)layout {
    NSInteger heightOfDayView = self.frame.size.height / kNumberOfDaysInWeek;
    NSInteger baseOffset = self.frame.size.height - kNumberOfDaysInWeek * heightOfDayView;
    
    for (NSInteger i = 0; i < kNumberOfDaysInWeek; i++) {
        ((NSView *)[self.dayViews objectAtIndex:i]).frame = NSMakeRect(0, baseOffset + heightOfDayView * (kNumberOfDaysInWeek - i - 1), self.frame.size.width, heightOfDayView);
    }
    [super layout];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
}

@end
