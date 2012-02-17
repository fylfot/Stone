//
//  Constants.h
//  Stone
//
//  Created by Stanislav Cherednichenko on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Stone_Constants_h
#define Stone_Constants_h

static NSString * const kReportsString = @"Reports";
static NSString * const kPreferencesString = @"Preferences";
static NSString * const kQuitString = @"Quit";
static NSString * const kTooltipString = @"Stone. Will collect your time.";
static NSString * const kStoneImageName = @"stone_image.png";
static NSString * const kStoneImageHighlightedName = @"stone_image_highlighted.png";

static NSString * const kNewNameString = @"New Name";
static NSString * const kInmutableException = @"Inmutable object exception";
static NSString * const kStopString = @"Stop Stone";

static NSString * const kZoneNameChanged = @"kZoneNameChanged";

#define FRAND() ((float) random()/RAND_MAX)

static NSString *FormatInterval(NSTimeInterval interval, BOOL isShort) {
    
    NSInteger numSeconds = interval;
    NSInteger days = numSeconds / (60 * 60 * 24);
    numSeconds -= days * (60 * 60 * 24);
    NSInteger hours = numSeconds / (60 * 60);
    numSeconds -= hours * (60 * 60);
    NSInteger minutes = numSeconds / 60;
    numSeconds -= minutes * 60;
    if (isShort) {
        return [NSString stringWithFormat:@"%.2d:%.2d", hours, minutes];
    } else {
        return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, numSeconds];   
    }
}

#endif
