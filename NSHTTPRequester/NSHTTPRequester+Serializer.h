//
//  NSHTTPRequester+Serializer.h
//  FoxSports
//
//  Created by Guillaume on 31/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester.h"

@interface NSHTTPRequester (Serializer)

/**
 *  HTTP Methods [GET, POST, PUT, DELETE] & Custom UPLOAD using multipart POST
 *  These methods are used by default ones (interface of NSHTTPRequester).
 *  They are meant to override default request & response serializers depending on the type of HTTP servers you are hitting.
 *
 *  @param url                  Entire URL (e.g http://ip.jsontest.com)
 *  @param cacheTTL        Defines if the requester should return local client-side cache or not, reguarding the ttl.
 *  @param customRequestSerializer    Custom request serializer implementing protocol `AFURLRequestSerialization'
 *  @param customResponseSerializer   Custom response serializer implementing protocol `AFURLResponseSerialization'
 *  @param completion               Block callback response when a response is received
 *                              (with the JSON body, the http status code, and boolean describing if the response comes from local cache or not)
 */

#pragma mark - Data Tasks (GET, POST, PUT, DELETE)

+ (NSURLSessionDataTask *)GET:(NSString *)url
                  usingCacheTTL:(NSInteger)cacheTTL
               requestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)customRequestSerializer
              responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
             andCompletionBlock:(void(^)(NSDictionary *response,
                                         NSInteger httpCode,
                                         NSURLSessionTask *task,
                                         NSError *error,
                                         BOOL isCached))completion;

+ (NSURLSessionDataTask *)POST:(NSString *)url
                withParameters:(id)params
             requestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)customRequestSerializer
            responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
           andCompletionBlock:(void(^)(NSDictionary *response,
                                       NSInteger httpCode,
                                       NSURLSessionTask *task,
                                       NSError *error))completion;

+ (NSURLSessionDataTask *)PUT:(NSString *)url
               withParameters:(id)params
            requestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)customRequestSerializer
           responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
          andCompletionBlock:(void(^)(NSDictionary *response,
                                      NSInteger httpCode,
                                      NSURLSessionTask *task,
                                      NSError *error))completion;

+ (NSURLSessionDataTask *)DELETE:(NSString *)url
                  withParameters:(id)params
               requestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)customRequestSerializer
              responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
             andCompletionBlock:(void(^)(NSDictionary *response,
                                         NSInteger httpCode,
                                         NSURLSessionTask *task,
                                         NSError *error))completion;

#pragma mark - Upload / Download Tasks

+ (NSURLSessionUploadTask *)UPLOADmp:(NSString *)url
                       withParameters:(id)params
                    requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
                   responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
                         sendingBlock:(void(^)(int64_t totalBytesWritten,
                                               int64_t totalBytesExpectedToWrite,
                                               double percentageUploaded))sending
                  andCompletionBlock:(void(^)(NSDictionary *response,
                                             NSInteger httpCode,
                                             NSURLSessionTask *task,
                                             NSError *error))completion;

+ (NSURLSessionDownloadTask *)DOWNLOAD:(NSString *)url
                      requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer
                     responseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)customResponseSerializer
                       downloadingBlock:(void(^)(int64_t totalBytesRead,
                                                 int64_t totalBytesExpectedToRead,
                                                 double percentageDownloaded))downloading
                    andCompletionBlock:(void(^)(NSDictionary *response,
                                               NSInteger httpCode,
                                               NSURLSessionTask *task,
                                               NSError *error))completion;
@end
