//
//  EVTEvent+Dictionary.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEvent+Dictionary.h"

#import "EVTVerboseLogger.h"

#define kEventDateFormat @"yyyy-MM-dd'T'HH:mm:ss'Z'ZZZZ"
#define kEventDateTimezone @"UTC"

#define kTitleLocalizedFormat @"APPLE_EVENTS.%@_TITLE"
#define kShortTitleLocalizedFormat @"APPLE_EVENTS.%@_TITLE_SHORT"
#define kLegacyDescLocalizedFormat @"APPLE_EVENTS.%@_DESC"
#define kPreDescLocalizedFormat @"APPLE_EVENTS.%@_DESC_LIVE"
#define kLiveDescLocalizedFormat @"APPLE_EVENTS.%@_DESC_LIVE"
#define kInterimDescLocalizedFormat @"APPLE_EVENTS.%@_DESC_INTERIM"
#define kPostDescLocalizedFormat @"APPLE_EVENTS.%@_DESC_POST"
#define kLocationLocalizedFormat @"APPLE_EVENTS.%@_LOCATION"

#define kHour24Placeholder @"@@HOUR24@@"
#define kHour12Placeholder @"@@HOUR12@@"
#define kAMPMPlaceholder @"@@AMPM@@"
#define kMinutePlaceholder @"@@MINUTE@@"
#define kDatePlaceholder @"@@DATE@@"
#define kYearPlaceholder @"@@YEAR@@"
#define kMonthPlaceholder @"@@MONTH@@"
#define kSyntaxMonthPlaceholder @"@@SYNTAX_MONTH@@"
#define kLocationPlaceholder @"@@LOCATION@@"

#define kButtonComingSoonFormat @"APPLE_EVENTS.BUTTON_COMING_SOON"
#define kButtonTimeFormat @"APPLE_EVENTS.BUTTON_TIME"
#define kButtonPlayFormat @"APPLE_EVENTS.BUTTON_PLAY"

#define kGenericKey @"GENERIC"

@implementation EVTEvent (Dictionary)

