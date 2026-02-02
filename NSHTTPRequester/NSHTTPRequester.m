//
//  NSHTTPRequester
//  NS-Networking
//
//  Created by Guillaume on 27/06/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSHTTPRequester.h"
#import "NSHTTPRequester+Private.h"
#import "NSHTTPRequester+Properties.h"
#import "NSHTTPRequester+Cache.h"
#import "NSHTTPRequester+Serializer.h"
#import "NSHTTPRequester+Private.h"

#import <NSTCategories/NSString+NSString_Tool.h>
#import <NSTCategories/NSObject+NSObject_Xpath.h>
#import <NSTCategories/NSObject+NSObject_File.h>
#import <NSTCategories/NSObject+NSObject_Block.h>
#import <NSTCategories/NSUsefulDefines.h>

#define HEADER_X_API_CLIENT_ID  @"X-Api-Client-Id"
#define HEADER_X_API_SIG        @"X-Api-Sig"

@interface NSHTTPRequester()
{
}
@end

@implementation NSHTTPRequester

+ (instancetype)sharedRequester
{
    static NSHTTPRequester *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NSHTTPRequester alloc]init];
    });
    return _sharedClient;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self.ishandlingCookies = YES;
        self.generalTimeout = 20;
        self.verbose = YES;
    }
    return self;
}

#pragma mark - NS Signature System
+(NSArray *)genSignatureHeaders:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
                         forUrl:(NSString *)url
                         params:(NSDictionary *)params
                         isJSON:(BOOL)isJSON
{
    NSMutableString *signature = [[NSMutableString alloc] init];
    [signature appendString:url];
    if ([url hasSubstring:@"?"])
        [signature appendString:@"&"];
    else
        [signature appendString:@"?"];

    if (params && isJSON)
        [signature appendString:[self signJSONParams:params]];
    else if (params && isJSON == NO)
        [signature appendString:[self signMultiPartParams:params]];

    [signature appendFormat:@"@%@:%@", clientId, [[NSString stringWithFormat:@"netcosports%@", clientSecret] sha1]];
    return @[@{HEADER_X_API_CLIENT_ID: clientId}, @{HEADER_X_API_SIG: [signature sha1]}];
}

+(NSString *)signJSONParams:(NSDictionary *)params
{
    NSError *errorJsonSerialization;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&errorJsonSerialization];
    if (!errorJsonSerialization)
    {
        NSString *stringFromJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return [[NSHTTPRequester cleanJSONString:stringFromJson] sha1];
    }
    else
    {
        [NSException raise:@"Bad JSON sent to signJSONParams" format:[errorJsonSerialization description], nil];
        return @"";
    }
}

+ (NSString *)signMultiPartParams:(NSDictionary *)params
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        return [obj1 compare:obj2];
    }];

    for (NSString *key in sortedKeys)
    {
        if ([[params objectForKey:key] isKindOfClass:[NSString class]])
        {
            NSString *str = [params objectForKey:key];
            str = [NSHTTPRequester encodeString:str];
            [result appendFormat:@"%@=%@&", key, str];
        }
    }
    return result;
}

+(NSString *)cleanJSONString:(NSString *)jsonString
{
    if (!jsonString)
    {
        if ([NSHTTPRequester sharedRequester].verbose)
            DLog(@"Bad json string !");
        return jsonString;
    }
    
    jsonString = [jsonString strReplace:@"\n" by:@""];

    __block NSMutableIndexSet *indexSetOfCharacterToremove = [[NSMutableIndexSet alloc] init];
    __block NSInteger numberOfParsedQuotes = 0;
    
    [jsonString enumerateSubstringsInRange:NSMakeRange(0, [jsonString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         if ([substring isEqualToString:@"\""])
             numberOfParsedQuotes += 1;
         
         if ([substring isEqualToString:@" "] && numberOfParsedQuotes % 2 == 0)
             [indexSetOfCharacterToremove addIndex:substringRange.location];
     }];
    
    __block NSInteger numberOfReplacedCharacters = 0;
    __block NSMutableString *mutableString = [jsonString mutableCopy];
    [indexSetOfCharacterToremove enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        [mutableString replaceCharactersInRange:NSMakeRange(idx - numberOfReplacedCharacters, 1) withString:@""];
        numberOfReplacedCharacters += 1;
    }];
    return [mutableString ToUnMutable];
}

