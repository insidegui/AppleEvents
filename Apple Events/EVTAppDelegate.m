//
//  EVTAppDelegate.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTAppDelegate.h"

#import "EVTEnvironment.h"

@import EventsUI;

@interface EVTAppDelegate ()

@end

@implementation EVTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSWindow *window = [NSApp windows].firstObject;
    if ([window respondsToSelector:@selector(setTabbingMode:)]) {
        [window setTabbingMode:NSWindowTabbingModeDisallowed];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)toggleFullScreenAction:(NSMenuItem *)sender {
    id firstWindow = [NSApplication sharedApplication].windows.firstObject;
    if ([firstWindow isKindOfClass:[EVTWindow class]]) {
        [(EVTWindow *)firstWindow reallyDoToggleFullScreenImNotEvenKiddingItsRealThisTimeISwear:sender];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
