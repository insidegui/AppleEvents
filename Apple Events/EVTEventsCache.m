//
//  EVTEventsCache.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEventsCache.h"

@implementation EVTEventsCache

+ (instancetype)cache
{
    EVTEventsCache *cache = [[EVTEventsCache alloc] init];
    
    return cache;
}

- (void)cacheEvents:(NSArray<EVTEvent *> *)events
{
    NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:events];
    
    [[NSUserDefaults standardUserDefaults] setObject:cacheData forKey:@"events"];
}

- (NSArray<EVTEvent *> *)cachedEvents
{
    NSData *cacheData = [[NSUserDefaults standardUserDefaults] objectForKey:@"events"];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
}

@end
