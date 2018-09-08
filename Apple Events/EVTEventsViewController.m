//
//  EVTEventsViewController.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEventsViewController.h"

#import "EVTEnvironment.h"
#import "EVTEvent.h"
#import "EVTEventsFetcher.h"
#import "EVTEventStateProvider.h"
#import "EVTEventsCache.h"
#import "EVTImageFetcher.h"

#import "EVTCurrentEventViewController.h"
#import "EVTPlayerViewController.h"
#import "EVTPastEventsCollectionViewController.h"

@import EventsUI;

@interface EVTEventsViewController ()

@property (nonatomic, strong) EVTEventsCache *eventsCache;
@property (nonatomic, strong) EVTEventsFetcher *fetcher;
@property (nonatomic, strong) EVTEventStateProvider *stateProvider;
@property (nonatomic, strong) EVTImageFetcher *imageFetcher;

@property (weak) IBOutlet EVTSpinner *spinner;
@property (assign) BOOL isLoadingEvents;

@property (copy) EVTEvent *currentEvent;
@property (copy) NSArray *pastEvents;

@property (strong) EVTCurrentEventViewController *currentEventController;
@property (strong) EVTPastEventsCollectionViewController *pastEventsController;
@property (strong) EVTPlayerViewController *playerViewController;

@property (strong) NSButton *backButton;

@property (assign) BOOL registeredPiPObserver;

@end

@implementation EVTEventsViewController

#pragma mark Initialization and event loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"currentEvent" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"pastEvents" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    
    self.imageFetcher = [[EVTImageFetcher alloc] initWithEnvironment:[EVTEnvironment currentEnvironment]];
    self.eventsCache = [EVTEventsCache cache];
    self.fetcher = [[EVTEventsFetcher alloc] initWithEnvironment:[EVTEnvironment currentEnvironment] cache:self.eventsCache];
    self.stateProvider = [[EVTEventStateProvider alloc] initWithEnvironment:[EVTEnvironment currentEnvironment]];
    
    [self __configureAndInstallChildViewControllers];
    
    [self loadEventsWithProgress:YES];
    
    [self __populateEventsWith:self.eventsCache.cachedEvents];
}

- (void)__installBackButton
{
    self.backButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    self.backButton.hidden = YES;
    self.backButton.target = self;
    self.backButton.action = @selector(goBack:);
    self.backButton.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    [self.backButton setButtonType:NSButtonTypeMomentaryLight];
    [self.backButton setBezelStyle:NSBezelStyleTexturedRounded];
    [self.backButton setTitle:@"Close Video"];
    self.backButton.controlSize = NSMiniControlSize;
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton sizeToFit];
    NSVisualEffectView *titlebar = [(EVTWindow *)self.view.window titlebarView];
    [titlebar addSubview:self.backButton];
    [[self.backButton.trailingAnchor constraintEqualToAnchor:titlebar.trailingAnchor constant:-6] setActive:YES];
    [[self.backButton.centerYAnchor constraintEqualToAnchor:titlebar.centerYAnchor] setActive:YES];
}

