//
//  NSHTTPRequester+Cache.m
//  NS-Networking
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester+Cache.h"

#import <NSCategories/NSString+NSString_Tool.h>
#import <NSCategories/NSObject+NSObject_File.h>
#import <NSCategories/NSUsefulDefines.h>

@implementation NSHTTPRequester (Cache)

#pragma mark - Caching

+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSUInteger)ttlFile
{
    NSDictionary *cachedResponse = [NSDictionary getObjectFromCacheFile:[url md5] withTTL:ttlFile];
    if ([NSHTTPRequester sharedRequester].verbose)
        DLog(@"[%@] Cache returned => %@", NSStringFromClass([self class]), url);
    return cachedResponse;
}

+(void)removeCacheForUrl:(NSString*)url
{
    [NSObject removeCacheFile:[url md5]];
}

+(void)clearCache
{
    [NSObject removeCacheFiles];
}

+(void)cacheValue:(id)value forUrl:(NSString *)url
{
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]])
    {
        if ([NSHTTPRequester sharedRequester].verbose)
            DLog(@"[%@] Cache saved => %@", NSStringFromClass([self class]), url);
        [value saveObjectInCacheFile:[url md5]];
    }
}

@end
