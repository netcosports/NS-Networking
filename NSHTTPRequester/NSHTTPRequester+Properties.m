//
//  NSHTTPRequester+Properties.m
//  FoxSports
//
//  Created by Guillaume on 03/03/15.
//  Copyright (c) 2015 Netco Sports. All rights reserved.
//

#import "NSHTTPRequester+Properties.h"
#import "NSHTTPRequester+Private.h"

@implementation NSHTTPRequester (Properties)

-(NSString *) getStringFromPropertyType:(eNSHttpRequestPropertyType)propertyType
{
    switch (propertyType)
    {
        case eNSHttpPropertyHeader:
            return @"header";
            
        case eNSHttpPropertyTimeout:
            return @"timeout";
            
        default:
            return @"unknown";
    }
}

-(eNSHttpRequestPropertyType)getPropertyTypeFromString:(NSString *)propertyType
{
    if (propertyType)
    {
        if ([propertyType isEqualToString:@"header"])
            return eNSHttpPropertyHeader;
        else if ([propertyType isEqualToString:@"timeout"])
            return eNSHttpPropertyTimeout;
    }
    return eNSHttpPropertyUnknow;
}

#pragma mark - Custom Values
-(void) addCustomValue:(id)value withPropertyType:(eNSHttpRequestPropertyType)propertyType forUrlsMatchingRegEx:(NSString *)regExUrl
{
    if (!customPropertiesForUrl)
        customPropertiesForUrl = [NSMutableArray new];
    [customPropertiesForUrl addObject:@{@"type" : [self getStringFromPropertyType:propertyType],
                                        @"urlRegEx" : regExUrl,
                                        @"value" : value}];
}

-(void) cleanCustomValuesWithPropertyType:(eNSHttpRequestPropertyType)propertyType forUrlsMatchingRegEx:(NSString *)regExUrl
{
    if (!customPropertiesForUrl)
        return ;
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    for (NSDictionary *element in customPropertiesForUrl)
    {
        if ([self getPropertyTypeFromString:[element getXpathEmptyString:@"type"]] == propertyType)
        {
            NSString *urlRegEx = [element getXpathNilString:@"urlRegEx"];
            
            if (urlRegEx && regExUrl && [urlRegEx isEqualToString:regExUrl])
            {
                [indexSet addIndex:[customPropertiesForUrl indexOfObject:element]];
            }
        }
    }
    [customPropertiesForUrl removeObjectsAtIndexes:indexSet];
}

-(NSArray *) getCustomValuesWithPropertyType:(eNSHttpRequestPropertyType)propertyType forUrl:(NSString *)url
{
    NSMutableArray *arrayOfCustomValues = [NSMutableArray new];
    
    if (!customPropertiesForUrl)
        return nil;
    
    for (NSDictionary *element in customPropertiesForUrl)
    {
        if ([self getPropertyTypeFromString:[element getXpathEmptyString:@"type"]] == propertyType)
        {
            NSString *urlRegEx = [element getXpathNilString:@"urlRegEx"];
            
            if (element && urlRegEx)
            {
                NSError *error;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:NSRegularExpressionCaseInsensitive error:&error];
                if ([regex numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])] > 0)
                {
                    id value = [element objectForKey:@"value"];
                    
                    if (value && [value isKindOfClass:[NSArray class]])
                    {
                        [arrayOfCustomValues addObjectsFromArray:value];
                    }
                    else if (value)
                    {
                        [arrayOfCustomValues addObject:element];
                    }
                }
            }
        }
    }
    return [arrayOfCustomValues ToUnMutable];
}

#pragma mark - Custom HTTP Headers
-(void) addCustomHeaders:(NSArray *)headers forUlrsMatchingRegEx:(NSString *)regExUrl
{
    if (!headers || ![headers isKindOfClass:[NSArray class]])
    {
        DLog(@"Bad headers passed");
        return;
    }
    if (!regExUrl)
    {
        DLog(@"Bad url regex");
        return;
    }
    [self addCustomValue:headers withPropertyType:eNSHttpPropertyHeader forUrlsMatchingRegEx:regExUrl];
}

-(void) cleanCustomHeadersForUrlMatchingRegEx:(NSString *)regExUrl
{
    if (!regExUrl)
    {
        DLog(@"Bad url regex");
        return;
    }
    [self cleanCustomValuesWithPropertyType:eNSHttpPropertyHeader forUrlsMatchingRegEx:regExUrl];
}

-(NSArray *) getCustomHeadersForUrl:(NSString *)url
{
    if (!url)
    {
        DLog(@"Bad url");
        return @[];
    }
    return [self getCustomValuesWithPropertyType:eNSHttpPropertyHeader forUrl:url];
}


#pragma mark - Custom Timeout
-(void)adCustomTimeout:(NSTimeInterval)secondsTimeout forUlrsMatchingRegEx:(NSString *)regExUrl
{
    if (secondsTimeout < 0)
    {
        DLog(@"Bad timeout passed");
        return;
    }
    if (!regExUrl)
    {
        DLog(@"Bad url regex");
        return;
    }
    [self addCustomValue:[NSNumber numberWithDouble:secondsTimeout] withPropertyType:eNSHttpPropertyTimeout forUrlsMatchingRegEx:regExUrl];
}

-(void)cleanCustomTimeoutForUrlsMatchingRegEx:(NSString *)regExUrl
{
    if (!regExUrl)
    {
        DLog(@"Bad url regex");
        return;
    }
    [self cleanCustomValuesWithPropertyType:eNSHttpPropertyTimeout forUrlsMatchingRegEx:regExUrl];
}


-(NSTimeInterval) getCustomTimeoutsForUrl:(NSString *)url
{
    if (!url)
    {
        DLog(@"Bad url");
        return self.generalTimeout;
    }
    
    NSArray *arrayOfTimeouts = [self getCustomValuesWithPropertyType:eNSHttpPropertyTimeout forUrl:url];
    
    if (arrayOfTimeouts && [arrayOfTimeouts count] > 0)
        return [[arrayOfTimeouts objectAtIndex:0] floatValue];
    else
        return self.generalTimeout;
}

@end

