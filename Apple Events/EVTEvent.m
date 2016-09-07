//
//  EVTEvent.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEvent.h"

@implementation EVTEvent

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_shortTitle forKey:@"shortTitle"];
    [aCoder encodeObject:_preDescription forKey:@"preDescription"];
    [aCoder encodeObject:_liveDescription forKey:@"liveDescription"];
    [aCoder encodeObject:_interimDescription forKey:@"interimDescription"];
    [aCoder encodeObject:_postDescription forKey:@"postDescription"];
    [aCoder encodeObject:_location forKey:@"location"];
    
    [aCoder encodeObject:_buttonComingSoon forKey:@"buttonComingSoon"];
    [aCoder encodeObject:_buttonTime forKey:@"buttonTime"];
    [aCoder encodeObject:_buttonPlay forKey:@"buttonPlay"];
    
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_liveURL forKey:@"liveURL"];
    [aCoder encodeObject:_vodURL forKey:@"vodURL"];
    [aCoder encodeBool:_live forKey:@"live"];
    [aCoder encodeDouble:_duration forKey:@"duration"];
    [aCoder encodeObject:_countdown forKey:@"countdown"];
    [aCoder encodeInteger:_order forKey:@"order"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    _title = [aDecoder decodeObjectForKey:@"title"];
    _shortTitle = [aDecoder decodeObjectForKey:@"shortTitle"];
    _preDescription = [aDecoder decodeObjectForKey:@"preDescription"];
    _liveDescription = [aDecoder decodeObjectForKey:@"liveDescription"];
    _interimDescription = [aDecoder decodeObjectForKey:@"interimDescription"];
    _postDescription = [aDecoder decodeObjectForKey:@"postDescription"];
    _location = [aDecoder decodeObjectForKey:@"location"];
    
    _buttonComingSoon = [aDecoder decodeObjectForKey:@"buttonComingSoon"];
    _buttonTime = [aDecoder decodeObjectForKey:@"buttonTime"];
    _buttonPlay = [aDecoder decodeObjectForKey:@"buttonPlay"];
    
    _identifier = [aDecoder decodeObjectForKey:@"identifier"];
    _liveURL = [aDecoder decodeObjectForKey:@"liveURL"];
    _vodURL = [aDecoder decodeObjectForKey:@"vodURL"];
    _live = [aDecoder decodeBoolForKey:@"live"];
    _duration = [aDecoder decodeDoubleForKey:@"duration"];
    _countdown = [aDecoder decodeObjectForKey:@"countdown"];
    _order = [aDecoder decodeIntegerForKey:@"order"];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    EVTEvent *copy = [[EVTEvent alloc] init];
 
    copy.title = _title;
    copy.shortTitle = _shortTitle;
    copy.preDescription = _preDescription;
    copy.liveDescription = _liveDescription;
    copy.interimDescription = _interimDescription;
    copy.postDescription = _postDescription;
    copy.location = _location;
    
    copy.buttonComingSoon = _buttonComingSoon;
    copy.buttonTime = _buttonTime;
    copy.buttonPlay = _buttonPlay;
    
    copy.identifier = _identifier;
    copy.liveURL = _liveURL;
    copy.vodURL = _vodURL;
    copy.live = _live;
    copy.duration = _duration;
    copy.countdown = _countdown;
    copy.order = _order;
    
    return copy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<EVTEvent 0x%lX> ID = %@, title = %@ localizedDate = %@ countdown = %@", (unsigned long)self.hash, self.identifier, self.title, self.localizedDateString, self.countdown];
}

- (NSString *)localizedTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    return [formatter stringFromDate:self.countdown];
}

- (NSString *)localizedDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateStyle = NSDateFormatterLongStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    return [formatter stringFromDate:self.countdown];
}

@end
