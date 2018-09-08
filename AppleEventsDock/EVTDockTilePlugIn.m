//
//  EVTDockTilePlugIn.m
//  Apple Events
//
//  Created by Guilherme Rambo on 9/6/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTDockTilePlugIn.h"

#import "EVTEnvironment.h"
#import "EVTEventsFetcher.h"
#import "EVTImageFetcher.h"
#import "EVTEventStateProvider.h"

#import "EVTDockIconView.h"

@interface EVTDockTilePlugIn ()

@property (nonatomic, strong) EVTEventStateProvider *stateProvider;
@property (nonatomic, strong) EVTEventsFetcher *eventsFetcher;
@property (nonatomic, strong) EVTImageFetcher *imageFetcher;
@property (nonatomic, strong) EVTDockIconView *iconView;

@property (nonatomic, strong) NSTimer *updateTimer;

@property (nonatomic, strong) NSDockTile *dockTile;

@end

@implementation EVTDockTilePlugIn

- (instancetype)init
{
    self = [super init];
    
    _stateProvider = [[EVTEventStateProvider alloc] initWithEnvironment:[EVTEnvironment currentEnvironment]];
    _eventsFetcher = [[EVTEventsFetcher alloc] initWithEnvironment:[EVTEnvironment currentEnvironment] cache:nil];
    _imageFetcher = [[EVTImageFetcher alloc] initWithEnvironment:[EVTEnvironment currentEnvironment]];
    
    [_stateProvider addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    
    return self;
}

- (void)setDockTile:(NSDockTile *)dockTile
{
    _dockTile = dockTile;
    
    self.iconView = [[EVTDockIconView alloc] initWithFrame:NSMakeRect(0, 0, dockTile.size.width, dockTile.size.height)];
    
    NSString *currentIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"__EVT_currentIdentifier"];
    if (currentIdentifier) [self updateIconWithEventImageNamed:currentIdentifier];
    
    [self update:nil];
    
    _dockTile.contentView = self.iconView;
    [_dockTile display];
}

- (void)updateIconWithEventImageNamed:(NSString *)imageName
{
    [[NSUserDefaults standardUserDefaults] setObject:imageName forKey:@"__EVT_currentIdentifier"];

    __weak typeof(self) weakSelf = self;
    [self.imageFetcher fetchImageNamed:imageName completionHandler:^(NSImage *image) {
        self.iconView.eventImage = image;
        [weakSelf.dockTile display];
    }];
}

- (void)update:(id)sender
{
    [self.eventsFetcher fetchCurrentEventIdentifierCompletionHandler:^(NSError *error, NSString *identifier) {
        if (!error && identifier) [self updateIconWithEventImageNamed:identifier];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        self.iconView.isLive = (self.stateProvider.state == EVTEventStateLive);
        [self.dockTile display];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [_stateProvider removeObserver:self forKeyPath:@"state"];
}

@end
