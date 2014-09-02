//
//  UIImageView+AFNetwokingCache.m
//  TVA Sport Framework
//
//  Created by Jean-François GRANG on 27/06/2014.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import "UIImageView+AFNetwokingCache.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (AFNetwokingCache)

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithURLString:urlString timeoutInterval:timeInterval placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    
    // In case there is the path of a local image in the URL String.
    if (urlString && ([urlString rangeOfString:@"http"].location == NSNotFound || [urlString rangeOfString:@"/"].location == NSNotFound))
    {
        UIImage *localImage = [UIImage imageNamed:urlString];
        if (localImage)
        {
            self.image = localImage;
            if (success)
                success(nil, nil, localImage);
            return;
        }
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setTimeoutInterval:timeInterval];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weak_self = self;
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        weak_self.image = image;
        if (success)
            success(request, response, image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure)
            failure(request, response, error);
    }];
}

@end
