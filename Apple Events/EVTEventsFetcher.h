//
//  EVTEventsFetcher.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EVTEvent, EVTEnvironment, EVTEventsCache;

@interface EVTEventsFetcher : NSObject

- (instancetype)initWithEnvironment:(EVTEnvironment *)environment cache:(EVTEventsCache *)cache;
- (void)fetchEventsWithCompletionHandler:(void (^)(NSError *error, NSArray <EVTEvent *> *events))completionHandler;

- (void)fetchCurrentEventIdentifierCompletionHandler:(void (^)(NSError *error, NSString *identifier))completionHandler;

@end
