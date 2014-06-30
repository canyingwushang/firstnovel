//
//  BBAUpdateManager.h
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 09/25/12.
//  Copyright (c) 2012 Baidu Inc. All rights reserved.
//

// update的时机可以理解为：尽量在满足两个条件的情况下update，如果实在无法满足也会update - zxh

// 头文件
#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestDelegate.h"

// @class - BBAUpdateManager
// @brief - App启动时，服务器下发信息更新管理类--单例
//             下发信息包括通知（搜索框活动内容及新版本通知）及垂搜地址
@interface BBAUpdateManager : NSObject <ASIHTTPRequestDelegate>

// 属性
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, retain) ASIFormDataRequest *updateReq;

// 类方法
+ (BBAUpdateManager *)sharedInstance; // 单例

// Open API
- (void)sendUpdateRequest;

@end // BBAUpdateManager
