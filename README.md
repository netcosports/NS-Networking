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
[NSHTTPRequester GET:@"URL" usingCacheTTL:60 andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached) {
}];

[NSHTTPRequester POST:@"URL" withParameters:@{} andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error) {
}];

[NSHTTPRequester PUT:@"URL" withParameters:@{} andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error) {
}];

[NSHTTPRequester DELETE:@"URL" withParameters:@{} andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error) {
}];

[NSHTTPRequester UPLOAD:@"URL" withParameters:@{}sendingBlock:^(long long totalBytesWritten, long long totalBytesExpectedToWrite, double percentageUploaded) {        
} andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error) {
}];
```

Tips:
You can specify for each HTTP request a custom request serializer & a custom response serializer if needed as shown here:
```
[NSHTTPRequester GET:@"URL" usingCacheTTL:60 requestSerializer:[AFHTTPRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] andCompletionBlock:^(NSDictionary *response, NSInteger httpCode, AFHTTPRequestOperation *requestOperation, NSError *error, BOOL isCached) {
}];
```
Please refer to the AFNetworking documentation for more information about the different serializer.

Explanation:
<ul>
<li>NSHTTPRequester is based on AFNetworking, it can be used for basics HTTP calls (GET, POST, PUT, DELETE) and a custom POST for uploading pictures (UPLOAD).</li>
<li>It automatically signed each urls according to the Netco Sports Url Signature System (old & new algorithm included).</li>
<li>Each methods require a url, some parameters if needed, a cache TTL for the local cache control (GET only) and a completion block (with a dictionary for the response, the http status code, the AFHTTPRequestOperation instance, the NSError if an error occured and a boolean value describing wether the returned value comes from the local cache or not as block's parameters).</li>
<li>Remote cache is http complient, it is based on the cache-control http header field.</li>
</ul>


<b><i>Further controls</i></b>

<i>Custom http headers</i>:
```
-(void)addCustomHeaders:(NSArray *)headers forUlrMatchingRegEx:(NSString *)regExUrl;
```

An array of custom http headers can be used by this requester for each called urls responding to the regEx.


<i>Custom timeout per request</i>:
```
-(void)adCustomTimeout:(NSTimeInterval)secondsTimeout forUlrsMatchingRegEx:(NSString *)regExUrl;
```

<i>Local cache:</i>
```
+(id)getCacheValueForUrl:(NSString *)url andTTL:(NSInteger)ttlFile;
+(void)removeCacheForUrl:(NSString*)url;
+(void)cacheValue:(id)value forUrl:(NSString *)url;
+(void)clearCache;
```

Local cache can be entirely controlled by the user without making any http calls.

<i>Cookies:</i>
```
-(void)setHTTPShouldHandleCookies:(BOOL)shouldHandleCookies;
+(void)clearCookies;
```

Cookies can be enable or disabled, and cleared by the user.
