//
//  NSHTTPRequester
//  NS-Networking
//
//  Created by Guillaume on 27/06/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

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
 *    (To do so, please take a look at addCustomHeaders:forUlrMatchingRegEx: in the Category "Properties")
 *
 *    To conclude, NSHTTPRequester can be used to sign every request specifying the client id and the
 *    client secret only once, or it can be used to sign different requests with multiple credentials.
 */

@property (nonatomic, assign) BOOL ishandlingCookies;

@property (nonatomic, strong) NSString *NS_CLIENT_ID;
@property (nonatomic, strong) NSString *NS_CLIENT_SECRET;

@property (nonatomic, assign) NSTimeInterval generalTimeout; // Default is set to 20sec
@property (nonatomic, assign) BOOL verbose; // Default is YES

/**
 *  Singleton pattern
 *
 *  @return NSHTTPRequester object
 */
+(instancetype)sharedRequester;

/**
 *  HTTP Methods [GET, POST, PUT, DELETE] & Custom UPLOAD using multipart POST
 *  Default request serializer: AFJSONRequestSerializer
 *  Default response serializer: AFJSONResponseSerializer
 *
 *  NB: Since UPLOAD is using the multipart post, the default request serializer for it is AFHTTPRequestSerializer. Params for uploads are {`image', `mimetype', `filename'}
 *  NB2: Same methods with custom request && response serializers exist (cf. NSHTTPRequester+Serializer)
 *
 *  @param url            Entire URL (e.g http://ip.jsontest.com)
 *  @param cacheTTL       Defines if the requester should return local client-side cache or not, reguarding the ttl.
 *  @param completion     Block callback response when a response is received
 *                        (with the JSON body, the http status code, and boolean describing if the response comes from local cache or not)
 */
+(NSURLSessionDataTask *)GET:(NSString *)url
             usingCacheTTL:(NSInteger)cacheTTL
        andCompletionBlock:(void(^)(NSDictionary *response,
                                   NSInteger httpCode,
                                   NSURLSessionDataTask *task,
                                   NSError *error,
                                   BOOL isCached))completion;

+(NSURLSessionDataTask *)POST:(NSString *)url
              withParameters:(id)params
        andCompletionBlock:(void(^)(NSDictionary *response,
                                   NSInteger httpCode,
                                   NSURLSessionDataTask *task,
                                   NSError *error))completion;

+(NSURLSessionDataTask *)PUT:(NSString *)url
              withParameters:(id)params
        andCompletionBlock:(void(^)(NSDictionary *response,
                                   NSInteger httpCode,
                                   NSURLSessionDataTask *task,
                                   NSError *error))completion;

+(NSURLSessionDataTask *)DELETE:(NSString *)url
                 withParameters:(id)params
           andCompletionBlock:(void(^)(NSDictionary *response,
                                      NSInteger httpCode,
                                      NSURLSessionDataTask *task,
                                      NSError *error))completion;

+(NSURLSessionUploadTask *)UPLOADmp:(NSString *)url
                    withParameters:(id)params
                      sendingBlock:(void(^)(int64_t bytesSent,
                                           int64_t totalBytes,
                                           double percentageUploaded))sending
              andCompletionBlock:(void(^)(NSDictionary *response,
                                         NSInteger httpCode,
                                         NSURLSessionUploadTask *task,
                                         NSError *error))completion;

+(NSURLSessionDownloadTask *)DOWNLOAD:(NSString *)url
                    downloadingBlock:(void(^)(int64_t bytesWritten,
                                             int64_t totalBytes,
                                             double percentageDownloaded))downloading
                andCompletionBlock:(void(^)(NSDictionary *response,
                                           NSInteger httpCode,
                                           NSURLSessionDownloadTask *task,
                                           NSError *error))completion;

/**
 *  Netco Sports URLs Signature Generation
 */
+(NSArray *)genSignatureHeaders:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
                         forUrl:(NSString *)url
                         params:(NSDictionary *)params
                         isJSON:(BOOL)isJSON;

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

