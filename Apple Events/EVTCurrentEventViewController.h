//
//  EVTCurrentEventViewController.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

#import "EVTEventStateProvider.h"

@class EVTEvent, EVTImageFetcher;

@interface EVTCurrentEventViewController : NSViewController

+ (instancetype)instantiateWithStoryboard:(NSStoryboard *)storyboard;

@property (nonatomic, weak) EVTImageFetcher *imageFetcher;
@property (nonatomic, weak) EVTEventStateProvider *stateProvider;

@property (weak) IBOutlet NSVisualEffectView *backdropView;


@property (nonatomic, copy) EVTEvent *event;

- (void)deactivateConstraintsAffectingWindow;
- (void)reactivateConstraintsAffectingWindow;

@end
