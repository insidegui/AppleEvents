//
//  EVTMaskButton.m
//  EventsUI
//
//  Created by Guilherme Rambo on 26/09/15.
//  Copyright © 2015 Guilherme Rambo. All rights reserved.
//

#import "EVTMaskButton.h"
#import "NSImage+CGImage.h"

@implementation EVTMaskButton
{
    NSColor *_tintColor;
    NSColor *_backgroundColor;
    NSImage *_image;
}

- (NSColor *)tintColor
{
    if (!_tintColor) return [NSColor blackColor];
    
    return _tintColor;
}

- (void)setTintColor:(NSColor *)tintColor
{
    [self willChangeValueForKey:@"tintColor"];
    _tintColor = [tintColor copy];
    [self didChangeValueForKey:@"tintColor"];
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    [self willChangeValueForKey:@"backgroundColor"];
    _backgroundColor = [backgroundColor copy];
    [self didChangeValueForKey:@"backgroundColor"];
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image
{
    [self willChangeValueForKey:@"image"];
    _image = image;
    [self didChangeValueForKey:@"image"];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (!self.image) return;
    
    CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
    CGContextSaveGState(ctx);
    
    if (self.backgroundColor) {
        CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
        CGContextFillRect(ctx, self.bounds);
    }
    
    CGFloat widthRatio = NSWidth(self.bounds) / self.image.size.width;
    CGFloat heightRatio = NSHeight(self.bounds) / self.image.size.height;
    CGRect imageRect = CGRectMake(0, 0, round(self.image.size.width*widthRatio), round(self.image.size.height*heightRatio));
    
    CGContextClipToMask(ctx, imageRect, self.image.CGImage);
    CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextRestoreGState(ctx);
}

- (void)mouseDown:(NSEvent *)event
{
    [NSApp sendAction:self.action to:self.target from:self];
}

@end
