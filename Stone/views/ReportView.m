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

static NSString * const kMondayString = @"Monday";
static NSString * const kTuesdayString = @"Tuesday";
static NSString * const kWednesdayString = @"Wednesday";
static NSString * const kThursdayString = @"Thursday";
static NSString * const kFridayString = @"Friday";
static NSString * const kSaturdayString = @"Saturday";
static NSString * const kSundayString = @"Sunday";

static const NSInteger kNumberOfDaysInWeek = 7; // Lol

@implementation ReportView

@synthesize dayViews = _dayViews;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _dayViews = [NSArray arrayWithObjects:
          [[ReportDayView alloc] initWithLabel:kMondayString],
          [[ReportDayView alloc] initWithLabel:kTuesdayString],
          [[ReportDayView alloc] initWithLabel:kWednesdayString],
          [[ReportDayView alloc] initWithLabel:kThursdayString],
          [[ReportDayView alloc] initWithLabel:kFridayString],
          [[ReportDayView alloc] initWithLabel:kSaturdayString],
          [[ReportDayView alloc] initWithLabel:kSundayString],
        nil];
        
        for (NSView *view in self.dayViews) {
            [self addSubview:view];
            view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
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
/*
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}
*/
@end
