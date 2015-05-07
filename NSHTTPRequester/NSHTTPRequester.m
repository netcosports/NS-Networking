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

#import "NSObject+NSObject_Xpath.h"
#import "NSString+NSString_Tool.h"
#import "NSObject+NSObject_File.h"
#import "NSObject+NSObject_Tool.h"

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
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (params)
    {
        [parameters addEntriesFromDictionary:params];
    }
    
    NSString *urlForSig = url;
//    if (httpRequestType == eNSHttpRequestGET)
//    {
        NSArray *urlTab = [url componentsSeparatedByString:@"?"];
        if (urlTab && [urlTab count] == 2)
        {
            urlForSig = urlTab[0];
            
            NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
            NSArray *paramTab = [urlTab[1] componentsSeparatedByString:@"&"];
            for (NSString *keyValue in paramTab)
            {
                NSArray *keyValueTab = [keyValue componentsSeparatedByString:@"="];
                if (keyValueTab && [keyValueTab count] == 2)
                {
                    [newParams setObject:keyValueTab[1] forKey:keyValueTab[0]];
                }
                else if (keyValueTab && [keyValueTab count] == 1)
                {
                    [newParams setObject:@"" forKey:keyValueTab[0]];
                }
            }
            [parameters addEntriesFromDictionary:newParams];
        }
//    }

    NSMutableString *signature = [[NSMutableString alloc] init];
    [signature appendString:urlForSig];
    if ([urlForSig hasSubstring:@"?"])
        [signature appendString:@"&"];
    else
        [signature appendString:@"?"];

    if (parameters && isJSON)
        [signature appendString:[self signJSONParams:parameters]];
    else if (parameters && isJSON == NO)
        [signature appendString:[self createStringFromParams:parameters]];

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

// Params can come from query params or multi-part params.
+ (NSString *)createStringFromParams:(NSDictionary *)params
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
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion
{
    [NSHTTPRequester GET:url usingCacheTTL:cacheTTL requestSerializer:[AFHTTPRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] andCompletionBlock:completion];
}

#pragma mark POST
+(void)POST:(NSString *)url withParameters:(id)params andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    [NSHTTPRequester POST:url withParameters:params requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] andCompletionBlock:completion];
}

#pragma mark PUT
+(void)PUT:(NSString *)url withParameters:(id)params andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    [NSHTTPRequester PUT:url withParameters:params requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] andCompletionBlock:completion];
}

#pragma mark DELETE
+(void)DELETE:(NSString *)url withParameters:(id)params andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    [NSHTTPRequester DELETE:url withParameters:params requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] andCompletionBlock:completion];
}

#pragma mark UPLOAD
+(void)UPLOADmp:(NSString *)url withParameters:(id)params sendingBlock:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded))sending andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    [NSHTTPRequester UPLOADmp:url withParameters:params requestSerializer:[AFHTTPRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] sendingBlock:sending andCompletionBlock:completion];
}

#pragma mark DOWNLOAD
+(void)DOWNLOAD:(NSString *)url downloadingBlock:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded))downloading andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error))completion
{
    [NSHTTPRequester DOWNLOAD:url requestSerializer:[AFHTTPRequestSerializer serializer] responseSerializer:[AFImageResponseSerializer serializer] downloadingBlock:downloading andCompletionBlock:completion];
}

