;//
//  UIImageView+AFNetwokingCache.h
//  TVA Sport Framework
//
//  Created by Jean-François GRANG on 27/06/2014.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AFNetwokingCache)

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage;

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
