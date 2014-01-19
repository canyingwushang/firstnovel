//
//  BBANetworkManager.h
//  BaiduBoxApp
//
//  Created by naonao on 12-9-20.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

// 头文件
#import <Foundation/Foundation.h>
#import "BBANetWorkCheckSocket.h"

// 枚举
enum TNetRequestType
{
	ENetRequestKeyWordSearch = 0x0001,      // 关键字搜索
	ENetRequestVoiceRecognition = 0x0002,   // 语音搜索
	ENetRequestUpdateDing = 0x0004,         // 更新阿拉丁
	ENetRequestAddMoreDingWebView = 0x0008, // 添加更多Ding Web
	ENetRequestOCRTextRecognition = 0x0010, // OCR文字识别
    ENetRequestLoadWebView = 0x0020,        // 用户反馈Web
	ENetRequestImageSearch = 0x0040,		// 图像搜索
	ENetRequestLogInOut = 0x0080			// 登录退出
};

// 前向声明
@class Reachability;

// @class - BBANetworkManager
// @brief - 网络管理类，判断网络状态等，分浏览页与非浏览页两套处理逻辑
@interface BBANetworkManager : NSObject<BBANetWorkCheckDelegate>

// 属性
@property (nonatomic, retain) BBANetWorkCheckSocket *netWorkCheckSocket;

+ (BBANetworkManager *)sharedInstance;

- (void)startDetectNetwork;     		// 开始监听网络
- (void)stopDetectNetwork;      	// 停止网络监听
- (BOOL)checkCurrentNetwork;    	// 获取当前网络状态
- (BOOL)isNeedAlertHint;        		// 判断是否需要提示错误信息, 需要返回YES
- (void)alertNetWorkBadHint;    	// 生成网络未连接弹出和显示
- (BOOL)detectSynchronization:(BOOL)aConnRequired;          // 同步方法获取网络状态

// --获得当前网络类型
- (BOOL)isWifiNetwork;
- (BOOL)isWWANNetwork;

// --网络请求，指定请求类型
- (void)startNetRequest:(enum TNetRequestType)aNetRequestType object:(id)aObject;
- (void)endNetRequest:(enum TNetRequestType)aNetRequestType object:(id)aObject;

@end // BBANetworkManager
