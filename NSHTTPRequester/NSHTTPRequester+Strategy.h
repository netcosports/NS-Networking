//
//  NSHTTPRequester+Strategy.h
//  FoxSports
//
//  Created by Guillaume on 30/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester.h"

@interface NSHTTPRequester (Strategy)

/**
 *  Implementation of the strategy pattern to deal with the 4 use cases around the networking
 *  reachability state & the local cache (Post-Serialization cache -- NSHTTPRequester layer).
 *
 *  @param url     Url for which to save a cached version of the response
 *  @param ttlFile TTL on the file to get the cache from.
 *  @param requestSerializer    Custom request serializer implementing protocol `AFURLRequestSerialization'
 *  @param responseSerializer   Custom response serializer implementing protocol `AFURLResponseSerialization'
 
 *  @param strategicBlockReachableAndCache: The network is reachable & the data comes from the NSHTTPRequester cache.
 *  @param strategicBlockReachableAndNoCache: The network is reachable & the data does not come from the NSHTTPRequester cache.
 *  @param strategicBlockNotReachableAndNoCache: The network is not reachable & the data does not come from the NSHTTPRequester cache.
 *  @param andStrategicBlockNotReachableAndCache: The network is not reachable & the data comes from the NSHTTPRequester cache.
 *
 *  @return The cached reponse
 */
+(void)strategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
  requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer
 responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer
strategicBlockReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocReachCachedData
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNotReachCachedData;

/**
 *  Short version of previous declaration. The custom serializers are pre-defined as AFJSONRequestSerializer & AFJSONResponseSerializer
 *
 */
+(void)stategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
strategicBlockReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocReachCachedData
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocCacheData;

@end
