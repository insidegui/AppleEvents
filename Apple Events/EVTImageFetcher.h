//
//  EVTImageFetcher.h
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

@import Cocoa;

@class EVTEnvironment;

@interface EVTImageFetcher : NSObject

- (instancetype)initWithEnvironment:(EVTEnvironment *)environment;

- (void)fetchImageNamed:(NSString *)imageName completionHandler:(void (^)(NSImage *))completionHandler;

@end
