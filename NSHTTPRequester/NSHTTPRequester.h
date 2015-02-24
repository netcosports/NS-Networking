//
//  NCSRequester.h
//  Cafhub
//
//  Created by Guillaume on 27/06/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"


typedef enum
{
    eNSHttpRequestGET,
    eNSHttpRequestPOST,
    eNSHttpRequestPUT,
    eNSHttpRequestDELETE,
    eNSHttpRequestUPLOAD,
} eNSHttpRequestType;


@interface NSHTTPRequester : NSObject

/**
 *  NSHTTPRequester and NSUSS (Netco Sports Urls Signature System)
 *
 * 1) First way to use the NSUSS is to set a default NS_CLIENT_ID && NS_CLIENT_SECRET
 *    to integrate 2 http header fields into each http request (X-Api-Client-Id & X-Api-Sig).
 *    If these attributes exist, they will be used on every request.
 *    N.B: They are REQUIRED by some specific modules in the Netco Sports Platform.
 *
 * 2) Another way to use the NSUSS for a custom use is to set some specific http header fields
 *    for some URLS described by a Regular Expression. In other words, all request's urls matching
 *    the specified regex will automatically integrate those custom http header fields.
 *    (To do so, please take a look at addCustomHeaders:forUlrMatchingRegEx:)
 *
 *    To conclude, NSHTTPRequester can be used to sign every request specifying the client id and the
 *    client secret only once, or it can be used to sign different requests with multiple credentials.
 */

@property (nonatomic, strong) NSString *NS_CLIENT_ID;
@property (nonatomic, strong) NSString *NS_CLIENT_SECRET;


+(instancetype)sharedRequester;

/**
 *  HTTP Methods [GET, POST, PUT, DELETE] & Custom UPLOAD using multipart POST
 *
 *  @param url            Entire URL (e.g http://ip.jsontest.com)
 *  @param usingCacheTTL  Defines if the requester should return local client-side cache or not, reguarding the ttl.
 *  @param cb_rep         Block callback response when a response is received
 *                        (with the JSON body, the http status code, and boolean describing if the response comes from local cache or not)
 */
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep;

+(void)POST:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep;

+(void)PUT:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep;

+(void)DELETE:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep;

+(void)UPLOAD:(NSString *)url withParameters:(id)params cb_send:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))cb_send cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep;

/**
 *  Custom Headers Management
 *
 *  @param headers  Desired Headers for all Urls matching the regExUrl param
 *  @param regExUrl Regular Expression of Urls
 */
-(void)addCustomHeaders:(NSArray *)headers forUlrMatchingRegEx:(NSString *)regExUrl;

/**
 *  Clean custom headers
 *
 *  @param regExUrl Regular Expression of Urls
 */
-(void) cleanCustomHeadersForUrlMatchingRegEx:(NSString *)regExUrl;

/**
 *  Netco Sports URLs Signature Generation
 */
+(NSArray *)genSignatureHeaders:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
                         forUrl:(NSString *)url
                         params:(NSDictionary *)params
                         isJSON:(BOOL)isJSON;
/**
 *  Local client-side caching mechanism [Get]
 *
 *  @param url     Url for which to save a cached version of the response
 *  @param ttlFile TTL on the file to get the cache from.
 *
 *  @return The cached reponse
 */
+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile;

/**
 *  Local client-side caching mechanism [Remove]
 *
 *  @param url Url for which the cache should be removed.
 */
+(void)removeCacheForUrl:(NSString*)url;

/**
 *  Local client-side caching mechanism [Save]
 *
 *  @param value Response to cache
 *  @param url   Url of the response to cache
 */
+(void)cacheValue:(id)value forUrl:(NSString *)url;

/**
 *  Remove all cached data stored on Disk & RAM.
 *
 */
+(void)clearCache;

/**
 *  Cookies
 *
 *  @param shouldHandleCookies define the cookie comportment in the http request.
 */
-(void)setHTTPShouldHandleCookies:(BOOL)shouldHandleCookies;

/**
 *  Clear cookies
 */
+(void)clearCookies;

@end

