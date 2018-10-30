//
//  EVTCurrentEventViewController.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTCurrentEventViewController.h"

#import "EVTEvent.h"
#import "EVTEnvironment.h"
#import "EVTImageFetcher.h"
#import "EVTEventsViewController.h"

@import EventsUI;

@interface EVTCurrentEventViewController ()

@property (weak) IBOutlet EVTMagicImageView *imageView;
@property (weak) IBOutlet NSTextField *titleLabel;
@property (weak) IBOutlet NSTextField *subtitleLabel;
@property (weak) IBOutlet NSTextField *descriptionLabel;
@property (weak) IBOutlet EVTButton *watchButton;

@property (readonly) EVTEventsViewController *mainController;

@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak) IBOutlet NSLayoutConstraint *buttonConstraint;

@property (nonatomic, strong) NSMutableArray <NSLayoutConstraint *> *previouslyDeactivatedConstraints;

@property (assign) CGFloat bottomConstraintDefaultConstant;
@property (assign) CGFloat heightConstraintDefaultConstant;
@property (assign) CGFloat buttonConstraintDefaultConstant;

@end

@implementation EVTCurrentEventViewController

+ (instancetype)instantiateWithStoryboard:(NSStoryboard *)storyboard
{
    return [storyboard instantiateControllerWithIdentifier:NSStringFromClass([self class])];
}

- (EVTEventsViewController *)mainController
{
    return (EVTEventsViewController *)self.parentViewController;
}

- (NSMutableArray<NSLayoutConstraint *> *)previouslyDeactivatedConstraints
{
    if (!_previouslyDeactivatedConstraints) _previouslyDeactivatedConstraints = [NSMutableArray new];
    
    return _previouslyDeactivatedConstraints;
}

- (void)setEvent:(EVTEvent *)event
{
    if (!event) return;
    
    _event = [event copy];
    
    [self __updateWithEvent:_event state:self.stateProvider.state];
}

- (void)setStateProvider:(EVTEventStateProvider *)stateProvider
{
    if (_stateProvider) {
        if (_stateProvider == stateProvider) return;
        [_stateProvider removeObserver:self forKeyPath:@"state"];
    }
    
    _stateProvider = stateProvider;
    
    [_stateProvider addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        if (change[NSKeyValueChangeOldKey]) {
            // if there is no change, do nothing
            if ([change[NSKeyValueChangeOldKey] integerValue] == self.stateProvider.state) return;
        }
        
        [self __updateWithEvent:self.event state:self.stateProvider.state];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)__updateWithEvent:(EVTEvent *)event state:(EVTEventState)state
{
    if (!event) return;
    
    self.watchButton.hidden = NO;
    
    self.titleLabel.stringValue = event.title;
    self.subtitleLabel.stringValue = (event.localizedDateString) ? event.localizedDateString : @"";
    
    if (event.live) {
        switch (state) {
            case EVTEventStateUnknown:
            case EVTEventStatePre:
                self.descriptionLabel.stringValue = event.preDescription;
                self.watchButton.title = (event.localizedTimeString) ? event.localizedDateString : NSLocalizedString(@"Live Soon", @"Live Soon");
                break;
            case EVTEventStateLive:
                self.descriptionLabel.stringValue = event.liveDescription;
                self.watchButton.title = event.buttonPlay;
                break;
            case EVTEventStateInterim:
                self.descriptionLabel.stringValue = event.interimDescription;
                self.watchButton.title = event.buttonComingSoon;
                break;
            case EVTEventStatePost:
                self.descriptionLabel.stringValue = event.postDescription;
                self.watchButton.title = event.buttonPlay;
                break;
            default:
                break;
        }
    } else {
        self.descriptionLabel.stringValue = event.postDescription;
        self.watchButton.title = event.buttonPlay;
    }
    
    NSString *originalIdentifier = event.identifier;
    [self.imageFetcher fetchImageNamed:event.identifier completionHandler:^(NSImage *image) {
        if (![self.event.identifier isEqualToString:originalIdentifier]) return;
        
        self.imageView.image = image;
        self.imageView.effectsEnabled = YES;
    }];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bottomConstraintDefaultConstant = self.bottomConstraint.constant;
    self.heightConstraintDefaultConstant = self.heightConstraint.constant;
    self.buttonConstraintDefaultConstant = self.buttonConstraint.constant;
    
    self.backdropView.material = NSVisualEffectMaterialUltraDark;
    self.backdropView.state = NSVisualEffectStateActive;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
}

- (IBAction)watch:(id)sender {
    if (self.event.live) {
        switch (self.stateProvider.state) {
            case EVTEventStateLive:
                self.event.liveURL = self.stateProvider.url;
                [self.mainController playLiveEvent:self.event];
                break;
            case EVTEventStatePost:
                [self.mainController playOnDemandEvent:self.event];
                break;
            default:
                break;
        }
    } else {
        [self.mainController playOnDemandEvent:self.event];
    }
}

- (void)deactivateConstraintsAffectingWindow
{
    self.bottomConstraint.constant = 0.0;
    self.heightConstraint.constant = 1.0;
    self.buttonConstraint.constant = 0.0;
    
    [self.previouslyDeactivatedConstraints removeAllObjects];
    
    [self.backdropView.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.previouslyDeactivatedConstraints addObject:obj];
        [obj setActive:NO];
    }];
}

- (void)reactivateConstraintsAffectingWindow
{
    [self.previouslyDeactivatedConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setActive:YES];
    }];
    
    self.bottomConstraint.animator.constant = self.bottomConstraintDefaultConstant;
    self.heightConstraint.animator.constant = self.heightConstraintDefaultConstant;
    self.buttonConstraint.animator.constant = self.buttonConstraintDefaultConstant;
}

@end
