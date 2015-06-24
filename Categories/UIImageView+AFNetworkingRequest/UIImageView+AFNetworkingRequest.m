//
//  UIImageView+AFNetwokingCache.m
//  UIImageView+AFNetworkingRequest
//
//  Created by Guillaume on 27/04/2015.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import "UIImageView+AFNetworkingRequest.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (AFNetworkingRequest)

#pragma mark - Image downloads
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
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
//        if ((weak_self.image && weak_self.image != placeholderImage) ||
//            weak_self.image == nil)
//        {
            [UIView animateWithDuration:0.15 animations:^{
                weak_self.alpha = 0.3f;
            } completion:^(BOOL finished) {
                weak_self.image = image;
                [UIView animateWithDuration:0.15 animations:^{
                    weak_self.alpha = 1;
                } completion:^(BOOL finished) {
                }];
            }];
//        }

        if (success)
            success(request, response, image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
        if (failure)
            failure(request, response, error);
    }];
}

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithURLString:urlString timeoutInterval:timeInterval placeholderImage:placeholderImage success:nil failure:nil];
}

#pragma mark - Image cache
+ (UIImage *)cachedImageForUrl:(NSString *)url
{
    return [[UIImageView sharedImageCache] cachedImageForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

+ (UIImageView *)imageViewFromCachedImageForUrl:(NSString *)url
{
    return [[UIImageView alloc] initWithImage:[self cachedImageForUrl:url]];
}

@end
