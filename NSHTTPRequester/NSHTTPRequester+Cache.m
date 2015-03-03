//
//  NSHTTPRequester+Cache.m
//  FoxSports
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester+Cache.h"
#import "NSString+NSString_Tool.h"
#import "NSObject+NSObject_File.h"
#import "NSDictionary+NSDictionary_File.h"

@implementation NSHTTPRequester (Cache)

#pragma mark - Caching

+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile
{
    NSDictionary *cachedResponse = [NSDictionary getDataFromFileCache:[url md5] temps:(int)ttlFile del:NO];
    DLog(@"[%@] Cache returned => %@", NSStringFromClass([self class]), url);
    return cachedResponse;
}

+(void)removeCacheForUrl:(NSString*)url
{
    [NSObject removeFileCache:[url md5]];
}

+(void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSError *error;
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error];
    if (!error)
    {
        for (NSString *file in tmpDirectory)
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:&error];
    }
    else
    {
        DLog(@"[%@] Error accessing temporary directory: %@", NSStringFromClass([self class]), [error description]);
    }
}

+(void)cacheValue:(id)value forUrl:(NSString *)url
{
    if (value && [value isKindOfClass:[NSDictionary class]])
    {
        DLog(@"[%@] Cache saved => %@", NSStringFromClass([self class]), url);
        [value setDataSaveNSDictionaryCache:[url md5]];
    }
}

@end
