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

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

- (IBAction)addNewZone:(NSButton *)button;

@end
