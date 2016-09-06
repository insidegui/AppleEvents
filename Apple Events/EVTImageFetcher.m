//
//  EVTImageFetcher.m
//  Apple Events
//
//  Created by Guilherme Rambo on 9/5/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "EVTImageFetcher.h"

#import "EVTEnvironment.h"

@interface EVTImageFetcher ()

@property (nonatomic, strong) EVTEnvironment *environment;

@end

@implementation EVTImageFetcher

- (instancetype)initWithEnvironment:(EVTEnvironment *)environment
{
    self = [super init];
    
    _environment = environment;
    
    return self;
}

- (NSString *)__cachePathForImageNamed:(NSString *)imageName
{
    NSString *basePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    return [basePath stringByAppendingPathComponent:[imageName stringByAppendingPathExtension:@"jpg"]];
}

- (void)fetchImageNamed:(NSString *)imageName completionHandler:(void (^)(NSImage *))completionHandler
{
    NSString *path = [self __cachePathForImageNamed:imageName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        if (image) {
            completionHandler(image);
            return;
        }
    }
    
    NSURL *imageURL = [self.environment URLForImageNamed:imageName];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [data writeToFile:path atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([[NSImage alloc] initWithData:data]);
        });
    }];
    [task resume];
}

@end
