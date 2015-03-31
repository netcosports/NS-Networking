//
//  NSHTTPRequester+Private.h
//  FoxSports
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#ifndef FoxSports_NSHTTPRequester_Private_h
#define FoxSports_NSHTTPRequester_Private_h

typedef enum
{
    eNSHttpRequestGET,
    eNSHttpRequestPOST,
    eNSHttpRequestPUT,
    eNSHttpRequestDELETE,
    eNSHttpRequestUPLOAD,
} eNSHttpRequestType;

@interface NSHTTPRequester ()
{
    NSMutableArray *customPropertiesForUrl;
}

-(AFHTTPRequestOperation *)createAfNetworkingOperationWithUrl:(NSString *)url
                                              httpRequestType:(eNSHttpRequestType)httpRequestType
                                            requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                           responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
                                                   parameters:(id)parameters
                                                usingCacheTTL:(NSInteger)cacheTTL
                                           andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion;

@end

#endif
