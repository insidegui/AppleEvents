//
//  EVTEnvironment.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEnvironment.h"

@interface EVTEnvironment ()

@property (nonatomic, copy) NSURL *baseURL;

@end

@implementation EVTEnvironment

+ (instancetype)currentEnvironment
{
#ifdef DEBUG
    if ([[NSProcessInfo processInfo].arguments containsObject:@"--test"]) {
        NSLog(@"USING TEST ENVIRONMENT");
        return [self testEnvironment];
    } else {
        NSLog(@"USING PRODUCTION ENVIRONMENT");
        return [self productionEnvironment];
    }
#else
    return [self productionEnvironment];
#endif
}

+ (instancetype)testEnvironment
{
    static EVTEnvironment *testEnv;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testEnv = [[EVTEnvironment alloc] init];
        testEnv.baseURL = [NSURL URLWithString:@"http://localhost"];
        testEnv.stateCheckInterval = 5.0;
    });
    
    return testEnv;
}

+ (instancetype)productionEnvironment
{
    static EVTEnvironment *prodEnv;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prodEnv = [[EVTEnvironment alloc] init];
        prodEnv.baseURL = [NSURL URLWithString:@"https://itunesevents.apple.com/4b7fad4f3f945dedf976096ae7cdae1f59f394a9/data/"];
        prodEnv.stateCheckInterval = 60.0;
    });
    
    return prodEnv;
}

- (void)setBaseURL:(NSURL *)baseURL
{
    [self willChangeValueForKey:@"baseURL"];
    _baseURL = [baseURL copy];
    [self didChangeValueForKey:@"baseURL"];
    
    self.eventsURL = [_baseURL URLByAppendingPathComponent:@"events.js"];
    self.stateURL = [_baseURL URLByAppendingPathComponent:@"state.of.events.json"];
    self.translationsURL = [_baseURL URLByAppendingPathComponent:@"translations.js"];
}

- (NSURL *)URLForImageNamed:(NSString *)imageName
{
    return [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"events/%@.jpg", imageName]];
}

#ifdef DEBUG
- (void)dump
{
    NSLog(@"DUMPING ENVIRONMENT");
    NSLog(@"baseURL = %@", self.baseURL);
    NSLog(@"eventsURL = %@", self.eventsURL);
    NSLog(@"stateURL = %@", self.stateURL);
    NSLog(@"translationsURL = %@", self.translationsURL);
    NSLog(@"test image URL = %@", [self URLForImageNamed:@"SEP2016"]);
}
#endif


@end