+ (NSString *)encodeString:(NSString *)str
{
    if (![str isKindOfClass:[NSString class]])
        return str;
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];
    str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    str = [str stringByReplacingOccurrencesOfString:@"(" withString:@"%28"];
    str = [str stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    str = [str stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    str = [str stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    str = [str stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    str = [str stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"%5B"];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@"%5D"];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@"%09"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"%0A"];
    return str;
}

#pragma mark - HTTP Methods
#pragma mark GET
+(NSURLSessionDataTask *)GET:(NSString *)url
             usingCacheTTL:(NSInteger)cacheTTL
         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
        responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
       andCompletionBlock:(void(^)(NSDictionary *response,
                                  NSInteger httpCode,
                                  NSURLSessionTask *task,
                                  NSError *error,
                                  BOOL isCached))completion
{
    return (NSURLSessionDataTask *)[[NSHTTPRequester sharedRequester]
        createAfNetworkingTaskWithUrl:url
                      httpRequestType:eNSHttpRequestGET
                    requestSerializer:requestSerializer
                   responseSerializer:responseSerializer
                           parameters:nil
                        usingCacheTTL:cacheTTL
                   andCompletionBlock:completion];
}

#pragma mark POST
+(NSURLSessionDataTask *)POST:(NSString *)url
              withParameters:(id)params
        andCompletionBlock:(void(^)(NSDictionary *response,
                                   NSInteger httpCode,
                                   NSURLSessionTask *task,
                                   NSError *error))completion
{
    return [NSHTTPRequester POST:url
                 withParameters:params
              requestSerializer:[AFJSONRequestSerializer serializer]
             responseSerializer:[AFJSONResponseSerializer serializer]
            andCompletionBlock:completion];
}

#pragma mark PUT
+(NSURLSessionDataTask *)PUT:(NSString *)url
              withParameters:(id)params
          andCompletionBlock:(void(^)(NSDictionary *response,
                                       NSInteger httpCode,
                                       NSURLSessionTask *task,
                                       NSError *error))completion
{
    return [NSHTTPRequester createTaskWithUrl:url
                              httpRequestType:eNSHttpRequestPUT
                                parameters:params
                          requestSerializer:[AFJSONRequestSerializer serializer]
                         responseSerializer:[AFJSONResponseSerializer serializer]
                        andCompletionBlock:completion];
}

#pragma mark DELETE
+(NSURLSessionDataTask *)DELETE:(NSString *)url
                 withParameters:(id)params
             andCompletionBlock:(void(^)(NSDictionary *response,
                                        NSInteger httpCode,
                                        NSURLSessionTask *task,
                                        NSError *error))completion
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    NSURLSessionDataTask *task = [manager DELETE:url
                                     parameters:params
                                        headers:nil
                                        success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, ((NSHTTPURLResponse *)task.response).statusCode, task, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, ((NSHTTPURLResponse *)task.response).statusCode, task, error);
        }
    }];

    return task;
}

#pragma mark UPLOAD
+(NSURLSessionUploadTask *)UPLOADmp:(NSString *)url
                      withParameters:(id)params
                         sendingBlock:(void(^)(int64_t bytesSent,
                                               int64_t totalBytes,
                                               double percentageUploaded))sending
                  andCompletionBlock:(void(^)(NSDictionary *response,
                                             NSInteger httpCode,
                                             NSURLSessionTask *task,
                                             NSError *error))completion
{
    return [NSHTTPRequester UPLOADmp:url
                       withParameters:params
                    requestSerializer:[AFHTTPRequestSerializer serializer]
                   responseSerializer:[AFJSONResponseSerializer serializer]
                         sendingBlock:sending
                  andCompletionBlock:completion];
}

