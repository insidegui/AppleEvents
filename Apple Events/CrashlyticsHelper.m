//
//  CrashlyticsHelper.m
//  Apple Events
//
//  Created by Guilherme Rambo on 07/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "CrashlyticsHelper.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation CrashlyticsHelper

+ (instancetype)shared
{
    static CrashlyticsHelper *_helper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[CrashlyticsHelper alloc] init];
    });
    
    return _helper;
}

- (void)install
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"NSApplicationCrashOnExceptions": @YES}];
    [Fabric with:@[[Crashlytics class]]];
}

- (void)logEvent:(NSString *)event info:(NSDictionary *)info
{
    [Answers logCustomEventWithName:event customAttributes:info];
}

@end
