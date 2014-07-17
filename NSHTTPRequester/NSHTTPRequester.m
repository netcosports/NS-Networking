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
    eNSHttpRequestGET,
    eNSHttpRequestPOST,
    eNSHttpRequestPUT,
    eNSHttpRequestDELETE,
} eNSHttpRequestType;

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

#pragma mark - NS Signature System
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
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *stringFromJson = [[[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] strReplace:@"\n" to:@""] strReplace:@" " to:@""];
    return [stringFromJson sha1];
}

#pragma mark - HTTP Methods
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestGET jsonRequest:YES parameters:nil usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)POST:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPOST jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)PUT:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPUT jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)DELETE:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDELETE jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)UPLOAD:(NSString *)url withParameters:(id)params cb_send:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))cb_send cb_rep:(void(^)(NSDictionary *rep, NSInteger httpCode, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDELETE jsonRequest:NO parameters:params usingCacheTTL:0 andCallBack:cb_rep];

    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
        if (cb_send)
            cb_send(totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

-(AFHTTPRequestOperation *)createAfNetworkingOperationWithUrl:(NSString *)url
                          httpRequestType:(eNSHttpRequestType)httpRequestType
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
    
    // FORCE RESPONSE SERIALIZER TO ACCEPT CONTENT-TYPE (text/html) as well. (thefanclub.com send response with only one content-type : text/html).
    NSMutableSet *setOfAcceptablesContentTypesInResonse = [afNetworkingManager.responseSerializer.acceptableContentTypes mutableCopy];
    [setOfAcceptablesContentTypesInResonse addObject:@"text/html"];
    [afNetworkingManager.responseSerializer setAcceptableContentTypes:setOfAcceptablesContentTypesInResonse];
    
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
             [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  [afNetworkingManager.requestSerializer setValue:obj forHTTPHeaderField:key];
              }];
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
    NSDictionary *cachedResponse = [NSDictionary getDataFromFileCache:[url md5] temps:(int)ttlFile del:NO];
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