- (void)__configureAndInstallChildViewControllers
{
    self.currentEventController = [EVTCurrentEventViewController instantiateWithStoryboard:self.storyboard];
    self.currentEventController.imageFetcher = self.imageFetcher;
    self.currentEventController.stateProvider = self.stateProvider;
    
    [self addChildViewController:self.currentEventController];
    
    self.currentEventController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentEventController.backdropView.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
    [self.view addSubview:self.currentEventController.view];
    
    [[self.currentEventController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.currentEventController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.currentEventController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.currentEventController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    self.pastEventsController = [EVTPastEventsCollectionViewController instantiateWithStoryboard:self.storyboard];
    self.pastEventsController.imageFetcher = self.imageFetcher;
    [self addChildViewController:self.pastEventsController];
    
    self.pastEventsController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pastEventsController.view];
    [[self.pastEventsController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.pastEventsController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.pastEventsController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    [(EVTWindow *)self.view.window setHidesTitlebar:NO];
    
    if (!self.isLoadingEvents) [self loadEventsWithProgress:NO];
    
    [self __installBackButton];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self restoreWindowTitle];
    
    if (!self.registeredPiPObserver) {
        self.registeredPiPObserver = YES;
        [self.view.window addObserver:self forKeyPath:@"isInPiPMode" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)restoreWindowTitle
{
    self.view.window.title = @" Events";
}

- (void)loadEventsWithProgress:(BOOL)showProgress
{
    self.isLoadingEvents = YES;
    
    if (showProgress) [self __showProgress];
    
    __weak typeof(self) weakSelf = self;
    [self.fetcher fetchEventsWithCompletionHandler:^(NSError *error, NSArray<EVTEvent *> *events) {
        weakSelf.isLoadingEvents = NO;
        
        if (error) {
            [self __showError:error];
        } else {
            [self __populateEventsWith:events];
        }
    }];
}

- (void)__populateEventsWith:(NSArray <EVTEvent *> *)events
{
    NSPredicate *livePredicate = [NSPredicate predicateWithFormat:@"live == YES"];
    self.currentEvent = [[events filteredArrayUsingPredicate:livePredicate] firstObject];
    self.pastEvents = events;
    
    [self.currentEventController.backdropView.subviews enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:NO];
    }];
    
    [self __hideProgress];
}

- (void)__showError:(NSError *)error
{
    [[NSAlert alertWithError:error] beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) { }];
}

#pragma mark State management

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentEvent"];
    [self removeObserver:self forKeyPath:@"pastEvents"];
    [self removeObserver:self forKeyPath:@"isInPiPMode"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentEvent"]) {
        self.currentEventController.event = self.currentEvent;
    } else if ([keyPath isEqualToString:@"pastEvents"]) {
        self.pastEventsController.events = self.pastEvents;
    } else if ([keyPath isEqualToString:@"isInPiPMode"]) {
        self.backButton.hidden = [(EVTWindow *)self.view.window isInPiPMode];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)__showProgress
{
    self.spinner.hidden = NO;
    self.spinner.animator.alphaValue = 1.0;
    [self.spinner startAnimation:self];
}

- (void)__hideProgress
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.spinner stopAnimation:self];
        self.spinner.hidden = YES;
    }];
    self.spinner.animator.alphaValue = 0;
    [NSAnimationContext endGrouping];
}

- (void)playLiveEvent:(EVTEvent *)event
{
    event.live = YES;
    [self playEvent:event videoURL:event.liveURL];
}

- (void)playOnDemandEvent:(EVTEvent *)event
{
    event.live = NO;
    [self playEvent:event videoURL:event.vodURL];
}

- (void)playEvent:(EVTEvent *)event videoURL:(NSURL *)videoURL
{
    [self.pastEventsController deactivateConstraintsAffectingWindow];
    [self.currentEventController deactivateConstraintsAffectingWindow];
    
    self.playerViewController = [EVTPlayerViewController playerViewControllerWithEvent:event videoURL:videoURL];
    self.playerViewController.view.frame = self.view.bounds;
    self.playerViewController.view.alphaValue = 0;
    [self addChildViewController:self.playerViewController];
    
    [self.view addSubview:self.playerViewController.view positioned:NSWindowAbove relativeTo:self.currentEventController.view];
    self.playerViewController.view.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    
    self.backButton.alphaValue = 0;
    self.backButton.hidden = NO;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        self.pastEventsController.view.hidden = YES;
    }];
    
    [(EVTWindow *)self.view.window setAllowsPiPMode:YES];
    [(EVTWindow *)self.view.window setHidesTitlebar:YES];
    for (NSView *view in self.currentEventController.backdropView.subviews) view.animator.alphaValue = 0;
    self.backButton.animator.alphaValue = 0.8;
    self.playerViewController.view.animator.alphaValue = 1;
    self.pastEventsController.view.animator.alphaValue = 0;
    
    [NSAnimationContext endGrouping];
}

- (IBAction)goBack:(id)sender {
    [(EVTWindow *)self.view.window setAllowsPiPMode:NO];
    
    self.pastEventsController.view.hidden = NO;
    
    [self restoreWindowTitle];
    
    [NSAnimationContext beginGrouping];
    [self.pastEventsController reactivateConstraintsAffectingWindow];
    [self.currentEventController reactivateConstraintsAffectingWindow];
    
    self.pastEventsController.view.animator.alphaValue = 1;
    self.playerViewController.view.animator.alphaValue = 0;
    self.backButton.animator.alphaValue = 0;
    for (NSView *view in self.currentEventController.backdropView.subviews) view.animator.alphaValue = 1;
    
    [(EVTWindow *)self.view.window setHidesTitlebar:NO];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.playerViewController stop];
        [self.playerViewController.view removeFromSuperview];
        [self removeChildViewControllerAtIndex:[self.childViewControllers indexOfObject:self.playerViewController]];
        self.playerViewController = nil;
        self.view.window.resizeIncrements = NSMakeSize(1, 1);
        [(EVTWindow *)self.view.window setHidesTitlebar:NO];
    }];
    [NSAnimationContext endGrouping];
}

- (void)showEvent:(EVTEvent *)event
{
    self.currentEventController.event = event;
}

@end
