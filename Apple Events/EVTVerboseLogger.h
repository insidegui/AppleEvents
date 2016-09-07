//
//  EVTVerboseLogger.h
//  Apple Events
//
//  Created by Guilherme Rambo on 07/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@interface EVTVerboseLogger : NSObject

+ (instancetype)shared;

- (void)addMessage:(NSString *)message;

@end
