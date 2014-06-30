//
//  BBAUDID.h
//  BaiduBoxApp
//
//  Created by wang cong on 13-8-19.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kVerifiable_BBAUDID_Length	51 // UDID长度，不是这个长度的UDID视为非法的

// @class - BBAUDID
// @brief - 生成可校验的UDID
@interface BBAUDID : NSObject

+ (NSString *)verifiableValue; // 可校验的UDID，共51位

@end // BBAUDID