+ (instancetype)eventWithDictionary:(NSDictionary *)dict localizationDictionary:(NSDictionary *)localizationDict fallbackLocalizations:(NSDictionary *)fallbackLocalizations
{
    NSDictionary *effectiveLocalizationDict;
    
    [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"Parsing event dict %@, localizationDict %@", dict, effectiveLocalizationDict]];
    
    EVTEvent *event = [[EVTEvent alloc] init];
    
    event.identifier = dict[@"identifier"];
    
    if ([dict[@"order"] respondsToSelector:@selector(integerValue)]) {
        event.order = [dict[@"order"] integerValue];
    }
    
    if ([dict[@"live"] respondsToSelector:@selector(boolValue)]) {
        event.live = [dict[@"live"] boolValue];
    }
    
    if ([dict[@"duration"] respondsToSelector:@selector(doubleValue)]) {
        event.duration = [dict[@"duration"] boolValue];
    }
    
    event.liveURL = [NSURL URLWithString:dict[@"live-url"]];
    event.vodURL = [NSURL URLWithString:dict[@"vod-url"]];
    event.countdown = [self dateFromCountdownString:dict[@"countdown"]];
    
    if (!event.vodURL) {
        event.vodURL = [NSURL URLWithString:dict[@"url"]];
    }
    
    [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"Event BEFORE localization parsing: %@", event]];
    
    NSString *titleKey = [NSString stringWithFormat:kTitleLocalizedFormat, event.identifier];
    NSString *shortTitleKey = [NSString stringWithFormat:kShortTitleLocalizedFormat, event.identifier];
    NSString *preDescriptionKey = [NSString stringWithFormat:kPreDescLocalizedFormat, event.identifier];
    NSString *liveDescriptionKey = [NSString stringWithFormat:kLiveDescLocalizedFormat, event.identifier];
    NSString *interimDescriptionKey = [NSString stringWithFormat:kInterimDescLocalizedFormat, event.identifier];
    NSString *postDescriptionKey = [NSString stringWithFormat:kPostDescLocalizedFormat, event.identifier];
    NSString *locationKey = [NSString stringWithFormat:kLocationLocalizedFormat, event.identifier];
    NSString *legacyDescriptionKey = [NSString stringWithFormat:kLegacyDescLocalizedFormat, event.identifier];
    
    NSString *titleKeyGeneric = [NSString stringWithFormat:kTitleLocalizedFormat, kGenericKey];
    NSString *shortTitleKeyGeneric = [NSString stringWithFormat:kShortTitleLocalizedFormat, kGenericKey];
    NSString *preDescriptionKeyGeneric = [NSString stringWithFormat:kPreDescLocalizedFormat, kGenericKey];
    NSString *liveDescriptionKeyGeneric = [NSString stringWithFormat:kLiveDescLocalizedFormat, kGenericKey];
    NSString *interimDescriptionKeyGeneric = [NSString stringWithFormat:kInterimDescLocalizedFormat, kGenericKey];
    NSString *postDescriptionKeyGeneric = [NSString stringWithFormat:kPostDescLocalizedFormat, kGenericKey];
    
    if (localizationDict[titleKeyGeneric] == nil) {
        effectiveLocalizationDict = fallbackLocalizations[@"en"];
    } else {
        effectiveLocalizationDict = localizationDict;
    }
    
    event.location = effectiveLocalizationDict[locationKey];
    
    if (effectiveLocalizationDict[titleKey]) {
        event.title = [self description:effectiveLocalizationDict[titleKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[titleKeyGeneric]) {
        event.title = [self description:effectiveLocalizationDict[titleKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    
    if (effectiveLocalizationDict[shortTitleKey]) {
        event.shortTitle = [self description:effectiveLocalizationDict[shortTitleKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[shortTitleKeyGeneric]) {
        event.shortTitle = [self description:effectiveLocalizationDict[shortTitleKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    
    if (effectiveLocalizationDict[preDescriptionKey]) {
        event.preDescription = [self description:effectiveLocalizationDict[preDescriptionKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[preDescriptionKeyGeneric]) {
        event.preDescription = [self description:effectiveLocalizationDict[preDescriptionKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    if (effectiveLocalizationDict[liveDescriptionKey]) {
        event.liveDescription = [self description:effectiveLocalizationDict[liveDescriptionKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[liveDescriptionKeyGeneric]) {
        event.liveDescription = [self description:effectiveLocalizationDict[liveDescriptionKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    if (effectiveLocalizationDict[interimDescriptionKey]) {
        event.interimDescription = [self description:effectiveLocalizationDict[interimDescriptionKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[interimDescriptionKeyGeneric]) {
        event.interimDescription = [self description:effectiveLocalizationDict[interimDescriptionKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    if (effectiveLocalizationDict[postDescriptionKey]) {
        event.postDescription = [self description:effectiveLocalizationDict[postDescriptionKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[legacyDescriptionKey]) {
        event.postDescription = [self description:effectiveLocalizationDict[legacyDescriptionKey] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    } else if (effectiveLocalizationDict[postDescriptionKeyGeneric]) {
        event.postDescription = [self description:effectiveLocalizationDict[postDescriptionKeyGeneric] withDateTimePlaceholdersFilledWithDate:event.countdown locationPlaceholdersFilledWithLocation:event.location];
    }
    
    event.buttonPlay = effectiveLocalizationDict[kButtonPlayFormat];
    event.buttonTime = effectiveLocalizationDict[kButtonTimeFormat];
    event.buttonComingSoon = effectiveLocalizationDict[kButtonComingSoonFormat];
    
    [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"Event AFTER localization parsing: %@", event]];
    
    return event;
}

+ (NSString *)description:(NSString *)desc withDateTimePlaceholdersFilledWithDate:(NSDate *)date locationPlaceholdersFilledWithLocation:(NSString *)location
{
    if (!date) {
        [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"Nil date received when parsing event with description %@", desc]];
        return desc;
    }
    
    NSString *output = desc;
    
    static NSDateFormatter *yearFormatter;
    static NSDateFormatter *dayFormatter;
    static NSDateFormatter *monthFormatter;
    static NSDateFormatter *hour24Formatter;
    static NSDateFormatter *hour12Formatter;
    static NSDateFormatter *minuteFormatter;
    static NSDateFormatter *AMPMFormatter;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yearFormatter = [[NSDateFormatter alloc] init];
        dayFormatter = [[NSDateFormatter alloc] init];
        monthFormatter = [[NSDateFormatter alloc] init];
        hour24Formatter = [[NSDateFormatter alloc] init];
        hour12Formatter = [[NSDateFormatter alloc] init];
        minuteFormatter = [[NSDateFormatter alloc] init];
        AMPMFormatter = [[NSDateFormatter alloc] init];
        
        yearFormatter.timeZone = [NSTimeZone systemTimeZone];
        yearFormatter.dateFormat = @"Y";
        dayFormatter.timeZone = [NSTimeZone systemTimeZone];
        dayFormatter.dateFormat = @"d";
        monthFormatter.timeZone = [NSTimeZone systemTimeZone];
        monthFormatter.dateFormat = @"MMMM";
        hour24Formatter.timeZone = [NSTimeZone systemTimeZone];
        hour24Formatter.dateFormat = @"HH";
        hour12Formatter.timeZone = [NSTimeZone systemTimeZone];
        hour12Formatter.dateFormat = @"hh";
        minuteFormatter.timeZone = [NSTimeZone systemTimeZone];
        minuteFormatter.dateFormat = @"mm";
        AMPMFormatter.timeZone = [NSTimeZone systemTimeZone];
        AMPMFormatter.dateFormat = @"a";
    });
    
    NSString *year = [yearFormatter stringFromDate:date];
    NSString *day = [dayFormatter stringFromDate:date];
    NSString *month = [monthFormatter stringFromDate:date];
    NSString *hour24 = [hour24Formatter stringFromDate:date];
    NSString *hour12 = [hour12Formatter stringFromDate:date];
    NSString *minute = [minuteFormatter stringFromDate:date];
    NSString *AMPM = [AMPMFormatter stringFromDate:date];
    
    [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"year = %@ | day = %@ | month = %@ | hour24 = %@ | hour12 = %@ | minute = %@ | AMPM = %@", year, day, month, hour24, hour12, minute, AMPM]];
    
    output = [output stringByReplacingOccurrencesOfString:kYearPlaceholder withString:year];
    output = [output stringByReplacingOccurrencesOfString:kDatePlaceholder withString:day];
    output = [output stringByReplacingOccurrencesOfString:kDatePlaceholder withString:day];
    output = [output stringByReplacingOccurrencesOfString:kMonthPlaceholder withString:month];
    output = [output stringByReplacingOccurrencesOfString:kSyntaxMonthPlaceholder withString:month];
    output = [output stringByReplacingOccurrencesOfString:kHour24Placeholder withString:hour24];
    output = [output stringByReplacingOccurrencesOfString:kHour12Placeholder withString:hour12];
    output = [output stringByReplacingOccurrencesOfString:kMinutePlaceholder withString:minute];
    output = [output stringByReplacingOccurrencesOfString:kAMPMPlaceholder withString:AMPM];
    
    if (location) {
        output = [output stringByReplacingOccurrencesOfString:kLocationPlaceholder withString:location];
    }
    
    return output;
}

+ (NSDate *)dateFromCountdownString:(NSString *)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kEventDateFormat;
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:kEventDateTimezone];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
    
    NSString *dateStringWithTimezone = [NSString stringWithFormat:@"%@%@", [dateString stringByReplacingOccurrencesOfString:@".000" withString:@""], kEventDateTimezone];
    
    NSDate *date = [formatter dateFromString:dateStringWithTimezone];
    
    return date;
}

@end
