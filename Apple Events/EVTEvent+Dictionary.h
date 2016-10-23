//
//  EVTEvent+Dictionary.h
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEvent.h"

@interface EVTEvent (Dictionary)

+ (instancetype)eventWithDictionary:(NSDictionary *)dict localizationDictionary:(NSDictionary *)localizationDict fallbackLocalizations:(NSDictionary *)fallbackLocalizations;

@end
