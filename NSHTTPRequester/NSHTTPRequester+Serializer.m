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

#pragma mark - GET
+ (NSURLSessionDataTask *)GET:(NSString *)url
                  usingCacheTTL:(NSInteger)cacheTTL
               requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
              responseSerializer:(AFHTTPResponseSerializer *)customResponseSerializer
             andCompletionBlock:(void(^)(NSDictionary *response,
                                         NSInteger httpCode,
                                         NSURLSessionTask *task,
                                         NSError *error,
                                         BOOL isCached))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    return [sharedRequester createAfNetworkingTaskWithUrl:url
                                          httpRequestType:eNSHttpRequestGET
                                        requestSerializer:customRequestSerializer
                                       responseSerializer:customResponseSerializer
                                               parameters:nil
                                            usingCacheTTL:cacheTTL
                                       andCompletionBlock:completion];
}

#pragma mark - POST
+ (NSURLSessionDataTask *)POST:(NSString *)url
                withParameters:(id)params
             requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
            responseSerializer:(AFHTTPResponseSerializer *)customResponseSerializer
           andCompletionBlock:(void(^)(NSDictionary *response,
                                       NSInteger httpCode,
                                       NSURLSessionTask *task,
                                       NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    return [sharedRequester createAfNetworkingTaskWithUrl:url
                                          httpRequestType:eNSHttpRequestPOST
                                        requestSerializer:customRequestSerializer
                                       responseSerializer:customResponseSerializer
                                               parameters:params
                                            usingCacheTTL:0
                                       andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, NSURLSessionTask *task, NSError *error, BOOL isCached)
    {
        if (completion) completion(response, httpCode, task, error);
    }];
}

#pragma mark - PUT
+ (NSURLSessionDataTask *)PUT:(NSString *)url
               withParameters:(id)params
            requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
           responseSerializer:(AFHTTPResponseSerializer *)customResponseSerializer
          andCompletionBlock:(void(^)(NSDictionary *response,
                                      NSInteger httpCode,
                                      NSURLSessionTask *task,
                                      NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    return [sharedRequester createAfNetworkingTaskWithUrl:url
                                          httpRequestType:eNSHttpRequestPUT
                                        requestSerializer:customRequestSerializer
                                       responseSerializer:customResponseSerializer
                                               parameters:params
                                            usingCacheTTL:0
                                       andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, NSURLSessionTask *task, NSError *error, BOOL isCached)
    {
        if (completion) completion(response, httpCode, task, error);
    }];
}

#pragma mark - DELETE
+ (NSURLSessionDataTask *)DELETE:(NSString *)url
                  withParameters:(id)params
               requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
              responseSerializer:(AFHTTPResponseSerializer *)customResponseSerializer
             andCompletionBlock:(void(^)(NSDictionary *response,
                                         NSInteger httpCode,
                                         NSURLSessionTask *task,
                                         NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    return [sharedRequester createAfNetworkingTaskWithUrl:url
                                          httpRequestType:eNSHttpRequestDELETE
                                        requestSerializer:customRequestSerializer
                                       responseSerializer:customResponseSerializer
                                               parameters:params
                                            usingCacheTTL:0
                                       andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, NSURLSessionTask *task, NSError *error, BOOL isCached)
    {
        if (completion) completion(response, httpCode, task, error);
    }];
}

#pragma mark - UPLOAD
+ (NSURLSessionUploadTask *)UPLOADmp:(NSString *)url
                       withParameters:(id)params
                    requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
                   responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer
                         sendingBlock:(void(^)(int64_t totalBytesWritten,
                                               int64_t totalBytesExpectedToWrite,
                                               double percentageUploaded))sending
                  andCompletionBlock:(void(^)(NSDictionary *response,
                                             NSInteger httpCode,
                                             NSURLSessionTask *task,
                                             NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    
    NSURLSessionUploadTask *task = (NSURLSessionUploadTask *)[sharedRequester createAfNetworkingTaskWithUrl:url
                                                                                             httpRequestType:eNSHttpRequestUPLOAD
                                                                                           requestSerializer:customRequestSerializer
                                                                                          responseSerializer:customResponseSerializer
                                                                                                  parameters:params
                                                                                               usingCacheTTL:0
                                                                                          andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, NSURLSessionTask *task, NSError *error, BOOL isCached)
    {
        if (completion) {
            completion(response, httpCode, task, error);
        }
    }];

    [task setTaskDescription:@"UPLOAD"]; // optional tag
    
    return task;
}

#pragma mark - DOWNLOAD
+ (NSURLSessionDownloadTask *)DOWNLOAD:(NSString *)url
                      requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
                     responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer
                       downloadingBlock:(void(^)(int64_t totalBytesRead,
                                                 int64_t totalBytesExpectedToRead,
                                                 double percentageDownloaded))downloading
                    andCompletionBlock:(void(^)(NSDictionary *response,
                                               NSInteger httpCode,
                                               NSURLSessionTask *task,
                                               NSError *error))completion
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = customRequestSerializer;
    manager.responseSerializer = customResponseSerializer;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSURLSessionDownloadTask *downloadTask =
    [manager downloadTaskWithRequest:request
                             progress:^(NSProgress * _Nonnull downloadProgress) {
                                 if (downloading) {
                                     downloading(downloadProgress.completedUnitCount,
                                                 downloadProgress.totalUnitCount,
                                                 (double)downloadProgress.fractionCompleted * 100.0);
                                 }
                             }
                          destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                              // Save to temporary directory
                              return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename]];
                          }
                    completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                        if (completion) {
                            NSDictionary *resp = nil;
                            if (filePath) {
                                resp = @{@"filePath": [filePath path]};
                            }
                            completion(resp,
                                       [(NSHTTPURLResponse *)response statusCode],
                                       downloadTask,
                                       error);
                        }
                    }];
    
    [downloadTask resume];
    return downloadTask;
}

@end
