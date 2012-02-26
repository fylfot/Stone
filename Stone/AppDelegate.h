//
//  AppDelegate.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *reports;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

- (void)startStone:(NSMenuItem *)menuItem;
- (IBAction)addNewZone:(NSButton *)button;
- (void)openReports:(NSMenuItem *)menuItem;
- (void)openPreferences:(NSMenuItem *)menuItem;
- (void)killApplication:(NSMenuItem *)menuItem;

@end
