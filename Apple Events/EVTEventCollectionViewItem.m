//
//  EVTEventCollectionViewItem.m
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEventCollectionViewItem.h"

@import EventsUI;

#import "EVTEvent.h"
#import "EVTImageFetcher.h"

@interface EVTEventCollectionViewItem ()

@property (nonatomic, strong) EVTMagicImageView *posterView;

@end

@implementation EVTEventCollectionViewItem
{
    CGFloat _defaultPosterPadding;
}

- (void)loadView
{
    _defaultPosterPadding = 20.0;
    
    self.view = [[NSView alloc] initWithFrame:NSZeroRect];
    self.view.wantsLayer = YES;
    self.view.layer = [CALayer layer];
    self.view.layer.masksToBounds = false;
    self.view.layerUsesCoreImageFilters = YES;
    
    self.posterView = [[EVTMagicImageView alloc] initWithFrame:NSZeroRect];
    self.posterView.blurAmount = 30.0;
    self.posterView.blurAmountWhenHovered = 20.0;
    self.posterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.posterView];
    
    [[self.posterView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:_defaultPosterPadding] setActive:YES];
    [[self.posterView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-_defaultPosterPadding] setActive:YES];
    [[self.posterView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-_defaultPosterPadding] setActive:YES];
    [[self.posterView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:_defaultPosterPadding] setActive:YES];
}

- (void)setEvent:(EVTEvent *)event
{
    _event = [event copy];
    
    [self updateUI];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.posterView.image = nil;
}

- (void)updateUI
{
    if (!self.event) return;
    
    NSString *originalIdentifier = self.event.identifier;
    [self.imageFetcher fetchImageNamed:self.event.identifier completionHandler:^(NSImage *image) {
        if (![self.event.identifier isEqualToString:originalIdentifier]) return;
        self.posterView.image = image;
    }];
}

@end
