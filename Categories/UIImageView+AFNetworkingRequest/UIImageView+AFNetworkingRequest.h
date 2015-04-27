;//
//  UIImageView+AFNetworkingRequest
//  UIImageView+AFNetworkingRequest
//
//  Created by Guillaume on 27/04/2015.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AFNetworkingRequest)

/**
 * Asynchronously downloads an image from the specified url based on the existing (UIImageView+AFNetworking) category.
 * The differences here are the specifc timeout that can be passed to the download request & the urlString can also 
 * describe a local image file embbeded in the main bundle of the application.
 *
 */
#pragma mark - Image downloads
- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/**
 * Short version of previous declaration.
 * Here the success & failure blocks callbacks are nil.
 *
 */
- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage;

/**
 * Returns a cached image for the specififed url, if available.
 * It uses the sharedImageCache (<AFImageCache>) of the existing (UIImageView+AFNetworking) category.
 * Here the url as a string can be used insted of a NSURLRequest.
 *
 */
#pragma mark - Image cache
+ (UIImage *)cachedImageForUrl:(NSString *)url;

/**
 * Implementation based on the cachedImageForUrl: method.
 * It also creates an UIImageView from the returned UIImage.
 *
 */
+ (UIImageView *)imageViewFromCachedImageForUrl:(NSString *)url;

@end
