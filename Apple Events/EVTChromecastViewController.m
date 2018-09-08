//
//  EVTChromecastViewController.m
//  Apple Events
//
//  Created by Guilherme Rambo on 23/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTChromecastViewController.h"

@import EventsUI;
@import ChromeCastCore;

#import "EVTEvent.h"
#import "EVTEnvironment.h"

@interface EVTChromecastStatus ()

+ (instancetype)statusWithOutputDeviceName:(NSString *)outputDeviceName currentTime:(double)currentTime state:(EVTChromecastState)state;
+ (instancetype)statusWithMediaStatus:(CastMediaStatus *)mediaStatus deviceName:(NSString *)deviceName;

@end

@interface EVTChromecastViewController () <CastClientDelegate>

@property (copy) EVTEvent *event;
@property (copy) NSURL *videoURL;

@property (strong) EVTMaskButton *castButton;

@property (strong) CastDeviceScanner *scanner;
@property (strong) CastClient *client;
@property (strong) CastApp *mediaPlayerApp;
@property (strong) CastDevice *outputDevice;

@property (strong) NSMenu *devicesMenu;

@property (readonly) CastMedia *media;

@property (nonatomic, strong) EVTChromecastStatus *status;

@property (nonatomic, strong) NSTimer *statusTimer;

@end

@implementation EVTChromecastViewController

+ (instancetype)chromecastViewControllerWithEvent:(EVTEvent *)event videoURL:(NSURL *)videoURL
{
    EVTChromecastViewController *controller = [[EVTChromecastViewController alloc] initWithNibName:nil bundle:nil];
    
    controller.event = event;
    controller.videoURL = videoURL;
    
    return controller;
}

- (void)loadView
{
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.widthAnchor constraintEqualToConstant:self.preferredContentSize.width];
    [self.view.heightAnchor constraintEqualToConstant:self.preferredContentSize.height];
    
    self.castButton = [[EVTMaskButton alloc] initWithFrame:NSMakeRect(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    self.castButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.castButton];
    
    [self.castButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.castButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.castButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.castButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    self.castButton.image = [NSImage imageNamed:@"chromecast"];
    self.castButton.tintColor = [NSColor whiteColor];
    
    self.castButton.target = self;
    self.castButton.action = @selector(showDevicesMenu:);
    self.castButton.hidden = YES;
}

- (CastMedia *)media
{
    NSURL *imageURL = [[EVTEnvironment currentEnvironment] URLForImageNamed:self.event.identifier];
    
    NSString *title = [NSString stringWithFormat:@"%@ - %@", self.event.title, self.event.shortTitle];
    
    NSString *streamType = (self.event.live) ? @"LIVE" : @"BUFFERED";
    
    return [[CastMedia alloc] initWithTitle:title url:self.videoURL poster:imageURL contentType:@"application/vnd.apple.mpegurl" streamType:streamType autoplay:YES currentTime:self.currentTime];
}

- (void)showDevicesMenu:(EVTMaskButton *)sender
{
    [self.devicesMenu popUpMenuPositioningItem:nil atLocation:sender.frame.origin inView:sender];
}

- (NSSize)preferredContentSize
{
    return NSMakeSize(24, 24);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.devicesMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Chromecast Devices", @"Chromecast Devices")];
    
    self.scanner = [[CastDeviceScanner alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDevicesMenu) name:[CastDeviceScanner DeviceListDidChange] object:self.scanner];
    [self.scanner startScanning];
}

- (void)updateDevicesMenu
{
    self.castButton.hidden = self.scanner.devices.count == 0;
    
    [self.devicesMenu removeAllItems];
    
    for (CastDevice *device in self.scanner.devices) {
        NSMenuItem *item;
        
        if ([device.name isEqualToString:self.status.outputDeviceName]) {
            NSString *format = NSLocalizedString(@"Disconnect from %@", @"Disconnect from %@ (Chromecast device name)");
            item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:format, device.name] action:@selector(stopCasting:) keyEquivalent:@""];
        } else {
            item = [[NSMenuItem alloc] initWithTitle:device.name action:@selector(connectToCastDevice:) keyEquivalent:@""];
        }
        
        item.target = self;
        item.representedObject = device;
        [self.devicesMenu addItem:item];
    }
}

- (void)connectToCastDevice:(NSMenuItem *)sender
{
    CastDevice *device = sender.representedObject;
    if (![device isKindOfClass:[CastDevice class]]) return;
    
    self.outputDevice = device;
    self.status = [EVTChromecastStatus statusWithOutputDeviceName:self.outputDevice.name currentTime:self.currentTime state:EVTChromeCastStateConnecting];
    
    self.client = [[CastClient alloc] initWithDevice:device];
    self.client.delegate = self;
    [self.client connect];
}

