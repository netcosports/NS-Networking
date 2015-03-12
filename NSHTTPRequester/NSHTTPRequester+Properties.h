//
//  NSHTTPRequester+Properties.h
//  NS-Networking
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester.h"

typedef enum
{
    eNSHttpPropertyHeader,
    eNSHttpPropertyTimeout,
    eNSHttpPropertyUnknow,
} eNSHttpRequestPropertyType;

@interface NSHTTPRequester (Properties)

#pragma mark - Custom HTTP Headers

/**
 *  Add custom HTTP Headers to all requests using an url responding to the regular expression
 *
 *  @param headers  HTTP Headers to add
 *  @param regExUrl Regular Expression defining all urls that needs the headers
 */
-(void) addCustomHeaders:(NSArray *)headers forUlrsMatchingRegEx:(NSString *)regExUrl;

/**
 *  Remove all custom HTTP Headers associated to the urls defined by the given regular expression
 *
 *  @param regExUrl Regular Expression defining all urls associated with the headers
 */
-(void) cleanCustomHeadersForUrlMatchingRegEx:(NSString *)regExUrl;

/**
 *  Get all custom HTTP Headers associated to the given url
 *
 *  @param url Url of the request
 *
 *  @return Array of HTTP Headers associated to the given url
 */
-(NSArray *) getCustomHeadersForUrl:(NSString *)url;

#pragma mark - Custom Timeout

/**
 *  Add custom Timeout to all requests using an url responding to the regular expression
 *
 *  @param secondsTimeout  Timeout expressed in seconds to associate with the regular expression
 *
 *  @param regExUrl Regular Expression defining all urls that needs the custom timeout
 */
-(void)adCustomTimeout:(NSTimeInterval)secondsTimeout forUlrsMatchingRegEx:(NSString *)regExUrl;

/**
 *  Remove all timeouts associated to the urls defined by the given regular expression
 *
 *  @param regExUrl Regular Expression defining all urls associated with the timeout
 */
-(void)cleanCustomTimeoutForUrlsMatchingRegEx:(NSString *)regExUrl;

/**
 *  Get custom timeout associated to the given url
 *
 *  @param url Url of the request
 *
 *  @return Timeout associated to the given url expressed in seconds
 */

-(NSTimeInterval) getCustomTimeoutsForUrl:(NSString *)url;

@end
