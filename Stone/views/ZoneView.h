//
//  ZoneView.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Zone;
@interface ZoneView : NSView <NSTextFieldDelegate>

@property (nonatomic, strong, readonly) NSTextField *textField;
@property (nonatomic, strong) Zone *zone;

@end
