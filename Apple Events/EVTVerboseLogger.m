//
//  EVTVerboseLogger.m
//  Apple Events
//
//  Created by Guilherme Rambo on 07/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTVerboseLogger.h"

@implementation EVTVerboseLogger
{
    NSMutableString *_logString;
}

+ (instancetype)shared
{
#ifdef DOCKTILE
    return nil;
#else
    static EVTVerboseLogger *_logger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logger = [[EVTVerboseLogger alloc] init];
    });
    
    return _logger;
#endif
}

- (instancetype)init
{
    self = [super init];
    
    _logString = [NSMutableString new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate) name:NSApplicationWillTerminateNotification object:nil];
    
    return self;
}

- (void)addMessage:(NSString *)message
{
#ifdef VERBOSELOG
    if (!_logString) _logString = [NSMutableString new];

    [_logString appendString: message];
    [_logString appendString: @"\n"];
#endif
}

- (void)writeLogToFile:(NSString *)filePath
{
    if (!_logString || [_logString isEqualToString:@""]) return;
    
    [_logString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)appWillTerminate
{
    [self writeLogToFile:[NSString pathWithComponents:@[NSHomeDirectory(), @"Desktop", @"AppleEventsVerbose.log"]]];
}

@end