- (void)stopCasting:(NSMenuItem *)sender
{
    self.currentTime = self.status.currentTime;
    self.status = nil;
    
    if (self.mediaPlayerApp) {
        [self.client stopApp:self.mediaPlayerApp];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.client disconnect];
        self.client = nil;
        
        [self updateDevicesMenu];
    });
}

- (void)castClient:(CastClient *)client didConnectTo:(CastDevice *)device
{
    __weak typeof(self) weakSelf = self;
    [self.client launchAppWithIdentifier:@"CC1AD845" completionHandler:^(NSError *launchError, CastApp *app) {
        weakSelf.mediaPlayerApp = app;
        
        if (launchError) {
            [[NSAlert alertWithError:launchError] runModal];
            weakSelf.status = nil;
            return;
        }
        
        [weakSelf.client loadMedia:self.media usingApp:app completionHandler:^(NSError *loadError, CastMediaStatus *mediaStatus) {
            if (loadError) {
                [[NSAlert alertWithError:launchError] runModal];
                weakSelf.status = nil;
            } else {
                weakSelf.status = [EVTChromecastStatus statusWithMediaStatus:mediaStatus deviceName:device.name];
                
                [weakSelf updateDevicesMenu];
            }
        }];
    }];
}

- (void)requestStatusUpdate:(NSTimer *)timer
{
    if (![timer.userInfo isKindOfClass:[NSNumber class]] || ![timer.userInfo respondsToSelector:@selector(longLongValue)]) return;
    
    NSNumber *info = timer.userInfo;
    [self.client requestMediaStatusForApp:self.mediaPlayerApp mediaSessionId:info.longLongValue];
}

- (void)castClient:(CastClient *)client connectionTo:(CastDevice *)device didFailWith:(NSError *)error
{
    self.status = nil;
    [[NSAlert alertWithError:error] runModal];
}

- (void)castClient:(CastClient *)client didDisconnectFrom:(CastDevice *)device
{
    self.status = nil;
    [self.statusTimer invalidate];
    self.statusTimer = nil;
}

- (void)castClient:(CastClient *)client mediaStatusDidChange:(CastMediaStatus *)status
{
    if (!self.statusTimer) {
        self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(requestStatusUpdate:) userInfo:@(status.mediaSessionId) repeats:YES];
    }
    
    self.status = [EVTChromecastStatus statusWithMediaStatus:status deviceName:self.outputDevice.name];
}

- (void)updateCastButtonTint
{
    if (self.status) {
        self.castButton.tintColor = [NSColor colorWithDeviceRed:0.002 green:0.487 blue:0.998 alpha:1];
    } else {
        self.castButton.tintColor = [NSColor whiteColor];
    }
}

- (void)setStatus:(EVTChromecastStatus *)status
{
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
    
    [self updateCastButtonTint];
}

@end

@implementation EVTChromecastStatus

+ (instancetype)statusWithOutputDeviceName:(NSString *)outputDeviceName currentTime:(double)currentTime state:(EVTChromecastState)state
{
    EVTChromecastStatus *status = [[EVTChromecastStatus alloc] init];
    
    status.outputDeviceName = outputDeviceName;
    status.currentTime = currentTime;
    status.state = state;
    
    return status;
}

+ (EVTChromecastState)stateFromMediaState:(NSString *)mediaState
{
    if ([mediaState isEqualToString:@"BUFFERING"]) {
        return EVTChromeCastStateBuffering;
    } else if ([mediaState isEqualToString:@"PAUSED"] || [mediaState isEqualToString:@"STOPPED"]) {
        return EVTChromeCastStatePaused;
    } else if ([mediaState isEqualToString:@"PLAYING"]) {
        return EVTChromeCastStatePlaying;
    } else {
        return EVTChromeCastStateNone;
    }
}

+ (instancetype)statusWithMediaStatus:(CastMediaStatus *)mediaStatus deviceName:(NSString *)deviceName
{
    EVTChromecastStatus *status = [[EVTChromecastStatus alloc] init];
    
    status.outputDeviceName = deviceName;
    status.currentTime = mediaStatus.currentTime;
    status.state = [self stateFromMediaState:mediaStatus.state];
    
    return status;
}

- (NSString *)descriptionForState:(EVTChromecastState)state
{
    switch(state) {
        case EVTChromeCastStateBuffering:
            return @"Buffering";
        case EVTChromeCastStateNone:
            return @"None";
        case EVTChromeCastStatePlaying:
            return @"Playing";
        case EVTChromeCastStatePaused:
            return @"Paused";
        case EVTChromeCastStateConnecting:
            return @"Connecting";
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"EVTChromecastStatus(outputDeviceName: %@, currentTime: %.2f, state: %@)", self.outputDeviceName, self.currentTime, [self descriptionForState:self.state]];
}

@end
