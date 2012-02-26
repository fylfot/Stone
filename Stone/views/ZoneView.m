//
//  ZoneView.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoneView.h"
#import "Zone.h"

@interface ZoneView ()

@property (nonatomic, strong, readonly) NSColor *backgroundColor;

- (void)_setColor:(NSColor *)color;
- (void)_setTitle:(NSString *)title;
- (void)_updateColor;
    
@end

@implementation ZoneView

@synthesize textField = _textField;
@synthesize backgroundColor = _backgroundColor;
@synthesize zone = _zone;

- (id)init {
    self = [super init];
    if (self) {
        _textField = [[NSTextField alloc] initWithFrame:self.bounds];
        self.textField.bezeled = NO;
        self.textField.drawsBackground = NO;
        self.textField.delegate = self;
        self.textField.selectable = NO;
        self.textField.editable = YES;
        self.textField.autoresizingMask =  NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:_textField];
        // Initialization code here.
    }
    
    return self;
}
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    return YES;
}
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    return YES;
}
- (BOOL)control:(NSControl *)control didFailToFormatString:(NSString *)string errorDescription:(NSString *)error {
    return  YES;
}
- (void)control:(NSControl *)control didFailToValidatePartialString:(NSString *)string errorDescription:(NSString *)error{
    NSLog(@"test");
}
- (BOOL)control:(NSControl *)control isValidObject:(id)obj {
    return YES;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    return YES;
}
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    return nil;
}

- (void)controlTextDidBeginEditing:(NSNotification *)aNotification {
    if([aNotification object] == self.textField) {
        self.textField.textColor = [NSColor blackColor];
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == self.textField) {
        self.zone.name = [self.textField stringValue];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    if([aNotification object] == self.textField) {
        [self _updateColor];
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:kZoneNameChanged object:self.zone];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
}

- (void)_updateColor {
    CGFloat f;
    [self.backgroundColor getHue:nil saturation:&f brightness:nil alpha:nil];
    if (f > kColorBrightLimit) {
        self.textField.textColor = [NSColor whiteColor];
    } else {
        self.textField.textColor = [NSColor blackColor];
    }
}

- (void)_setColor:(NSColor *)color {
    _backgroundColor = color;
    [self _updateColor];
}

- (void)_setTitle:(NSString *)title {
    [self.textField setTitleWithMnemonic:title];
}

- (void)setZone:(Zone *)zone {
    _zone = zone;
    [self _setColor:zone.color];
    [self _setTitle:zone.name];
}

@end
