//
//  EVTEvent.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EVTEvent : NSObject <NSCopying, NSCoding>

@property (copy) NSString *title;
@property (copy) NSString *shortTitle;
@property (copy) NSString *preDescription;
@property (copy) NSString *liveDescription;
@property (copy) NSString *interimDescription;
@property (copy) NSString *postDescription;
@property (copy) NSString *location;

@property (copy) NSString *buttonComingSoon;
@property (copy) NSString *buttonTime;
@property (copy) NSString *buttonPlay;

@property (copy) NSString *identifier;
@property (copy) NSURL *liveURL;
@property (copy) NSURL *vodURL;
@property (assign) BOOL live;
@property (assign) NSTimeInterval duration;
@property (copy) NSDate *countdown;
@property (assign) NSUInteger order;

@property (nonatomic, readonly) NSString *localizedTimeString;
@property (nonatomic, readonly) NSString *localizedDateString;

@end
