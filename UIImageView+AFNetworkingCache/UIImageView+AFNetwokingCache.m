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
             placeholderImage:(UIImage *)placeholderImage {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:timeInterval];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setTimeoutInterval:timeInterval];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weak_self = self;
    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weak_self.image = image;
        if (success) {
            success(request, response, image);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (failure) {
            failure(request, response, error);
        }
    }];
}

@end
