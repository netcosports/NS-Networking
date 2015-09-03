//
//  UIImageView+AFNetwokingCache.m
//  UIImageView+AFNetworkingRequest
//
//  Created by Guillaume on 27/04/2015.
//  Copyright (c) 2014 Netco Sports. All rights reserved.
//

#import "UIImageView+AFNetworkingRequest.h"
#import "UIImageView+AFNetworking.h"
#import <objc/runtime.h>
#import "AFHTTPRequestOperation.h"

@interface AFImageCache : NSCache <AFImageCache>
@end

#pragma mark - Private category (_AFNetworking)

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _af_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(af_imageRequestOperation));
}

- (void)af_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(af_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


#pragma mark - Private category (_AFNetworkingRequest)
@interface UIImageView (_AFNetworkingRequest)
@property (copy, nonatomic) void(^completionImageLoaded)(UIImage *image);
@end

@implementation UIImageView (_AFNetworkingRequest)

-(void)setCompletionImageLoaded:(void (^)(UIImage *))completion
{
    objc_setAssociatedObject(self, @selector(completionImageLoaded), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void(^)(UIImage *))completionImageLoaded
{
    return (void(^)(UIImage *))objc_getAssociatedObject(self, @selector(completionImageLoaded));
}

@end

@implementation UIImageView (AFNetworkingRequest)

#pragma mark - Image downloads
- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    __weak UIImageView *weak_self = self;
    
    if (!self.completionImageLoaded)
    {
        self.completionImageLoaded = ^(UIImage *image)
        {
            weak_self.alpha = 0.0;
            weak_self.image = image;
            
            [UIView animateWithDuration:0.15 animations:^{
                weak_self.alpha = 1;
            }];
        };
    }
    
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
    
    // URL Creation => Timeout handler
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setTimeoutInterval:timeInterval];
    [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [urlRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

    [self cancelImageRequestOperation];

    // Cache
    UIImage *cachedImage = [[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage)
    {
        if (success)
        {
            success(nil, nil, cachedImage);
        }
        else
        {
            self.image = cachedImage;
        }
        self.af_imageRequestOperation = nil;
    }
    else
    {
        if (placeholderImage)
        {
            self.image = placeholderImage;
        }
        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [[[strongSelf class] sharedImageCache] cacheImage:responseObject forRequest:urlRequest];

            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]])
            {
                if (success)
                {
                    success(urlRequest, operation.response, responseObject);
                }
                else if (responseObject)
                {
                    if (weak_self.image == placeholderImage)
                        weakSelf.completionImageLoaded(responseObject);
                    else
                        weak_self.image = responseObject;
                }
                if (operation == strongSelf.af_imageRequestOperation)
                {
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]])
            {
                if (failure)
                {
                    failure(urlRequest, operation.response, error);
                }
                if (operation == strongSelf.af_imageRequestOperation)
                {
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
        }];
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)setImageWithURLString:(NSString *)urlString
              timeoutInterval:(NSTimeInterval)timeInterval
             placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithURLString:urlString timeoutInterval:timeInterval placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
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
