//
//  ReportPeriodView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 18.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportPeriodView.h"
#import "TimePeriod.h"

@implementation ReportPeriodView

@synthesize color = _color;
@synthesize label = _label;
@synthesize period = _period;

- (void)setColor:(NSColor *)color {
    _color = color;
    CGFloat f;
    [self.color getHue:nil saturation:&f brightness:nil alpha:nil];
    if (f > kColorBrightLimit) {
        self.label.textColor = [NSColor whiteColor];
    } else {
        self.label.textColor = [NSColor blackColor];
    }
}

- (id)initWithColor:(NSColor *)color {
    self = [super init];
    if (self) {
        _color = color;
        _label = [[NSTextField alloc] initWithFrame:self.frame];
        self.label.editable = NO;
        self.label.bordered = NO;
        self.label.drawsBackground = NO;
        self.label.textColor = [NSColor blackColor];
        self.label.font = [NSFont systemFontOfSize:16];
        self.label.alignment = NSCenterTextAlignment;
        [self addSubview:self.label];
        self.label.autoresizingMask = NSViewHeightSizable;
    }
    
    return self;
}

- (void)layout {
    self.label.font = [NSFont systemFontOfSize:((NSInteger)self.frame.size.height) / 2];
    self.label.frame = NSMakeRect(10, 10, self.frame.size.width - 20, self.frame.size.height - 20);
    [super layout];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.color set];
    NSRectFill(dirtyRect);
}

@end
