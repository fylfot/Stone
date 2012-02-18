//
//  ReportPeriodView.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 18.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TimePeriod;
@interface ReportPeriodView : NSView

@property (nonatomic, strong, readonly) NSTextField *label;
@property (nonatomic, strong, readonly) NSColor *color;
@property (nonatomic, strong) TimePeriod *period;
- (id)initWithColor:(NSColor *)color;

@end
