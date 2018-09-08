//
//  CASTV2PlatformReader.h
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 20/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CASTV2PlatformReader : NSObject

- (instancetype)initWithStream:(NSInputStream *)stream;

- (void)readStream;
- (NSData *__nullable)nextMessage;

@end

NS_ASSUME_NONNULL_END
