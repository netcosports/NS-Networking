//
//  NSHTTPRequester+Strategy.h
//  FoxSports
//
//  Created by Guillaume on 30/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester.h"

@interface NSHTTPRequester (Strategy)

+(void)strategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
  requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer
 responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocCacheData;


+(void)stategicGET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL
strategicBlockReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocDataUpdated
strategicBlockNotReachableAndNoCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocNoDataEver
andStrategicBlockNotReachableAndCache:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))strategicBlocCacheData;

@end
