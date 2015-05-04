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
 *  These methods are used by default ones (@interface NSHTTPRequester).
 *  They are meant to override default request & response serializers depending on the type of HTTP servers you are hitting.
 *
 *  @param url                  Entire URL (e.g http://ip.jsontest.com)
 *  @param usingCacheTTL        Defines if the requester should return local client-side cache or not, reguarding the ttl.
 *  @param requestSerializer    Custom request serializer implementing protocol `AFURLRequestSerialization'
 *  @param responseSerializer   Custom response serializer implementing protocol `AFURLResponseSerialization'
 *  @param cb_rep               Block callback response when a response is received
 *                              (with the JSON body, the http status code, and boolean describing if the response comes from local cache or not)
 */

+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion;

+(void)POST:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion;

+(void)PUT:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion;

+(void)DELETE:(NSString *)url withParameters:(id)params requestSerializer:(id<AFURLRequestSerialization>)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion;

+(void)UPLOADmp:(NSString *)url withParameters:(id)params requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer sendingBlock:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded))sending andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion;

+(void)DOWNLOAD:(NSString *)url requestSerializer:(AFHTTPRequestSerializer *)customRequestSerializer responseSerializer:(id<AFURLResponseSerialization>)customResponseSerializer downloadingBlock:(void(^)(long long totalBytesRead, long long totalBytesExpectedToRead, double percentageDownloaded))downloading andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion;

@end
