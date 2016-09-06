//
//  EVTEventsCache.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EVTEvent;

@interface EVTEventsCache : NSObject

+ (instancetype)cache;

@property (nonatomic, readonly) NSArray <EVTEvent *> *cachedEvents;

- (void)cacheEvents:(NSArray <EVTEvent * > *)events;

@end
