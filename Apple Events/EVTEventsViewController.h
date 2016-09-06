//
//  EVTEventsViewController.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@class EVTEvent;

@interface EVTEventsViewController : NSViewController

- (void)playLiveEvent:(EVTEvent *)event;
- (void)playOnDemandEvent:(EVTEvent *)event;
- (void)showEvent:(EVTEvent *)event;

@end
