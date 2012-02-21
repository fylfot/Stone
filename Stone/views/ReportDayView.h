//
//  ReportDayView.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ReportDayView : NSView

@property (nonatomic, strong, readonly) NSTextField *label;
@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, strong) NSArray *zonePeriods;

- (id)initWithDate:(NSDate *)date;
- (NSString *)infoForX:(CGFloat)x;

@end
