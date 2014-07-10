//
//  NCSRequester.m
//  Cafhub
//
//  Created by Guillaume on 27/06/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSDictionary+NSDictionary_File.h"
#import "NSObject+NSObject_Xpath.h"
#import "NSString+NSString_Tool.h"
#import "NSObject+NSObject_File.h"
#import "NSObject+NSObject_Tool.h"
#import "NSHTTPRequester.h"

#define HEADER_X_API_CLIENT_ID  @"X-Api-Client-Id"
#define HEADER_X_API_SIG        @"X-Api-Sig"

typedef enum
{
    eNCSHttpRequestGET,
    eNCSHttpRequestPOST,
    eNCSHttpRequestPUT,
    eNCSHttpRequestDELETE,
} eNCSHttpRequestType;

@interface NSHTTPRequester()
{
    NSMutableArray *customHeadersForUrl;
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
    { }
    return self;
}

#pragma mark - API signature calculation
+(NSArray *)genSignatureHeaders:(NSString *)clientId
                   clientSecret:(NSString *)clientSecret
                         forUrl:(NSString *)url
                         params:(NSDictionary *)params
{
    NSMutableString *signature = [[NSMutableString alloc] init];
    [signature appendString:url];
    if ([url hasSubstring:@"?"])
        [signature appendString:@"&"];
    else
        [signature appendString:@"?"];
    
    if (params)
        [signature appendString:[self generateParamsStringFromDictionary:params]];

    [signature appendFormat:@"@%@:%@", clientId, [[NSString stringWithFormat:@"netcosports%@", clientSecret] sha1]];
    return @[@{HEADER_X_API_CLIENT_ID: clientId}, @{HEADER_X_API_SIG: [signature sha1]}];
}

+ (NSString *)generateParamsStringFromDictionary:(NSDictionary *)params
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
    // Already done by stringByAddingPercentEscapesUsingEncoding ?
    //    str = [str stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    //    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //    str = [str stringByReplacingOccurrencesOfString:@"é" withString:@"%C3%A9"];
    //    str = [str stringByReplacingOccurrencesOfString:@"à" withString:@"%C3%A0"];
    //    str = [str stringByReplacingOccurrencesOfString:@"ç" withString:@"%C3%A7"];
    //    str = [str stringByReplacingOccurrencesOfString:@"è" withString:@"%C3%A8"];
    //    str = [str stringByReplacingOccurrencesOfString:@"ù" withString:@"%C3%B9"];
    //    str = [str stringByReplacingOccurrencesOfString:@"ô" withString:@"%C3%B4"];
    
    return str;
}


