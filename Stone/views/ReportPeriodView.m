//
//  ReportPeriodView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 18.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportPeriodView.h"
#import "TimePeriod.h"
#import "Zone.h"
#import "NSDate+Motive.h"

@implementation ReportPeriodView

@synthesize color = _color;
@synthesize period = _period;

- (id)initWithColor:(NSColor *)color {
    self = [super init];
    if (self) {
        _color = color;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.color set];
    NSRectFill(dirtyRect);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:\n %@ - %@", self.period.zone.name, [self.period.startDate stringWithFormat:@"HH:mm"], [self.period.endDate stringWithFormat:@"HH:mm"]];
}

@end
