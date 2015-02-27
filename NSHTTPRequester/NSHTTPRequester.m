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
        DLog(@"Bad json string !");
        return jsonString;
    }
    
    jsonString = [jsonString strReplace:@"\n" to:@""];

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
+(void)GET:(NSString *)url usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestGET jsonRequest:YES parameters:nil usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)POST:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPOST jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)PUT:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestPUT jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)DELETE:(NSString *)url withParameters:(id)params usingCacheTTL:(NSInteger)cacheTTL cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestDELETE jsonRequest:YES parameters:params usingCacheTTL:cacheTTL andCallBack:cb_rep];
}

+(void)UPLOAD:(NSString *)url withParameters:(id)params cb_send:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))cb_send cb_rep:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSHTTPRequester *sharedRequester = [NSHTTPRequester sharedRequester];
    AFHTTPRequestOperation *requestOperation = [sharedRequester createAfNetworkingOperationWithUrl:url httpRequestType:eNSHttpRequestUPLOAD jsonRequest:NO parameters:params usingCacheTTL:0 andCallBack:cb_rep];

    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
//        double percentDone = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite) * 100;
        if (cb_send)
            cb_send(totalBytesWritten, totalBytesExpectedToWrite);
    }];
}

#pragma mark - Private Creation of Operation
-(AFHTTPRequestOperation *)createAfNetworkingOperationWithUrl:(NSString *)url
                          httpRequestType:(eNSHttpRequestType)httpRequestType
                              jsonRequest:(BOOL)requestShouldBeJson
                               parameters:(id)parameters
                               usingCacheTTL:(NSInteger)cacheTTL
                              andCallBack:(void(^)(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached))cb_rep
{
    NSLog(@"[%@] URL => %@", NSStringFromClass([self class]), url);
    
    // CLIENT CACHE
    if (cacheTTL > 0)
    {
        NSDictionary *localCachedResponse = [NSHTTPRequester getCacheValueForUrl:url andTTL:cacheTTL];
        [NSObject mainThreadBlock:^{
            if (cb_rep && localCachedResponse)
                cb_rep(localCachedResponse, 0, nil, nil, YES);
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

    // COOKIES
    [afNetworkingManager.requestSerializer setHTTPShouldHandleCookies:self.ishandlingCookies];

    // SERVER CACHE POLICY
    if (cacheTTL > 0)
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    else
        [afNetworkingManager.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    // NETCO SPORTS SIGNED HTTP HEADER FIELDS
    if (self.NS_CLIENT_ID && self.NS_CLIENT_SECRET && [self.NS_CLIENT_ID length] > 0 && [self.NS_CLIENT_SECRET length] > 0)
    {
        [[NSHTTPRequester genSignatureHeaders:self.NS_CLIENT_ID clientSecret:self.NS_CLIENT_SECRET forUrl:url params:parameters isJSON:requestShouldBeJson] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
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
        [NSHTTPRequester cacheValue:responseObject forUrl:url]; // Store a Cached version of the response every time it's called.
        
        if (cb_rep)
        {
            [NSObject mainThreadBlock:^{
                cb_rep(responseObject, [operation.response statusCode], operation, nil, NO);
            }];
        }
    };
    void (^failureCompletionBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error){
        if (cb_rep)
        {
            [NSObject mainThreadBlock:^{
                cb_rep(operation.responseObject, [operation.response statusCode], operation, error, NO);
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
        } break;
            
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

#pragma mark - Custom HTTP Headers

-(void) addCustomHeaders:(NSArray *)headers forUlrMatchingRegEx:(NSString *)regExUrl
{
    if (!self.customHeadersForUrl)
        self.customHeadersForUrl = [NSMutableArray new];
    [self.customHeadersForUrl addObject:@{@"headers" : headers, @"urlRegEx" : regExUrl}];
}

-(void) cleanCustomHeadersForUrlMatchingRegEx:(NSString *)regExUrl
{
    if (!self.customHeadersForUrl)
        return ;
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    for (NSDictionary *element in self.customHeadersForUrl)
    {
        NSArray *headers = [element getXpathNilArray:@"headers"];
        NSString *urlRegEx = [element getXpathNilString:@"urlRegEx"];
        
        if (element && headers && urlRegEx)
        {
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:NSRegularExpressionCaseInsensitive error:&error];
            if ([regex numberOfMatchesInString:regExUrl options:0 range:NSMakeRange(0, [regExUrl length])] > 0)
            {
                [indexSet addIndex:[self.customHeadersForUrl indexOfObject:element]];
            }
        }
    }
    [self.customHeadersForUrl removeObjectsAtIndexes:indexSet];
}

-(NSArray *) getCustomHeadersForUrl:(NSString *)url
{
    NSMutableArray *arrayOfCustomHeaders = [NSMutableArray new];
    
    if (!self.customHeadersForUrl)
        return nil;
    
    for (NSDictionary *element in self.customHeadersForUrl)
    {
        NSArray *headers = [element getXpathNilArray:@"headers"];
        NSString *urlRegEx = [element getXpathNilString:@"urlRegEx"];
        
        if (element && headers && urlRegEx)
        {
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:NSRegularExpressionCaseInsensitive error:&error];
            if ([regex numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])] > 0)
                [arrayOfCustomHeaders addObjectsFromArray:headers];
        }
    }
    return [arrayOfCustomHeaders ToUnMutable];
}

#pragma mark - Caching

+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile
{
    NSDictionary *cachedResponse = [NSDictionary getDataFromFileCache:[url md5] temps:(int)ttlFile del:NO];
    DLog(@"[%@] Cache returned => %@", NSStringFromClass([self class]), url);
    return cachedResponse;
}

+(void)removeCacheForUrl:(NSString*)url
{
	[NSObject removeFileCache:[url md5]];
}

+(void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSError *error;
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:&error];
    if (!error)
    {
        for (NSString *file in tmpDirectory)
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:&error];
    }
    else
    {
        DLog(@"[%@] Error accessing temporary directory: %@", NSStringFromClass([self class]), [error description]);
    }
}

+(void)cacheValue:(id)value forUrl:(NSString *)url
{
    if (value && [value isKindOfClass:[NSDictionary class]])
    {
        DLog(@"[%@] Cache saved => %@", NSStringFromClass([self class]), url);
        [value setDataSaveNSDictionaryCache:[url md5]];
    }
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
