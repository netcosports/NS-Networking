//
//  NSHTTPRequester+Cache.h
//  NS-Networking
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester.h"

@interface NSHTTPRequester (Cache)

/**
 *  Local client-side caching mechanism [Get]
 *
 *  @param url     Url for which to save a cached version of the response
 *  @param ttlFile TTL on the file to get the cache from.
 *
 *  @return The cached reponse
 */
+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSUInteger)ttlFile;

/**
 *  Local client-side caching mechanism [Remove]
 *
 *  @param url Url for which the cache should be removed.
 */
+(void)removeCacheForUrl:(NSString*)url;

/**
 *  Local client-side caching mechanism [Save]
 *
 *  @param value Response to cache
 *  @param url   Url of the response to cache
 */
+(void)cacheValue:(id)value forUrl:(NSString *)url;

/**
 *  Remove all cached data stored on Disk & RAM.
 *
 */
+(void)clearCache;


@end
