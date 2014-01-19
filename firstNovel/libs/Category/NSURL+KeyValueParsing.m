//
//  NSURL+KeyValueParsing.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-1-16.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "NSURL+KeyValueParsing.h"

@implementation NSURL (KeyValueParsing)

- (NSDictionary *)keysAndValuesOfString:(NSString *)string
{
    if (!string) return nil;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (NSString *pair in [string componentsSeparatedByString:@"&"]) {
        NSArray *keyAndValue = [pair componentsSeparatedByString:@"="];
        if ([keyAndValue count] == 2) {
            DICTIONARY_SET_OBJECT_FOR_KEY(result, [keyAndValue objectAtIndex:1], [keyAndValue objectAtIndex:0]);
        }
        else if ([keyAndValue count] == 1) {
            DICTIONARY_SET_OBJECT_FOR_KEY(result, @"", [keyAndValue objectAtIndex:0]);
        }
    }
    return [[result copy] autorelease];
}

- (NSDictionary *)keysAndValuesOfFragment
{
    return [self keysAndValuesOfString:[self fragment]];
}

- (NSDictionary *)keysAndValuesOfQuery
{
    return [self keysAndValuesOfString:[self query]];
}

@end