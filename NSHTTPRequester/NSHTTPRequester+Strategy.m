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

@implementation NSHTTPRequester (Strategy)

+(void)strategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer
responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer
strategicBlockReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocReachCachedData
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNotReachCachedData
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [NSHTTPRequester GET:url usingCacheTTL:cacheTTL requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
    {
        if ([AFNetworkReachabilityManager sharedManager].isReachable == YES && isCached == YES)
        {
            if (strategicBlocReachCachedData)
                strategicBlocReachCachedData(response, httpCode, requestOperation, error, isCached);
        }
        else if ([AFNetworkReachabilityManager sharedManager].isReachable == NO && isCached == YES)
        {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            
            if (strategicBlocNotReachCachedData)
                strategicBlocNotReachCachedData(response, httpCode, requestOperation, error, isCached);
        }
        else if ([AFNetworkReachabilityManager sharedManager].isReachable == NO && isCached == NO) // Cache exists in that case ?
        {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            
            if (response || requestOperation.responseData)
            {
                DLog(@"Response exist ??? WHY ??");
            }
            if (error || response == nil)
            {
                id cachedResponse = [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];
                if (cachedResponse)
                {
                    // Here it means it already came into
                    // else if ([AFNetworkReachabilityManager sharedManager].isReachable == NO && isCached == YES)
                    // SO strategicBlocCacheData has already been called.
                }
                else
                {
                    if (strategicBlocNoDataEver)
                        strategicBlocNoDataEver(response, httpCode, requestOperation, error, isCached);
                }
            }
            
        }
        else if ([AFNetworkReachabilityManager sharedManager].isReachable == YES && isCached == NO) // Cache has been created, it didn't exist before, good to go!
        {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
            
            if (strategicBlocDataUpdated)
                strategicBlocDataUpdated(response, httpCode, requestOperation, error, isCached);
        }
    }];
}

+(void)strategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
strategicBlockReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocReachCachedData
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocCacheData
{
                [NSHTTPRequester strategicGET:url
                                usingCacheTTL:cacheTTL
                            requestSerializer:[AFJSONRequestSerializer serializer]
                           responseSerializer:[AFJSONResponseSerializer serializer]
              strategicBlockReachableAndCache:strategicBlocReachCachedData
            strategicBlockReachableAndNoCache:strategicBlocDataUpdated
         strategicBlockNotReachableAndNoCache:strategicBlocNoDataEver
        andStrategicBlockNotReachableAndCache:strategicBlocCacheData];
}

@end
