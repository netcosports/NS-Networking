//
//  NSHTTPRequesterTests.m
//  cafhub
//
//  Created by Guillaume on 17/07/14.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <NSTCategories/NSObject+NSObject_Tool.h>

#import "NSHTTPRequesterTests.h"
#import "NSHTTPRequester.h"

@implementation NSHTTPRequesterTests

+(void) launchTests
{
    [NSHTTPRequester sharedRequester].NS_CLIENT_ID = @"2c4ba50e-67fc-481a-994f-d7990c621e5c";
    [NSHTTPRequester sharedRequester].NS_CLIENT_SECRET = @"882b57a56d63b9e9da45f1fe66a087f57ee101c1";
    // [[NSHTTPRequester sharedRequester] setHTTPShouldHandleCookies:NO];
    
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TEST NSHTTREQUESTER <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
//    [NSHTTPRequesterTests getTESTS];
    [NSHTTPRequesterTests postTEST1:^(BOOL ok) {
        [NSHTTPRequesterTests uploadFileTESTS:^(BOOL ok) {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DONE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
        }];
    }];
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

+(void)postTEST1:(void(^)(BOOL ok))cb_test
{
    NSDictionary *loginNSAPIData = @{@"app_bundle" : @"com.jai.GameConnectV2",
                                     @"device_model" : @"44AFC89459EB48E4A34689ADA4A2E54A",
                                     @"device_version" : @"7.1",
                                     @"email" : @"guillaume.derivery@gmail.com",
                                     @"password" : @"lkdslk42"};
    
    NSString *url = @"https://nsapi-integration.netcodev.com/api/1/users/_/login_by_email";
    [NSHTTPRequester POST:url withParameters:loginNSAPIData usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
    {
        NSLog(@"****************************************************");
        NSLog(@"[NSHTTPRequester] POST %@", url);
        NSLog(@"%@", rep);
        if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
        {
            sleep(1);
            [NSHTTPRequesterTests postTEST2:cb_test];
            NSLog(@"************************ OK ****************************");
        }
        else
        {
            cb_test(NO);
            NSLog(@"************************ KO ****************************");
        }
    }];
}

+(void)postTEST2:(void(^)(BOOL ok))cb_test
{
    NSDictionary *updateNSAPIData = @{@"nickname" : @"Uncle Bens"};
    NSString *url = @"https://nsapi-integration.netcodev.com/api/1/users/_/update_my_profile";
    [NSHTTPRequester POST:url withParameters:updateNSAPIData usingCacheTTL:0 cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
     {
         NSLog(@"****************************************************");
         NSLog(@"[NSHTTPRequester] POST %@", url);
         NSLog(@"%@", rep);
         if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
         {
             cb_test(YES);
             NSLog(@"************************ OK ****************************");
         }
         else
         {
             cb_test(NO);
             NSLog(@"************************ KO ****************************");
         }
     }];
}

+(void)uploadFileTESTS:(void(^)(BOOL ok))cb_test
{
    NSDictionary *postDic = @{@"mimetype" : @"image/jpeg",
                              @"filename" : @"toto.png",
                              @"image" : [UIImage imageNamed:@"smiley"]};
    
    NSString *url = @"https://nsapi-integration.netcodev.com/api/1/users/_/upload_my_avatar";
    
    [NSHTTPRequester UPLOAD:url withParameters:postDic cb_send:^(long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        NSLog(@"SENDING %lld / %lld", totalBytesWritten, totalBytesExpectedToWrite);
        
    } cb_rep:^(NSDictionary *rep, NSInteger httpCode, BOOL isCached)
    {
        NSLog(@"****************************************************");
        NSLog(@"[NSHTTPRequester] UPLOAD %@", url);
        NSLog(@"%@", rep);
        if (rep && [[rep allKeys] count] > 0 && httpCode == 200)
        {
            NSLog(@"************************ OK ****************************");
            cb_test(YES);
        }
        else
        {
            NSLog(@"************************ KO ****************************");
            cb_test(NO);
        }
    }];
}

@end
