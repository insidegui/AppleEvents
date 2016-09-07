//
//  CrashlyticsHelper.h
//  Apple Events
//
//  Created by Guilherme Rambo on 07/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashlyticsHelper : NSObject

+ (instancetype)shared;

- (void)install;
- (void)logEvent:(NSString *)event info:(NSDictionary *)info;

@end
