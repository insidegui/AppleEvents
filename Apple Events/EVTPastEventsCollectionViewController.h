//
//  EVTPastEventsCollectionViewController.h
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EVTImageFetcher, EVTEvent;

@interface EVTPastEventsCollectionViewController : NSViewController

@property (nonatomic, weak) EVTImageFetcher *imageFetcher;
@property (nonatomic, copy) NSArray <EVTEvent *> *events;

+ (instancetype)instantiateWithStoryboard:(NSStoryboard *)storyboard;

- (void)deactivateConstraintsAffectingWindow;
- (void)reactivateConstraintsAffectingWindow;

@end
