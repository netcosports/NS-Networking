//
//  NSHTTPRequester+Strategy.m
//  FoxSports
//
//  Created by Guillaume on 30/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester+Strategy.h"

#import "NSHTTPRequester+Serializer.h"
#import "NSHTTPRequester+Cache.h"

#import <NSTCategories/NSUsefulDefines.h>

@implementation NSHTTPRequester (Strategy)

+ (NSURLSessionDataTask *)strategicGET:(NSString *)url
                          usingCacheTTL:(NSInteger)cacheTTL
         strategicBlockReachableAndCache:(void(^)(NSDictionary *response,
                                                   NSInteger httpCode,
                                                   NSURLSessionTask *task,
                                                   NSError *error,
                                                   BOOL isCached))strategicBlocReachCachedData
       strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response,
                                                   NSInteger httpCode,
                                                   NSURLSessionTask *task,
                                                   NSError *error,
                                                   BOOL isCached))strategicBlocDataUpdated
      strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response,
                                                    NSInteger httpCode,
                                                    NSURLSessionTask *task,
                                                    NSError *error,
                                                    BOOL isCached))strategicBlocNoDataEver
     andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response,
                                                     NSInteger httpCode,
                                                     NSURLSessionTask *task,
                                                     NSError *error,
                                                     BOOL isCached))strategicBlocCacheData
{
    // Start monitoring reachability
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    // Check cached data first
    NSDictionary *cachedResponse = [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];
    BOOL hasCache = (cachedResponse != nil);

    // If not reachable and cache exists
    if (![AFNetworkReachabilityManager sharedManager].isReachable && hasCache) {
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        if (strategicBlocCacheData)
            strategicBlocCacheData(cachedResponse, 0, nil, nil, YES);
        return nil;
    }

    // If not reachable and no cache
    if (![AFNetworkReachabilityManager sharedManager].isReachable && !hasCache) {
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        if (strategicBlocNoDataEver)
            strategicBlocNoDataEver(nil, 0, nil, [NSError errorWithDomain:@"NSHTTPRequester"
                                                                    code:-1009
                                                                userInfo:@{NSLocalizedDescriptionKey: @"No network and no cached data"}],
                                    NO);
        return nil;
    }

    // Create URLSessionDataTask using existing NSHTTPRequester GET
    NSURLSessionDataTask *task = [NSHTTPRequester GET:url
                                         usingCacheTTL:cacheTTL
                                     requestSerializer:[AFJSONRequestSerializer serializer]
                                    responseSerializer:[AFJSONResponseSerializer serializer]
                                   andCompletionBlock:^(NSDictionary *response,
                                                        NSInteger httpCode,
                                                        NSURLSessionTask *task,
                                                        NSError *error,
                                                        BOOL isCached)
    {
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];

        BOOL reachable = [AFNetworkReachabilityManager sharedManager].isReachable;

        if (reachable && isCached) {
            if (strategicBlocReachCachedData)
                strategicBlocReachCachedData(response, httpCode, task, error, isCached);
        } else if (reachable && !isCached) {
            if (strategicBlocDataUpdated)
                strategicBlocDataUpdated(response, httpCode, task, error, isCached);
        } else if (!reachable && isCached) {
            if (strategicBlocCacheData)
                strategicBlocCacheData(response, httpCode, task, error, isCached);
        } else if (!reachable && !isCached) {
            if (strategicBlocNoDataEver)
                strategicBlocNoDataEver(response, httpCode, task, error, isCached);
        }
    }];

    return task;
}

//+(AFHTTPRequestOperation *)strategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
//strategicBlockReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocReachCachedData
//strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
//strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
//andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocCacheData
//{
//    return [NSHTTPRequester strategicGET:url
//                                usingCacheTTL:cacheTTL
//                            requestSerializer:[AFJSONRequestSerializer serializer]
//                           responseSerializer:[AFJSONResponseSerializer serializer]
//              strategicBlockReachableAndCache:strategicBlocReachCachedData
//            strategicBlockReachableAndNoCache:strategicBlocDataUpdated
//         strategicBlockNotReachableAndNoCache:strategicBlocNoDataEver
//        andStrategicBlockNotReachableAndCache:strategicBlocCacheData];
//}

@end
