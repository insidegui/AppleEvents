//
//  EVTEventsFetcher.m
//  Apple Events
//
//  Created by Guilherme Rambo on 05/09/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTEventsFetcher.h"

#import "EVTEnvironment.h"
#import "EVTEventsCache.h"
#import "EVTEvent.h"
#import "EVTEvent+Dictionary.h"
#import "EVTVerboseLogger.h"

#define kEventsFetcherErrorDomain @"br.com.guilhermerambo.AppleEvents.EventsFetcher"
#define kEventsFetcherEmptyDataErrorCode 10
#define kEventsFetcherEmptyDataErrorMessage @"The server returned an empty response"
#define kEventsFetcherInvalidUTF8DataErrorCode 20
#define kEventsFetcherInvalidUTF8DataErrorMessage @"The server returned invalid UTF8 data"
#define kEventsFetcherJSParseErrorCode 30
#define kEventsFetcherJSParseErrorMessage @"Unable to parse the javascript code returned from the server"
#define kEventsFetcherJSONParseErrorCode 40
#define kEventsFetcherJSONParseErrorMessage @"Unable to parse JSON data returned from the server"
#define kEventsFetcherEventsParseErrorCode 50
#define kEventsFetcherEventsParseErrorMessage @"Unable to parse events from dictionary returned from the server"
#define kEventsFetcherTranslationsErrorCode 60
#define kEventsFetcherTranslationsErrorMessage @"Unable to download localization file from the server"
#define kEventsFetcherGeneralExceptionErrorCode -10

#define kEventsFetcherSimulatedErrorMessage @"This is a simulated error for testing purposes"
#define kEventsFetcherSimulatedErrorCode -20

@import JavaScriptCore;

@interface EVTEventsFetcher ()

@property (nonatomic, strong) EVTEnvironment *environment;
@property (nonatomic, strong) EVTEventsCache *cache;
@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, readonly) NSArray <NSString *> *availableLocalizations;
@property (nonatomic, readonly) NSString *languageForLocalization;

@end

@implementation EVTEventsFetcher
{
    NSString *_cachedLanguageForLocalization;
}

- (NSArray<NSString *> *)availableLocalizations
{
    // OBS: available languages taken from Apple's TV app
    return @[@"en", @"en-GB", @"en-CA", @"en-AU", @"fr", @"fr-CA", @"de", @"it", @"nl", @"es", @"es-MX", @"pt", @"ja", @"tr", @"ru"];
}

- (NSString *)__computeLanguageForLocalization
{
    // OBS: language replacements taken from Apple's TV app
    
    NSString *lang = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    
    if ([lang isEqualToString:@"es-ES"]) {
        lang = @"es";
    } else if([lang isEqualToString:@"en-US"]) {
        lang = @"en";
    }
    
    if (![self.availableLocalizations containsObject:lang]) {
        NSLog(@"Localization not available for %@, falling back to english", lang);
        return @"en";
    } else {
        return lang;
    }
}

- (NSString *)languageForLocalization
{
    if (!_cachedLanguageForLocalization) _cachedLanguageForLocalization = [self __computeLanguageForLocalization];
    
    return _cachedLanguageForLocalization;
}


- (instancetype)initWithEnvironment:(EVTEnvironment *)environment cache:(EVTEventsCache *)cache
{
    self = [super init];
    
    _cache = cache;
    _environment = environment;
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    return self;
}

- (void)fetchEventsWithCompletionHandler:(void (^)(NSError *, NSArray<EVTEvent *> *))completionHandler
{
    [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"System timezone: %@. Language code: %@", [NSTimeZone systemTimeZone].name, [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]]];
    
    [self __fetchTranslationsWithCompletionHandler:^(NSError *translationError, NSString *translationCode) {
        [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"__fetchTranslationsWithCompletionHandler returned error %@, result %@", translationError, translationCode]];
        
        if (translationError || !translationCode || [translationCode isEqualToString:@""]) {
            NSError *error = [self __errorWithCode:kEventsFetcherTranslationsErrorCode message:kEventsFetcherTranslationsErrorMessage];
            completionHandler(error, nil);
            return;
        }
        
        [self __fetchTranslatedEventsWithTranslations:translationCode completionHandler:completionHandler];
    }];
}

- (void)__fetchTranslationsWithCompletionHandler:(void (^)(NSError *, NSString *))completionHandler
{
    NSURLSessionDataTask *translationsTask = [self.session dataTaskWithURL:self.environment.translationsURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error downloading translations JS: %@", error);
                completionHandler(error, nil);
            });
            return;
        }
        
        if (!data) {
            NSError *dataError = [self __errorWithCode:kEventsFetcherTranslationsErrorCode message:kEventsFetcherTranslationsErrorMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(dataError, nil);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(nil, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        });
    }];
    [translationsTask resume];
}

