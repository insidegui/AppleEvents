//
//  EVTEventStateProvider.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EVTEnvironment;

typedef NS_ENUM(NSInteger, EVTEventState) {
    EVTEventStateUnknown = -1,
    EVTEventStatePre,
    EVTEventStateLive,
    EVTEventStateInterim,
    EVTEventStatePost
};

@interface EVTEventStateProvider : NSObject

- (instancetype)initWithEnvironment:(EVTEnvironment *)environment;

@property (readonly) EVTEventState state;
@property (readonly) NSURL *url;

@end
