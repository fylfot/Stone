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

@interface AppDelegate ()

@property (nonatomic, strong, readonly) NSStatusItem *systemTray;
@property (nonatomic, strong, readonly) NSMenu *menu;
@property (nonatomic, strong, readonly) Zone *currentStone;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, strong, readonly) NSMenuItem *stopStoneItem;

- (void)_reloadData;
- (void)_stopStone;
- (void)_makeATickUpdate:(id)sender;

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
    self.systemTray.image = [NSImage imageNamed:kStoneImageName];
//    self.systemTray.target = self;
//    self.systemTray.action = @selector(systemTrayClicked:);
    self.systemTray.alternateImage = [NSImage imageNamed:kStoneImageHighlightedName];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [Zone loadApplicationData];
    
    srandom((unsigned int)time(NULL));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeNameOfZone:) name:kZoneNameChanged object:nil];    

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
    _startDate = [NSDate date];
    [self _stopStone];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(_makeATickUpdate:) userInfo:nil repeats:YES];
    _currentStone = [[Zone availableZones] objectAtIndex:menuItem.tag];
    [self.currentStone startPeriod];
    [self _makeATickUpdate:nil];
    self.stopStoneItem.action = @selector(_stopStone);
}

- (void)_stopStone {
    [_timer invalidate];
    _timer = nil;
    self.systemTray.title = @"";
    if (self.currentStone) {
        [self.currentStone stopPeriod];
    }
    self.stopStoneItem.action = nil;
}

- (void)_makeATickUpdate:(id)sender {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
    self.systemTray.title = FormatInterval(interval, NO);
}

- (void)openReports:(NSMenuItem *)menuItem {
    [self.reports.contentView setNeedsLayout:YES];
    [self.reports.contentView layoutSubtreeIfNeeded];
    [self.reports makeKeyAndOrderFront:nil];
}

- (void)openPreferences:(NSMenuItem *)menuItem {
    [self.window makeKeyAndOrderFront:nil];
}

- (void)killApplication:(NSMenuItem *)menuItem {
    [[NSApplication sharedApplication] terminate:menuItem];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self _stopStone];
    [Zone saveApplicationData];
}

@end
