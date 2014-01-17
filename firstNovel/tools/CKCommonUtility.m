//
//  CKCommonUtility.m
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKCommonUtility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CKCommonUtility

+ (CGSize)getApplicationSize
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        return [[UIScreen mainScreen] bounds].size;
    }
    else
    {
        return [[UIScreen mainScreen] applicationFrame].size;
    }
}

+ (NSString *)md5:(NSString *)aInput
{
    const char *cStr = [aInput UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+ (BOOL)isiPhone5
{
    CGSize applicationSize = [CKCommonUtility getApplicationSize];
    if ((int)applicationSize.width == 320 && (int)applicationSize.height > 480)
        return YES;
    return NO;
}

@end
