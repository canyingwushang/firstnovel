//
//  UIDevice-Extend.h
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 12-5-2.
//  Copyright (c) 2012年 baidu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IPHONE1						@"iPhone1"
#define IPHONE3  					@"iPhone3"
#define IPAD1							@"iPad1"
#define IPAD3							@"iPad3"

#define PLATFORM_FORMAT             @"%@,%@"
#define DEVICEINFO_FORMAT           @"%@_%@"

// @class - UIDevice
// @brief - 扩展UIDevice，获得更多的设备相关信息
@interface UIDevice (Extend)

- (NSString *)getSysInfoByName:(const char *)aTypeSpecifier;
- (NSString *)getCellularProviderName;  // 获取运营商信息
- (NSString *)getMNC;           //获取移动网络码
- (NSString *)getMCC;           //获取国家码
- (NSString *)getMACAddress;     // 获取MAC地址

- (BOOL)isRetina;           // 判断是否是高清屏幕
- (BOOL)isJailBreak;        // 判断是否越狱

@end