#pragma mark - Private Creation of Operation
-(AFHTTPRequestOperation *)createAfNetworkingOperationWithUrl:(NSString *)url
                          httpRequestType:(eNSHttpRequestType)httpRequestType
                              requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                              responseSerializer:(AFHTTPResponseSerializer *)responseSerializer
                               parameters:(id)parameters
                               usingCacheTTL:(NSInteger)cacheTTL
                              andCompletionBlock:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))completion
{
    [self printUrl:url forRequestType:httpRequestType];
    
    // CLIENT CACHE
    if (cacheTTL > 0 && httpRequestType == eNSHttpRequestGET)
    {
        [NSObject backgroundQueueBlock:^{
            NSDictionary *localCachedResponse = [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];
            [NSObject mainQueueBlock:^{
                if (completion && localCachedResponse)
                    completion(localCachedResponse, 0, nil, nil, YES);
            }];
        }];
	}

    // SERIALIZER TYPE
    __block AFHTTPRequestOperationManager *afNetworkingManager = [AFHTTPRequestOperationManager manager];
    if (requestSerializer && [requestSerializer conformsToProtocol:@protocol(AFURLRequestSerialization)])
    {
        [afNetworkingManager setRequestSerializer:requestSerializer];
    }
    else
    {
        if (self.verbose)
            DLog(@"Bad request serializer");
    }
    if (responseSerializer && [responseSerializer conformsToProtocol:@protocol(AFURLResponseSerialization)])
    {
        [afNetworkingManager setResponseSerializer:responseSerializer];
    }
    else
    {
        if (self.verbose)
            DLog(@"Bad response serializer");
    }
    
    // COOKIES
    [afNetworkingManager.requestSerializer setHTTPShouldHandleCookies:self.ishandlingCookies];
    
    // SERVER CACHE POLICY
    if (cacheTTL > 0)
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    else
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];

    // FORCE RESPONSE SERIALIZER TO ACCEPT CONTENT-TYPE (text/html & text/plain) as well.
    // (thefanclub.com send response with only one content-type : text/html).
    // json mocks usually do not use application/json but text/plain instead.
    NSMutableSet *setOfAcceptablesContentTypesInResonse = [afNetworkingManager.responseSerializer.acceptableContentTypes mutableCopy];
    [setOfAcceptablesContentTypesInResonse addObject:@"text/html"];
    [setOfAcceptablesContentTypesInResonse addObject:@"text/plain"];
    [afNetworkingManager.responseSerializer setAcceptableContentTypes:setOfAcceptablesContentTypesInResonse];

    // NETCO SPORTS SIGNED HTTP HEADER FIELDS
    if (self.NS_CLIENT_ID && self.NS_CLIENT_SECRET && [self.NS_CLIENT_ID length] > 0 && [self.NS_CLIENT_SECRET length] > 0)
    {
        [[NSHTTPRequester genSignatureHeaders:self.NS_CLIENT_ID clientSecret:self.NS_CLIENT_SECRET forUrl:url params:parameters isJSON:[requestSerializer isMemberOfClass:[AFJSONRequestSerializer class]]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            if (obj && [obj isKindOfClass:[NSDictionary class]])
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                {
                    [afNetworkingManager.requestSerializer setValue:obj forHTTPHeaderField:key];
                }];
            }
        }];
    }

    // CUSTOM TIMEOUT
    CGFloat timeoutForUrl = [self getCustomTimeoutsForUrl:url];
    [afNetworkingManager.requestSerializer setTimeoutInterval:timeoutForUrl];
    
    // CUSTOM HTTP HEADER FIELDS
    NSArray *customHttpHeaders = [self getCustomHeadersForUrl:url];
    if (customHttpHeaders && [customHttpHeaders count] > 0)
    {
        [customHttpHeaders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  [afNetworkingManager.requestSerializer setValue:obj forHTTPHeaderField:key];
              }];
        }];
    }

    // CALLBACKS BLOCKS
    void (^successCompletionBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (httpRequestType == eNSHttpRequestGET)
            [NSHTTPRequester cacheValue:responseObject forUrl:url]; // Store a Cached version of the response every time it's called.
        
        if (completion)
        {
//            [NSObject mainQueueBlock:^{
                completion(responseObject, [operation.response statusCode], operation, nil, NO);
//            }];
        }
    };
    void (^failureCompletionBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (completion)
        {
//            [NSObject mainQueueBlock:^{
                completion(operation.responseObject, [operation.response statusCode], operation, error, NO);
//            }];
        }
    };

    // OPERATIONMANAGER LAUNCHING OPERATION
    AFHTTPRequestOperation *afNetworkingOperation = nil;
    switch (httpRequestType)
    {
        case eNSHttpRequestGET:
            afNetworkingOperation = [afNetworkingManager GET:url parameters:nil success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNSHttpRequestPOST:
            afNetworkingOperation = [afNetworkingManager POST:url parameters:parameters success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNSHttpRequestPUT:
            afNetworkingOperation = [afNetworkingManager PUT:url parameters:parameters success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNSHttpRequestDELETE:
            afNetworkingOperation = [afNetworkingManager DELETE:url parameters:parameters success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNSHttpRequestUPLOAD:
        {
            afNetworkingOperation = [afNetworkingManager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
            {
                UIImage *imageToUpload = [parameters getXpathNil:@"image" type:[UIImage class]];
                NSString *mimeType = [parameters getXpathNilString:@"mimetype"];
                NSString *fileName = [parameters getXpathNilString:@"filename"];

                if (imageToUpload)
                {
                    NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 0.5);
                    NSString *impliedFileName = [imageToUpload accessibilityIdentifier];
                    if (!impliedFileName || [impliedFileName length] == 0)
                    {
                        if (fileName)
                            impliedFileName = fileName;
                        else
                            impliedFileName = @"file";
                    }
                    [formData appendPartWithFileData:imageData name:@"file" fileName:impliedFileName mimeType:mimeType];
                }
            } success:successCompletionBlock failure:failureCompletionBlock];
            break;
        }
        case eNSHttpRequestDOWNLOAD:
        {
            afNetworkingOperation = [afNetworkingManager HTTPRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] success:successCompletionBlock failure:failureCompletionBlock];
            [afNetworkingOperation start];
            break;
        }
        default:
            afNetworkingOperation = [afNetworkingManager GET:url parameters:nil success:successCompletionBlock failure:failureCompletionBlock];
            break;
    }
    
    // CACHE BLOCK
    if (afNetworkingOperation)
    {
        // QUEUE MANAGEMENT
        afNetworkingOperation.completionQueue = [NSObject isMainQueue] ? nil : [NSObject backgroundQueueBlock:nil];
        
        // CACHE BLOCK
        [afNetworkingOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse)
         {
             // Block Called only if : Cache-Control is set into http response header
             if (cacheTTL > 0)
                 return cachedResponse;
             else
                 return nil;
         }];

        // REDIRECTION BLOCK
        [afNetworkingOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse)
        {
            return request;
        }];

    }
    return afNetworkingOperation;
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

@end