#pragma mark - HTTP Methods
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNCSHttpRequestGET jsonRequest:YES parameters:nil usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)POST:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNCSHttpRequestPOST jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)PUT:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNCSHttpRequestPUT jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)DELETE:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNCSHttpRequestDELETE jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)UPLOAD:(NSString *)url withParameters:(id)params cb_send:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))cb_send cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNCSHttpRequestDELETE jsonRequest:NO parameters:params usingCacheTTL:0 andCallBack:cb_rep];

    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
        if (cb_send)
            cb_send(totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

-(AFHTTPRequestOperation *)createAfNetworkingOperationWithUrl:(NSString *)url
                          httpRequestType:(eNCSHttpRequestType)httpRequestType
                              jsonRequest:(BOOL)requestShouldBeJson
                               parameters:(id)parameters
                               usingCacheTTL:(NSInteger)cacheTTL
                              andCallBack:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSLog(@"[NCSRequester] URL => %@", url);
    
    // CLIENT CACHE
    if (cacheTTL > 0)
    {
        NSDictionary *localCachedResponse = [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];
        [NSObject mainThreadBlock:^{
            if (cb_rep && localCachedResponse)
                cb_rep(localCachedResponse, 0, YES);
        }];
	}

    // SERIALIZER TYPE
    __block AFHTTPRequestOperationManager *afNetworkingManager = [AFHTTPRequestOperationManager manager];
    if (requestShouldBeJson)
        [afNetworkingManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    else
        [afNetworkingManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    [afNetworkingManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    // SERVER CACHE POLICY
    if (cacheTTL > 0)
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    else
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    // NETCO SPORTS SIGNED HTTP HEADER FIELDS
    if (self.NS_CLIENT_ID && self.NS_CLIENT_SECRET && [self.NS_CLIENT_ID length] > 0 && [self.NS_CLIENT_SECRET length] > 0)
    {
        [[NSHTTPRequester genSignatureHeaders:self.NS_CLIENT_ID clientSecret:self.NS_CLIENT_SECRET forUrl:url params:parameters] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
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

    // CUSTOM HTTP HEADER FIELDS
    NSArray *customHttpHeaders = [self getCustomHeadersForUrl:url];
    if (customHttpHeaders && [customHttpHeaders count] > 0)
    {
        [customHttpHeaders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            {
                [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                {
                    [afNetworkingManager.requestSerializer setValue:obj forHTTPHeaderField:key];
                }];
            }
        }];
    }
    
    // CALLBACKS BLOCKS
    void (^successCompletionBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject){
        if (cb_rep)
        {
            [NSHTTPRequester cacheValue:responseObject forUrl:url]; // Store a Cached version of the response every time it's called.

            [NSObject mainThreadBlock:^{
                cb_rep(responseObject, [operation.response statusCode],NO);
            }];
        }
    };
    void (^failureCompletionBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error){
        if (cb_rep)
        {
            [NSObject mainThreadBlock:^{
                cb_rep(operation.responseObject, [operation.response statusCode], NO);
            }];
        }
    };
    AFHTTPRequestOperation *afNetworkingOperation = nil;
    
    switch (httpRequestType)
    {
        case eNCSHttpRequestGET:
            afNetworkingOperation = [afNetworkingManager GET:url parameters:nil success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNCSHttpRequestPOST:
            afNetworkingOperation = [afNetworkingManager POST:url parameters:parameters success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNCSHttpRequestPUT:
            afNetworkingOperation = [afNetworkingManager PUT:url parameters:parameters success:successCompletionBlock failure:failureCompletionBlock];
            break;

        case eNCSHttpRequestDELETE:
            afNetworkingOperation = [afNetworkingManager DELETE:url parameters:nil success:successCompletionBlock failure:failureCompletionBlock];
            break;

        default:
            afNetworkingOperation = [afNetworkingManager GET:url parameters:nil success:successCompletionBlock failure:failureCompletionBlock];
            break;
    }

    if (afNetworkingOperation)
    {
        [afNetworkingOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse)
         {
             // Block Called only if : Cache-Control is set into http response header
             if (cacheTTL > 0)
                 return cachedResponse;
             else
                 return nil;
         }];
    }
    return afNetworkingOperation;
}

#pragma mark - Caching

+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile
{
    NSDictionary *cachedResponse = [NSDictionary getDataFromFileCache:[url md5] temps:ttlFile del:NO];
    NSLog(@"[NCSRequester] Cache returned => %@", url);
    return cachedResponse;
}

+(void)removeCacheForUrl:(NSString*)url
{
	[NSObject removeFileCache:[url md5]];
}

+(void)cacheValue:(id)value forUrl:(NSString *)url
{
    if (value && [value isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"[NCSRequester] Cache saved => %@", url);
        [value setDataSaveNSDictionaryCache:[url md5]];
    }
}

#pragma mark - Custom HTTP Headers

-(void) addCustomHeaders:(NSArray *)headers forUlrMatchingRegEx:(NSString *)regExUrl
{
    if (!customHeadersForUrl)
        customHeadersForUrl = [NSMutableArray new];
    [customHeadersForUrl addObject:@{@"headers" : headers, @"urlRegEx" : regExUrl}];
}

-(NSArray *) getCustomHeadersForUrl:(NSString *)url
{
    if (!customHeadersForUrl)
        return nil;

    for (NSDictionary *element in customHeadersForUrl)
    {
        NSArray *headers = [element getXpathNilArray:@"headers"];
        NSString *urlRegEx = [element getXpathNilString:@"urlRegEx"];
        
        if (element && headers && urlRegEx)
        {
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:NSRegularExpressionCaseInsensitive error:&error];
            if ([regex numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])] > 0)
                return headers;
        }
    }
    return nil;
}

@end
