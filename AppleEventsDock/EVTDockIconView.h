//
//  EVTDockIconView.h
//  Apple Events
//
//  Created by Guilherme Rambo on 9/6/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EVTDockIconView : NSView

@property (nonatomic, copy) NSImage *eventImage;
@property (nonatomic, assign) BOOL isLive;

@end
