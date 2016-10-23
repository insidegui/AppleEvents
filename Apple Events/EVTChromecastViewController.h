//
//  EVTChromecastViewController.h
//  Apple Events
//
//  Created by Guilherme Rambo on 23/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EVTEvent;

typedef NS_ENUM(NSInteger, EVTChromecastState) {
    EVTChromeCastStateNone,
    EVTChromeCastStateConnecting,
    EVTChromeCastStateBuffering,
    EVTChromeCastStatePlaying,
    EVTChromeCastStatePaused
};

@interface EVTChromecastStatus : NSObject

@property (copy) NSString *outputDeviceName;
@property (assign) double currentTime;
@property (assign) EVTChromecastState state;

@end

@interface EVTChromecastViewController : NSViewController

+ (instancetype)chromecastViewControllerWithEvent:(EVTEvent *)event videoURL:(NSURL *)videoURL;

@property (readonly) NSString *outputDeviceName;

@end
