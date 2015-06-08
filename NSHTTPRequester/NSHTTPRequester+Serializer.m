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
+(AFHTTPRequestOperation *)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestGET requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:nil usingCacheTTL:cacheTTL andCompletionBlock:completion];
    return requestOperation;
}

#pragma mark POST
+(AFHTTPRequestOperation *)POST:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPOST requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
    return requestOperation;
}

#pragma mark PUT
+(AFHTTPRequestOperation *)PUT:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPUT requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
    return requestOperation;
}

#pragma mark DELETE
+(AFHTTPRequestOperation *)DELETE:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDELETE requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:params usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
     {
         if (completion)
             completion(response, httpCode, requestOperation, error);
     }];
    return requestOperation;
}

#pragma mark UPLOAD
+(AFHTTPRequestOperation *)UPLOADmp:(NSString *)url withParameters:(id)params requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer sendingBlock:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded))sending andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
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
    return requestOperation;
}

+(AFHTTPRequestOperation *)DOWNLOAD:(NSString *)url requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer downloadingBlock:(void(^)(long long totalBytesRead, long long totalBytesExpectedToRead, double percentageDownloaded))downloading andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDOWNLOAD requestSerializer:customRequestSerializer responseSerializer:customResponseSerializer parameters:nil usingCacheTTL:0 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached)
                                                {
                                                    if (completion)
                                                        completion(response, httpCode, requestOperation, error);
                                                }];
    
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    {
         double percentDone = ((double)totalBytesRead / (double)totalBytesExpectedToRead) * 100;
        if (downloading)
            downloading(totalBytesRead, totalBytesExpectedToRead, percentDone);
    }];
    return requestOperation;
}
@end