#pragma mark DOWNLOAD
+(NSURLSessionDownloadTask *)DOWNLOAD:(NSString *)url
                     downloadingBlock:(void(^)(int64_t bytesDownloaded,
                                               int64_t totalBytes,
                                               double percentageDownloaded))downloading
                  andCompletionBlock:(void(^)(NSDictionary *response,
                                             NSInteger httpCode,
                                             NSURLSessionTask *task,
                                             NSError *error))completion
{
    return [NSHTTPRequester DOWNLOAD:url
                    requestSerializer:[AFHTTPRequestSerializer serializer]
                   responseSerializer:[AFImageResponseSerializer serializer]
                   downloadingBlock:downloading
                  andCompletionBlock:completion];
}


#pragma mark - Private Creation of Operation
-(NSURLSessionTask *)createAfNetworkingTaskWithUrl:(NSString *)url
                                  httpRequestType:(eNSHttpRequestType)httpRequestType
                                requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                               responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
                                       parameters:(id)parameters
                                    usingCacheTTL:(NSInteger)cacheTTL
                               andCompletionBlock:(void(^)(NSDictionary *response,
                                                           NSInteger httpCode,
                                                           NSURLSessionTask *task,
                                                           NSError *error,
                                                           BOOL isCached))completion
{
    url = [url stringByRemovingPercentEncoding];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    if (self.verbose)
        [self printUrl:url forRequestType:httpRequestType];

    // ✅ CLIENT CACHE (GET only)
    if (cacheTTL > 0 && httpRequestType == eNSHttpRequestGET)
    {
        [NSObject backgroundQueueBlock:^{
            NSDictionary *localCachedResponse =
                [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];

            [NSObject mainQueueBlock:^{
                if (completion && localCachedResponse)
                    completion(localCachedResponse, 0, nil, nil, YES);
            }];
        }];
    }

    // ✅ Session Manager (AFNetworking 4.x)
    AFHTTPSessionManager *manager =
        [[AFHTTPSessionManager alloc] initWithBaseURL:nil];

    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;

    // ✅ Cookies
    manager.requestSerializer.HTTPShouldHandleCookies = self.ishandlingCookies;

    // ✅ Cache Policy
    if (cacheTTL > 0)
        manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    else
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

    // ✅ Accept extra content-types
    NSMutableSet *acceptableTypes =
        [manager.responseSerializer.acceptableContentTypes mutableCopy];

    [acceptableTypes addObject:@"text/html"];
    [acceptableTypes addObject:@"text/plain"];
    [acceptableTypes addObject:@"application/ld+json"];

    manager.responseSerializer.acceptableContentTypes = acceptableTypes;

    // ✅ Signed Headers
    if (self.NS_CLIENT_ID.length > 0 && self.NS_CLIENT_SECRET.length > 0)
    {
        NSString *urlForSig = url;
        BOOL isJSONForSig = [requestSerializer isKindOfClass:[AFJSONRequestSerializer class]];

        [[NSHTTPRequester genSignatureHeaders:self.NS_CLIENT_ID
                                 clientSecret:self.NS_CLIENT_SECRET
                                       forUrl:urlForSig
                                       params:parameters
                                       isJSON:isJSONForSig]
         enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop)
         {
            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
            {
                [manager.requestSerializer setValue:value forHTTPHeaderField:key];
            }];
         }];
    }

    // ✅ Timeout
    manager.requestSerializer.timeoutInterval =
        [self getCustomTimeoutsForUrl:url];

    // ✅ Custom Headers
    NSArray *customHeaders = [self getCustomHeadersForUrl:url];
    for (NSDictionary *dict in customHeaders)
    {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }

    // ✅ Completion helpers
    void (^successBlock)(NSURLSessionTask *, id) =
    ^(NSURLSessionTask *task, id responseObject)
    {
        if (httpRequestType == eNSHttpRequestGET)
            [NSHTTPRequester cacheValue:responseObject forUrl:url];

        if (completion)
            completion(responseObject,
                       ((NSHTTPURLResponse *)task.response).statusCode,
                       task,
                       nil,
                       NO);
    };

    void (^failureBlock)(NSURLSessionTask *, NSError *) =
    ^(NSURLSessionTask *task, NSError *error)
    {
        if (completion)
            completion(nil,
                       ((NSHTTPURLResponse *)task.response).statusCode,
                       task,
                       error,
                       NO);
    };

    // ✅ Create Task
    NSURLSessionTask *task = nil;

    switch (httpRequestType)
    {
        case eNSHttpRequestGET:
            task = [manager GET:url
                     parameters:nil
                        headers:nil
                       progress:nil
                        success:successBlock
                        failure:failureBlock];
            break;

        case eNSHttpRequestPOST:
            task = [manager POST:url
                      parameters:parameters
                         headers:nil
                        progress:nil
                         success:successBlock
                         failure:failureBlock];
            break;

        case eNSHttpRequestPUT:
            task = [manager PUT:url
                     parameters:parameters
                        headers:nil
                        success:successBlock
                        failure:failureBlock];
            break;

        case eNSHttpRequestDELETE:
            task = [manager DELETE:url
                        parameters:parameters
                           headers:nil
                           success:successBlock
                           failure:failureBlock];
            break;

        case eNSHttpRequestUPLOAD:
        {
            task = [manager POST:url
                      parameters:parameters
                         headers:nil
       constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
            {
                UIImage *imageToUpload = [parameters getXpathNil:@"image"
                                                           type:[UIImage class]];

                if (imageToUpload)
                {
                    NSData *data = UIImageJPEGRepresentation(imageToUpload, 0.5);
                    [formData appendPartWithFileData:data
                                                name:@"file"
                                            fileName:@"upload.jpg"
                                            mimeType:@"image/jpeg"];
                }
            }
                        progress:nil
                         success:successBlock
                         failure:failureBlock];
            break;
        }

        default:
            break;
    }

    return task;
}

