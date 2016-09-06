//
//  EVTPlayerViewController.h
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@class EVTEvent;

@interface EVTPlayerViewController : NSViewController

+ (instancetype)playerViewControllerWithEvent:(EVTEvent *)event videoURL:(NSURL *)videoURL;

- (void)stop;

@end
