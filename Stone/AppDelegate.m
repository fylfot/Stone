//
//  AppDelegate.m
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Zone.h"
#import "ZoneView.h"
//#import <QuartzCore/QuartzCore.h>

@interface AppDelegate ()

@property (nonatomic, strong, readonly) NSStatusItem *systemTray;
@property (nonatomic, strong, readonly) NSMenu *menu;
@property (nonatomic, strong, readonly) Zone *currentStone;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, strong, readonly) NSMenuItem *stopStoneItem;
@property (nonatomic, strong, readonly) NSImage *trayIcon;

- (void)_reloadData;
- (void)_stopStone;
- (void)_makeATickUpdate:(id)sender;
- (void)_didChangeNameOfZone:(NSNotification *)notification;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize reports = _reports;
@synthesize menu = _menu;
@synthesize systemTray = _systemTray;
@synthesize tableView = _tableView;
@synthesize currentStone = _currentStone;
@synthesize startDate = _startDate;
@synthesize timer = _timer;
@synthesize stopStoneItem = _stopStoneItem;
@synthesize trayIcon = _trayIcon;

// http://www.cocoabuilder.com/archive/cocoa/64546-example-how-to-tint-an-image.html
+ (NSImage *)_coloredImage:(NSImage *)image color:(NSColor *)color {
    if (color) {
        NSImage *icon = [image copy];
        NSSize iconSize = [icon size];
        NSRect iconRect = { NSZeroPoint, iconSize };
        
        [icon lockFocus];
        [[color colorWithAlphaComponent:0.8f] set];
        NSRectFillUsingOperation(iconRect, NSCompositeSourceAtop);
        [icon unlockFocus];
        
        return icon;
    } else {
        return image;
    }
}

- (void)_createTrayBar  {
    NSZone *menuZone = [NSMenu menuZone];
    _menu = [[NSMenu allocWithZone:menuZone] init];
    NSMenuItem *menuItem;
    
    [self.menu addItem:[NSMenuItem separatorItem]];
    
    _stopStoneItem = [self.menu addItemWithTitle:kStopString action:nil keyEquivalent:@""];
    [self.stopStoneItem setTarget:self];
    
    menuItem = [self.menu addItemWithTitle:kReportsString action:@selector(openReports:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    menuItem = [self.menu addItemWithTitle:kPreferencesString action:@selector(openPreferences:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    menuItem = [self.menu addItemWithTitle:kQuitString action:@selector(killApplication:) keyEquivalent:@""];
    [menuItem setTarget:self];
    
    _systemTray = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.systemTray.menu = self.menu;
    self.systemTray.highlightMode = YES;
    self.systemTray.toolTip = kTooltipString;
    _trayIcon = [NSImage imageNamed:kStoneImageName];
    self.systemTray.image = self.trayIcon;
//    self.systemTray.target = self;
//    self.systemTray.action = @selector(systemTrayClicked:);
    self.systemTray.alternateImage = [NSImage imageNamed:kStoneImageHighlightedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Zone loadApplicationData];
    
    srandom((unsigned int)time(NULL));
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeNameOfZone:) name:kZoneNameChanged object:nil];    

    [self _createTrayBar];
    
    [self _reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ZoneView *zoneView = [[ZoneView alloc] init];
    Zone *zone = [tableView.dataSource tableView:tableView objectValueForTableColumn:tableColumn row:row];
    [zoneView setZone:zone];
    return zoneView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[Zone availableZones] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[Zone availableZones] objectAtIndex:row];
}

- (void)_didChangeNameOfZone:(NSNotification *)notification {
    NSArray *zones = [Zone availableZones];
    for (NSInteger i = 0; i < [zones count]; i++) {
        if ([zones objectAtIndex:i] == notification.object) {
            ((NSMenuItem *)[self.menu.itemArray objectAtIndex:i]).title = [notification.object description];
            break;
        }
    }
}

// Don't know how make it better
- (void)_recompileMenuItems {
    
    for (NSMenuItem *item in self.menu.itemArray) {
        if (item.isSeparatorItem) {
            break;
        }
             
        [self.menu removeItemAtIndex:0];       
    }
    
    NSMenuItem *menuItem;
    Zone *zone;
    NSArray *zones = [Zone availableZones];
    for (NSInteger i = 0; i < [zones count]; i++) {
        zone = [zones objectAtIndex:i];
        menuItem = [self.menu insertItemWithTitle:[zone description] action:@selector(startStone:) keyEquivalent:@"" atIndex:i];
        if (zone == _currentStone) {
            menuItem.image = self.systemTray.image;
        }
        menuItem.tag = i;
        [menuItem setTarget:self];
    }
}

- (void)_reloadData {
    [self.tableView reloadData];
    [self _recompileMenuItems];
}

- (IBAction)addNewZone:(NSButton *)button {
    [Zone addNewZone];
    [self _reloadData];
}

- (void)startStone:(NSMenuItem *)menuItem {
    Zone *selectedStone = [[Zone availableZones] objectAtIndex:menuItem.tag];
    if (self.currentStone == selectedStone) {
        return;
    }
    _startDate = [NSDate date];
    [self _stopStone];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(_makeATickUpdate:) userInfo:nil repeats:YES];
    _currentStone = selectedStone;
    [self.currentStone startPeriod];
    [self _makeATickUpdate:nil];
    self.stopStoneItem.action = @selector(_stopStone);
    self.systemTray.image = [AppDelegate _coloredImage:self.trayIcon color:self.currentStone.color];
    [self _recompileMenuItems];
}

- (void)_stopStone {
    [_timer invalidate];
    _timer = nil;
    self.systemTray.title = @"";
    if (self.currentStone) {
        [self.currentStone stopPeriod];
    }
    _currentStone = nil;
    self.stopStoneItem.action = nil;
    self.systemTray.image = self.trayIcon;
    [self _recompileMenuItems];
}

- (void)_makeATickUpdate:(id)sender {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    self.systemTray.title = FormatInterval(interval, NO);
}

- (void)openReports:(NSMenuItem *)menuItem {
    [self.reports.contentView setNeedsLayout:YES];
    [self.reports.contentView layoutSubtreeIfNeeded];
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:kReportsNeedUpdate object:nil];
//    [self.reports makeKeyAndOrderFront:nil];
    [self.reports orderFrontRegardless];
}

- (void)openPreferences:(NSMenuItem *)menuItem {
    [self.window orderFrontRegardless];//makeKeyAndOrderFront:nil];
}

- (void)killApplication:(NSMenuItem *)menuItem {
    [[NSApplication sharedApplication] terminate:menuItem];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self _stopStone];
    [Zone saveApplicationData];
}

@end
