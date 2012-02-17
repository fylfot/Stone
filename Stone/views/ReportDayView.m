//
//  ReportDayView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReportDayView.h"

static NSString * const kGradientImageName = @"report_gradient.png";

@interface ReportDayView ()

@property (nonatomic, strong, readonly) NSImage *gradientImage;

@end

@implementation ReportDayView

@synthesize label = _label;
@synthesize gradientImage = _gradientImage;

- (id)initWithLabel:(NSString *)label {
    self = [super initWithFrame:NSMakeRect(0, 0, 100, 100)];
    if (self) {
        _gradientImage = [NSImage imageNamed:kGradientImageName];
        _label = [[NSTextField alloc] initWithFrame:self.frame];
        [self.label setTitleWithMnemonic:label];
        self.label.editable = NO;
        self.label.bordered = NO;
        self.label.drawsBackground = NO;
        self.label.textColor = [NSColor whiteColor];
//        self.label.shadow = [[NSShadow alloc] init];
//        self.label.shadow.shadowColor = [NSColor darkGrayColor];
//        self.label.shadow.shadowBlurRadius = 16.0f;
        self.label.font = [NSFont systemFontOfSize:16];
        [self addSubview:self.label];
        self.label.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    }
    return self;
}


- (void)layout {
    self.label.font = [NSFont systemFontOfSize:((NSInteger)self.frame.size.height) / 2];
    self.label.frame = NSMakeRect(10, 10, self.frame.size.width - 20, self.frame.size.height - 20);
    [super layout];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [_gradientImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
    /*
    [[NSColor colorWithDeviceRed:FRAND() green:FRAND() blue:FRAND() alpha:1] setFill];
    NSRectFill(dirtyRect);
     */
}

@end
