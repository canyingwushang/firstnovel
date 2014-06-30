//
//  UIDevice-Extend.m
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 12-5-2.
//  Copyright (c) 2012年 baidu.com. All rights reserved.
//

// 头文件
#import "UIDevice-Extend.h"
#include <sys/sysctl.h>														// sysctlbyname
#include <sys/socket.h> 														// MAC地址
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>			// 获取运营商信息时依赖这两个头文件,需要加入对库“CoreTelephony.framework”的依赖
#import <CoreTelephony/CTCarrier.h>

@implementation UIDevice (Extend)

#pragma mark - sysctlbyname utils

- (NSString *)getSysInfoByName:(const char *)aTypeSpecifier
{
    size_t size;
    sysctlbyname(aTypeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(aTypeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	
    free(answer);
    return results;
}

// 目前没有区分iPad和iPhone的模拟器
- (NSString *)platform
{
	NSString *platformInfo = [self getSysInfoByName:"hw.machine"];
    NSString *noUnderlinePlatFromInfo = [platformInfo stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
#if TARGET_IPHONE_SIMULATOR
	if ([self isRetina])
		return [NSString stringWithFormat:PLATFORM_FORMAT, IPHONE3, noUnderlinePlatFromInfo];
	else
		return [NSString stringWithFormat:PLATFORM_FORMAT, IPHONE1, noUnderlinePlatFromInfo];
#endif
    return noUnderlinePlatFromInfo;
}

- (NSString *)getDeviceInfo
{
    NSString *noUnderlineSystemVersion = [[UIDevice currentDevice].systemVersion stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSString *platform = [self platform];
    if (CHECK_STRING_INVALID(platform))
    {
        platform = @"NUL";
    }
    if (CHECK_STRING_INVALID(noUnderlineSystemVersion))
    {
        noUnderlineSystemVersion = @"0.0";
    }
	return [NSString stringWithFormat:DEVICEINFO_FORMAT, platform, noUnderlineSystemVersion];
}

#pragma mark - misc

- (NSString *)getCellularProviderName
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
	[netInfo release];
    NSString *cellularProviderName = [[[carrier carrierName] retain] autorelease];
    return cellularProviderName;
}

- (NSString *)getMNC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = [netInfo subscriberCellularProvider];
	[netInfo release];
	return [carrier mobileNetworkCode];
}

- (NSString *)getMCC
{
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
	CTCarrier *carrier = [netInfo subscriberCellularProvider];
	[netInfo release];
	return [carrier mobileCountryCode];
}

- (NSString *)getMACAddress
{
    int 					mib[6];
    size_t              	len;
    char                	*buf;
    unsigned char       	*ptr;
    struct if_msghdr    	*ifm;
    struct sockaddr_dl  	*sdl;
	
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
	
    if ((mib[5] = if_nametoindex("en0")) == 0) 
    {
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) 
    {
        return nil;
    }
    
    if ((buf = (char*)malloc(len)) == NULL) 
    {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) 
    {
		free(buf);
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return [outstring uppercaseString];
}

- (BOOL)isRetina
{
    return [[UIScreen mainScreen] scale] == 2.0f;
}

- (BOOL)isJailBreak
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"])
	{
        return YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"])
	{
        return YES;
    }
    
    return NO;
}

@end  // UIDevice (Extend)
