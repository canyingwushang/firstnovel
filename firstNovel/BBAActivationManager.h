//
//  BBAActivationManager.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 12-9-19.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

// 头文件
#import <Foundation/Foundation.h>

// 枚举
typedef enum
{
    EActivationTypeBaiduBoxApp = 0,     // 百度App新用户
    EActivationTypeBaiduMobile          // 掌百升级用户
}TActivationType;

// @class - BBAActivationManager
// @brief - App启动时检查用户激活状况--单例
@interface BBAActivationManager : NSObject

// 类方法
+ (BBAActivationManager *)sharedInstance;
+ (void)doActivation; // 用户激活入口

@end // BBAActivationManager