-(void)printUrl:(NSString *)url forRequestType:(eNSHttpRequestType)requestType
{
    NSString *httpMethod = @"";
    
    if (requestType == eNSHttpRequestGET)
        httpMethod = @"GET";
    else if (requestType == eNSHttpRequestPOST)
        httpMethod = @"POST";
    else if (requestType == eNSHttpRequestPUT)
        httpMethod = @"PUT";
    else if (requestType == eNSHttpRequestDELETE)
        httpMethod = @"DELETE";
    else if (requestType == eNSHttpRequestUPLOAD)
        httpMethod = @"UPLOAD (multipart POST)";
    else if (requestType == eNSHttpRequestDOWNLOAD)
        httpMethod = @"DOWNLOAD";
    else
        httpMethod = @"";
    
   NSLog(@"[%@] %@ => %@", NSStringFromClass([self class]), httpMethod, url);
}

#pragma mark - Cookies

-(void)setHTTPShouldHandleCookies:(BOOL)shouldHandleCookies
{
    self.ishandlingCookies = shouldHandleCookies;
}

+(void)clearCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    if (storage && [[storage cookies] count])
    {
        for (NSHTTPCookie *cookie in [storage cookies])
            [storage deleteCookie:cookie];
    }
}

+ (NSURLSessionDataTask *)GET:(NSString *)url
                 usingCacheTTL:(NSInteger)cacheTTL
            andCompletionBlock:(void(^)(NSDictionary *response,
                                        NSInteger httpCode,
                                        NSURLSessionTask *task,
                                        NSError *error,
                                        BOOL isCached))completion
{
    return [NSHTTPRequester GET:url
                   usingCacheTTL:cacheTTL
                requestSerializer:[AFJSONRequestSerializer serializer]
               responseSerializer:[AFJSONResponseSerializer serializer]
              andCompletionBlock:completion];
}

+ (NSURLSessionDataTask *)createTaskWithUrl:(NSString *)url
                           httpRequestType:(eNSHttpRequestType)httpRequestType
                                parameters:(id)parameters
                          requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                         responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
                        andCompletionBlock:(void(^)(NSDictionary *response,
                                                   NSInteger httpCode,
                                                   NSURLSessionTask *task,
                                                   NSError *error))completion
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;

    NSURLSessionDataTask *task = [manager PUT:url
                                   parameters:parameters
                                      headers:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion)
            completion(responseObject, ((NSHTTPURLResponse *)task.response).statusCode, task, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion)
            completion(nil, ((NSHTTPURLResponse *)task.response).statusCode, task, error);
    }];

    return task;
}

@end
