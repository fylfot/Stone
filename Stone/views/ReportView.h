//
//  ReportView.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ReportView : NSView

@property (nonatomic, strong, readonly) NSArray *dayViews;
@property (assign) NSInteger heightOfDayView;
@property (assign) NSInteger baseOffset;
@property (nonatomic, strong, readonly) NSTextField *informationView;
@property (nonatomic, strong, readonly) NSTrackingArea *area;
@property (assign) NSRect previousFrame;

@end
