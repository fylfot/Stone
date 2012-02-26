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
static const NSRect kInformationRect = {{-200, -200}, {192, 64}};

@implementation ReportView

@synthesize dayViews = _dayViews;
@synthesize heightOfDayView = _heightOfDayView;
@synthesize baseOffset = _baseOffset;
@synthesize informationView = _informationView;
@synthesize area = _area;
@synthesize previousFrame = _previousFrame;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSDate *today = [NSDate date];
        _dayViews = [NSArray arrayWithObjects:
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-6 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-5 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-4 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-3 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-2 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-1 * kSecondsInDay]],
          [[ReportDayView alloc] initWithDate:[today dateByAddingTimeInterval:-0 * kSecondsInDay]],
        nil];
        
        for (NSView *view in self.dayViews) {
            [self addSubview:view];
            view.autoresizingMask = NSViewHeightSizable;
        }
        
        _informationView = [[NSTextField alloc] initWithFrame:kInformationRect];

        self.informationView.editable = NO;
        self.informationView.bordered = NO;
//        self.informationView.drawsBackground = NO;
        self.informationView.textColor = [NSColor whiteColor];
        self.informationView.backgroundColor = [NSColor blackColor];//[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.6f];
        self.informationView.font = [NSFont systemFontOfSize:12];
        
        [self addSubview:self.informationView];
        
    }
    
    return self;
}

// WARNING! Private method _updateTrackingAreas exist!
- (void)_myUpdateTrackingArea {
    if (self.area) {
        [self removeTrackingArea:self.area];
    }
    _area = [[NSTrackingArea alloc] initWithRect:self.frame 
                                                        options:NSTrackingMouseMoved + NSTrackingActiveInKeyWindow
                                                          owner:self
                                                       userInfo:nil];
    [self addTrackingArea:self.area];
}

- (void)layout {
    if (_previousFrame.size.width != self.frame.size.width || _previousFrame.size.height != self.frame.size.height) {
        _previousFrame = self.frame;
        _heightOfDayView = (NSInteger)(self.frame.size.height / kNumberOfDaysInWeek);
        _baseOffset = (NSInteger)(self.frame.size.height - kNumberOfDaysInWeek * _heightOfDayView);
        
        for (NSInteger i = 0; i < kNumberOfDaysInWeek; i++) {
            ((NSView *)[self.dayViews objectAtIndex:i]).frame = NSMakeRect(0, _baseOffset + _heightOfDayView * (kNumberOfDaysInWeek - i - 1), self.frame.size.width, _heightOfDayView);
        }
        [self _myUpdateTrackingArea];
    }
    [super layout];
}

- (void)_updateInformationPanel:(NSString *)information atPosition:(CGPoint)point {
    if (information && ![information isEqualToString:[self.informationView stringValue]]) {
        [self.informationView setTitleWithMnemonic:information];   
    }
    if (information) {
        self.informationView.frame = CGRectMake(point.x, point.y, kInformationRect.size.width, kInformationRect.size.height);
    } else {
        self.informationView.frame = kInformationRect;
    }
}


- (void)mouseMoved:(NSEvent *)theEvent {
    CGPoint l = [theEvent locationInWindow];
    NSInteger i = (NSInteger)(l.y / _heightOfDayView);
    if (i >= 0 && i < kNumberOfDaysInWeek) {
        NSString *info = [[self.dayViews objectAtIndex:kNumberOfDaysInWeek - i - 1] infoForX:l.x];
        if (info) {
            [self _updateInformationPanel:info atPosition:l];
        } else {
            [self _updateInformationPanel:nil atPosition:CGPointZero];
        }
    }
}


@end
