//
//  NSHTTPRequester+Serializer.m
//  FoxSports
//
//  Created by Guillaume on 31/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester+Serializer.h"
#import "NSHTTPRequester+Private.h"

@implementation NSHTTPRequester (Serializer)

#pragma mark - HTTP Methods
#pragma mark GET
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestGET requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:nil usingCacheTTL:cacheTTL andCompletionBlock:completion];
}

#pragma mark POST
+(void)POST:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPOST requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
}

#pragma mark PUT
+(void)PUT:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPUT requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
}

#pragma mark DELETE
+(void)DELETE:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDELETE requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
}

#pragma mark UPLOAD
+(void)UPLOAD:(NSString *)url withParameters:(id)params requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer sendingBlock:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded))sending andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestUPLOAD requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
                                                {
                                                    if (completion)
                                                        completion(response, httpCode, requestOperation, error);
                                                }];
    
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         double percentDone = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite) * 100;
         if (sending)
             sending(totalBytesWritten, totalBytesExpectedToWrite, percentDone);
     }];
}

@end