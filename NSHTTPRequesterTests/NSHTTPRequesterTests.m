//
//  NSHTTPRequesterTests.m
//  cafhub
//
//  Created by Guillaume on 17/07/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import "NSHTTPRequesterTests.h"
#import "NSHTTPRequester.h"

@implementation NSHTTPRequesterTests

+(void) launchTests
{
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TEST NSHTTREQUESTER <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    [NSHTTPRequesterTests getTESTS];
    [NSHTTPRequesterTests postTESTS];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

+(void)getTESTS
{
    // Simple GET without custom http headers
    NSString *url = @"http://fr.starafrica.com/football/feed/?type=json&cat=5712";
    [NSHTTPRequester GET:url usingCacheTTL:60*60 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
    {
        NSLog(@"****************************************************");
        NSLog(@"[NSHTTPRequester] GET %@", url);
        NSLog(@"%@", rep);
        if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
            NSLog(@"************************ OK ****************************");
        else
            NSLog(@"************************ KO ****************************");
    }];
    
    // Get on www.thefanclub.com. It has a txt/html content-type in the http header of the response. JSON Serializer have to be used for the response.
    
    url = @"http://www.thefanclub.com/partnervideo/get_app_videolist/12/1/30.ijson";
    [NSHTTPRequester GET:url usingCacheTTL:60*60 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
     {
         NSLog(@"****************************************************");
         NSLog(@"[NSHTTPRequester] GET %@", url);
         NSLog(@"%@", rep);
         if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
             NSLog(@"************************ OK ****************************");
         else
             NSLog(@"************************ KO ****************************");
     }];
}

+(void)postTESTS
{
    NSDictionary *loginNSAPIData = @{@"app_bundle" : @"com.jai.GameConnectV2",
                                     @"device_model" : @"44AFC89459EB48E4A34689ADA4A2E54A",
                                     @"device_version" : @"7.1",
                                     @"email" : @"guillaume.derivery@gmail.com",
                                     @"password" : @"lkdslk42"};

    [NSHTTPRequester sharedRequester].NS_CLIENT_ID = @"2c4ba50e-67fc-481a-994f-d7990c621e5c";
    [NSHTTPRequester sharedRequester].NS_CLIENT_SECRET = @"882b57a56d63b9e9da45f1fe66a087f57ee101c1";
    
    NSString *url = @"https://nsapi-integration.netcodev.com/api/1/users/_/login_by_email";
    [NSHTTPRequester POST:url withParameters:loginNSAPIData usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
    {
        NSLog(@"****************************************************");
        NSLog(@"[NSHTTPRequester] POST %@", url);
        NSLog(@"%@", rep);
        if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
            NSLog(@"************************ OK ****************************");
        else
            NSLog(@"************************ KO ****************************");
    }];
    
    
    
}

@end
