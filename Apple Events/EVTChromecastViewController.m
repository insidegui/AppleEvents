//
//  EVTChromecastViewController.m
//  Apple Events
//
//  Created by Guilherme Rambo on 23/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTChromeCastViewController.h"

@import EventsUI;
@import ChromeCastCore;

#import "EVTEvent.h"
#import "EVTEnvironment.h"

@interface EVTChromecastViewController () <CastClientDelegate>

@property (copy) EVTEvent *event;
@property (copy) NSURL *videoURL;

@property (strong) EVTMaskButton *castButton;

@property (strong) CastDeviceScanner *scanner;
@property (strong) CastClient *client;

@property (strong) NSMenu *devicesMenu;

@property (assign) double currentTime;
@property (readonly) CastMedia *media;

@property (copy) NSString *outputDeviceName;

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
    
    return [[CastMedia alloc] initWithTitle:self.event.title url:self.videoURL poster:imageURL contentType:@"application/vnd.apple.mpegurl" streamType:@"BUFFERED" autoplay:YES currentTime:self.currentTime];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListDidChange:) name:[CastDeviceScanner DeviceListDidChange] object:self.scanner];
    [self.scanner startScanning];
}

- (void)deviceListDidChange:(NSNotification *)note
{
    self.castButton.hidden = self.scanner.devices.count == 0;
    
    [self.devicesMenu removeAllItems];
    
    for (CastDevice *device in self.scanner.devices) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:device.name action:@selector(connectToCastDevice:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = device;
        [self.devicesMenu addItem:item];
    }
}

- (void)connectToCastDevice:(NSMenuItem *)sender
{
    CastDevice *device = sender.representedObject;
    if (![device isKindOfClass:[CastDevice class]]) return;
    
    self.client = [[CastClient alloc] initWithDevice:device];
    self.client.delegate = self;
    [self.client connect];
}

- (void)castClient:(CastClient *)client didConnectTo:(CastDevice *)device
{
    [self.client launchAppWithIdentifier:@"CC1AD845" completionHandler:^(NSError *launchError, CastApp *app) {
        if (launchError) {
            [[NSAlert alertWithError:launchError] runModal];
            self.outputDeviceName = nil;
            return;
        }
        
        [self.client loadMedia:self.media usingApp:app completionHandler:^(NSError *loadError, CastMediaStatus *mediaStatus) {
            if (loadError) {
                [[NSAlert alertWithError:launchError] runModal];
                self.outputDeviceName = nil;
            } else {
                self.outputDeviceName = device.name;
            }
        }];
    }];
}

- (void)castClient:(CastClient *)client connectionTo:(CastDevice *)device didFailWith:(NSError *)error
{
    self.outputDeviceName = nil;
    [[NSAlert alertWithError:error] runModal];
}

- (void)castClient:(CastClient *)client didDisconnectFrom:(CastDevice *)device
{
    self.outputDeviceName = nil;
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

@end
