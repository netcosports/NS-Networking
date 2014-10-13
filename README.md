NS-Networking
=============

<b>NSHTTPRequester</b>

Init:
```
[NSHTTPRequester sharedRequester].NS_CLIENT_ID = @"CREDENTIAL_CLIENT_ID";
[NSHTTPRequester sharedRequester].NS_CLIENT_SECRET = @"CREDENTIAL_CLIENT_SECRET_KEY";
```

Usage:
```
[NSHTTPRequester GET:@"URL" usingCacheTTL:10 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached) {
}];

[NSHTTPRequester POST:@"URL" withParameters:@{@"key" : @"value"} usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached) {
}];

[NSHTTPRequester PUT:@"URL" withParameters:@{@"key" : @"value"} usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached) {
}];

[NSHTTPRequester DELETE:@"URL" withParameters:@{@"key" : @"value"} usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached) {
}];

[NSHTTPRequester UPLOAD:@"URL" withParameters:@{@"key" : @"value"} cb_send:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {

// For example
// double percentDone = ((double)totalBytesWritten / (double)totalBytesExpectedToWrite) * 100;
     
} cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached) {
        
}];
```
Explanation:

NSHTTPRequester is based on AFNetworking, it can be used for basics HTTP calls (GET, POST, PUT, DELETE) and a custom POST for uploading pictures (UPLOAD).
It automatically signed each urls according to the Netco Sports Url Signature System (old & new algorithm included).
Each methods require a url, some parameters if needed, a cache TTL for the local cache control and a completition (with a dictionary for the response, the http status code and a boolean value describing wether the returned value comes from the local cache or not as block's parameters).
Remote cache is 

<i>Further controls</i>
Custom http headers:
```
-(void)addCustomHeaders:(NSArray *)headers forUlrMatchingRegEx:(NSString *)regExUrl;
```

An array of custom http headers can be used by this requester for each called urls responding to the regEx.

Local cache:
```
+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile;
+(void)removeCacheForUrl:(NSString*)url;
+(void)cacheValue:(id)value forUrl:(NSString *)url;
+(void)clearCache;
```

Local cache can be entirely controlled by the user without making any http calls.

Cookies:
```
-(void)setHTTPShouldHandleCookies:(BOOL)shouldHandleCookies;
+(void)clearCookies;
```

Cookies can be enable or disabled, and cleared by the user.
