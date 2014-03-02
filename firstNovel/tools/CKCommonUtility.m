//
//  CKCommonUtility.m
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
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

+ (NSArray *)videoTypeList
{
    return [NSArray arrayWithObjects:
            @"video/mpeg4",
            @"video/mpeg",
            @"video/mp4",
            @"video/mpg",
            @"video/x-mpg",
            @"video/x-mpeg",
            @"video/vnd.rn-realvideo",
            @"video/x-ms-wmv",
            @"video/x-ms-wvx",
            @"video/x-ms-wmx",
            @"video/x-ms-wm",
            @"video/x-sgi-movie",
            @"video/x-ivf",
            @"video/avi",
            @"video/x-ms-asf", nil];
}

+ (BOOL)isMP4File:(NSString *)contentType
{
    if ([[contentType lowercaseString] rangeOfString:@"video/mp4"].location != NSNotFound)
    {
        return YES;
    }
    if ([[contentType lowercaseString] rangeOfString:@"video/mpeg4"].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isM3U8:(NSString *)aContentType
{
    if ([[aContentType lowercaseString] rangeOfString:@"application/vnd.apple.mpegurl"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"application/x-mpegurl"].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isTextHtml:(NSString *)aContentType
{
    return ([[aContentType lowercaseString] rangeOfString:@"text/html"].location != NSNotFound);
}

+ (BOOL)isTextPlain:(NSString *)aContentType
{
    return ([[aContentType lowercaseString] rangeOfString:@"text/plain"].location != NSNotFound);
}

+ (BOOL)isAudioMP3:(NSString *)aContentType
{
    if ([[aContentType lowercaseString] rangeOfString:@"audio/mp3"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"audio/mpeg"].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isImage:(NSString *)aContentType
{
    if ([[aContentType lowercaseString] rangeOfString:@"image/png"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"image/gif"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"image/jpeg"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"image/x-icon"].location != NSNotFound)
    {
        return YES;
    }
    if ([[aContentType lowercaseString] rangeOfString:@"image/tiff"].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (NSArray *)imageTypeList
{
    return [NSArray arrayWithObjects:
            @"jpg",
            @"jpeg",
            @"tif",
            @"tiff",
            @"png",
            @"gif",
            @"ico", nil];
}


+ (CGFloat)totalDiskStorage
{
    NSDictionary *fsAttr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float diskSize = [[fsAttr objectForKey:NSFileSystemSize] doubleValue]/1024.0/1024.0;
    return diskSize;
}

+ (CGFloat)avaiableDiskStorage
{
    NSDictionary *fsAttr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float diskSize = [[fsAttr objectForKey:NSFileSystemFreeSize] doubleValue]/1024.0/1024.0;
    return diskSize;
}

+ (NSString *)sizeStr:(long long)bytes
{
    NSMutableString *totalStr = [NSMutableString string];
    if (bytes < 1)
    {
        [totalStr appendString:[NSString stringWithFormat:@"%@", @"未知"]];
    }
    else if (bytes < 1024)
    {
        [totalStr appendFormat:@"%dB", (int)bytes];
    }
    else if (bytes < (1024*1024))
    {
        [totalStr appendFormat:@"%.1fK", (CGFloat)bytes/1024.0f];
    }
    else if (bytes < (1024*1024*1024))
    {
        [totalStr appendFormat:@"%.1fM", (CGFloat)bytes/1024.0f/1024.0f];
    }
    else
    {
        [totalStr appendFormat:@"%.1fG", (CGFloat)bytes/1024.0f/1024.0f/1024.0f];
    }
    return totalStr;
}

+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha
{
    // #rrggbb 大小写字母及数字
	int nums[6] = {0};
	for (int i = 1; i < MIN(7, [aHexStr length]); i++) // 第一个字符是“＃”号
    {
		int asc = [aHexStr characterAtIndex:i];
		if (asc >= '0' && asc <= '9') // 数字
			nums[i - 1] = [aHexStr characterAtIndex:i] - '0';
        else if(asc >= 'A' && asc <= 'F') // 大写字母
			nums[i - 1] = [aHexStr characterAtIndex:i] - 'A' + 10;
        else if(asc >= 'a' && asc <= 'f') // 小写字母
			nums[i - 1] = [aHexStr characterAtIndex:i] - 'a' + 10;
        else
			return [UIColor whiteColor];
	}
	float rValue = (nums[0] * 16 + nums[1]) / 255.0f;
	float gValue = (nums[2] * 16 + nums[3]) / 255.0f;
	float bValue = (nums[4] * 16 + nums[5]) / 255.0f;
	UIColor *rgbColor = [UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aAlpha];
	return rgbColor;
}

+ (void)goRating
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RATE_FOR_IOS7_URL_STRING]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RATE_FOR_IOS6_URL_STRING]];
    }
}

+ (void)goPro
{
#ifndef _LITEBOOK
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BAIDU_RATE_FOR_IOS7_URL_STRING]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BAIDU_RATE_FOR_IOS6_URL_STRING]];
    }
#else
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RATE_FOR_IOS7_URL_STRING]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:RATE_FOR_IOS6_URL_STRING]];
    }
#endif
}


@end
