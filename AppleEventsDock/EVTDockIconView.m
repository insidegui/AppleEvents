//
//  EVTDockIconView.m
//  Apple Events
//
//  Created by Guilherme Rambo on 9/6/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTDockIconView.h"

@implementation EVTDockIconView
{
    NSImage *_maskImage;
    NSImage *_defaultImage;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    _maskImage = [[NSImage alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForImageResource:@"IconMask"]];
    _defaultImage = [[NSImage alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForImageResource:@"DefaultIcon"]];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(self.bounds, 9.0, 9.0)] addClip];
    NSImage *_imageToDraw = (_eventImage) ? _eventImage : _defaultImage;
    [_imageToDraw drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    [_maskImage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositePlusLighter fraction:1.0];
    
    if (self.isLive) {
        NSDictionary *attrs = @{
                                NSFontAttributeName: [NSFont systemFontOfSize:18.0 weight:NSFontWeightMedium],
                                NSForegroundColorAttributeName: [NSColor whiteColor]
                                };
        NSAttributedString *liveIndicator = [[NSAttributedString alloc] initWithString:@"LIVE" attributes:attrs];
        NSSize stringSize = [liveIndicator size];
        NSRect liveRect = NSMakeRect(floor(NSWidth(self.bounds) / 2.0 - stringSize.width / 2.0) + 0.5,
                                     floor(NSHeight(self.bounds) / 2.0 - stringSize.height / 2.0 - 16.0) + 0.5,
                                     stringSize.width,
                                     stringSize.height);
        [[NSColor colorWithDeviceRed:0.9 green:0.1 blue:0.1 alpha:0.9] setFill];
        [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(liveRect, -8.0, -4.0) xRadius:8.0 yRadius:8.0] fill];
        [liveIndicator drawInRect:liveRect];
    }
}

@end