/// Returns the most recent event's identifier (used by the Dock tile plugin)
- (void)fetchCurrentEventIdentifierCompletionHandler:(void (^)(NSError *, NSString *))completionHandler
{
    _context = [[JSContext alloc] init];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:self.environment.eventsURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error, nil);
            });
            return;
        }
        
        if (!data) {
            NSError *dataError = [self __errorWithCode:kEventsFetcherEmptyDataErrorCode message:kEventsFetcherEmptyDataErrorMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(dataError, nil);
            });
            return;
        }
        
        NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!script) {
            NSError *dataError = [self __errorWithCode:kEventsFetcherInvalidUTF8DataErrorCode message:kEventsFetcherInvalidUTF8DataErrorMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(dataError, nil);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.context evaluateScript:script];
                
                JSValue *eventsValue = [self.context evaluateScript:@"EVENTS"];
                
                NSDictionary *eventsDict = [eventsValue toDictionary];
                
                if (!eventsDict) {
                    NSError *jsError = [self __errorWithCode:kEventsFetcherJSParseErrorCode message:kEventsFetcherJSParseErrorMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(jsError, nil);
                    });
                    return;
                }
                
                NSArray *identifiers = [eventsDict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    if ([[obj1 objectForKey:@"live"] boolValue]) {
                        return NSOrderedAscending;
                    } else {
                        return NSOrderedDescending;
                    }
                }];
                
                completionHandler(nil, identifiers.firstObject);
            } @catch (NSException *e) {
                completionHandler([self __errorWithCode:kEventsFetcherGeneralExceptionErrorCode message:e.reason], nil);
            }
        });
    }];
    [task resume];
}

/// Returns the events with translated strings
- (void)__fetchTranslatedEventsWithTranslations:(NSString *)translationsSource completionHandler:(void (^)(NSError *, NSArray<EVTEvent *> *))completionHandler
{
    _context = [[JSContext alloc] init];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:self.environment.eventsURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([[NSProcessInfo processInfo].arguments containsObject:@"--simulateErrors"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler([self __errorWithCode:kEventsFetcherSimulatedErrorCode message:kEventsFetcherSimulatedErrorMessage], nil);
            });
            return;
        }
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error, nil);
            });
            return;
        }
        
        if (!data) {
            NSError *dataError = [self __errorWithCode:kEventsFetcherEmptyDataErrorCode message:kEventsFetcherEmptyDataErrorMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(dataError, nil);
            });
            return;
        }
        
        NSString *script = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!script) {
            NSError *dataError = [self __errorWithCode:kEventsFetcherInvalidUTF8DataErrorCode message:kEventsFetcherInvalidUTF8DataErrorMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(dataError, nil);
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.context evaluateScript:translationsSource];
                [self.context evaluateScript:script];
                
                JSValue *eventsValue = [self.context evaluateScript:@"EVENTS"];
                JSValue *localizationValue = [self.context evaluateScript:@"LOCALIZATION"];
                
                [[EVTVerboseLogger shared] addMessage:[NSString stringWithFormat:@"eventsValue = %@, localizationValue = %@", eventsValue, localizationValue]];
                
                NSDictionary *eventsDict = [eventsValue toDictionary];
                NSDictionary *localizationDict = [localizationValue toDictionary];
                
                if (!eventsDict || !localizationDict) {
                    NSError *jsError = [self __errorWithCode:kEventsFetcherJSParseErrorCode message:kEventsFetcherJSParseErrorMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(jsError, nil);
                    });
                    return;
                }
                
                NSDictionary *languageDict = localizationDict[self.languageForLocalization];
                if (!languageDict) languageDict = localizationDict[@"en"];
                
                NSArray *events = [self __eventsArrayFromServerDictionary:eventsDict withLocalization:languageDict fallbackLocalizations:localizationDict];
                if (!events || events.count == 0) {
                    NSError *eventsError = [self __errorWithCode:kEventsFetcherEventsParseErrorCode message:kEventsFetcherEventsParseErrorMessage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(eventsError, nil);
                    });
                    return;
                }
                
                [self.cache cacheEvents:events];
                completionHandler(nil, events);
            } @catch (NSException *e) {
                completionHandler([self __errorWithCode:kEventsFetcherGeneralExceptionErrorCode message:e.reason], nil);
            }
        });
    }];
    [task resume];
}

- (NSError *)__errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:kEventsFetcherErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (NSArray <EVTEvent *> *)__eventsArrayFromServerDictionary:(NSDictionary *)dict withLocalization:(NSDictionary *)localizationDict fallbackLocalizations:(NSDictionary *)fallbackLocalizations
{
    NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:dict.allKeys.count];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL * stop) {
        @autoreleasepool {
            NSMutableDictionary *eventDict = [obj mutableCopy];
            eventDict[@"identifier"] = key;
            EVTEvent *event = [EVTEvent eventWithDictionary:eventDict localizationDictionary:localizationDict fallbackLocalizations:fallbackLocalizations];
            if (event) [events addObject:event];
        }
    }];
    
    return [events sortedArrayUsingComparator:^NSComparisonResult(EVTEvent *obj1, EVTEvent *obj2) {
        if (obj1.order == obj2.order) {
            return [obj2.countdown compare:obj1.countdown];
        } else {
            if (obj1.order > obj2.order) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }
    }];
}

@end
