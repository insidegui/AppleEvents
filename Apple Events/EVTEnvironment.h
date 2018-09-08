//
//  EVTEnvironment.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@interface EVTEnvironment : NSObject

@property (copy) NSURL *eventsURL;
@property (copy) NSURL *stateURL;
@property (copy) NSURL *translationsURL;
@property (assign) NSTimeInterval stateCheckInterval;

+ (instancetype)currentEnvironment;
+ (instancetype)testEnvironment;
+ (instancetype)productionEnvironment;

- (NSURL *)URLForImageNamed:(NSString *)imageName;

#ifdef DEBUG
- (void)dump;
#endif

@end
