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

- (id)initWithLabel:(NSString *)label;

@end
