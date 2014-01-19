//
//  BBANetWorkCheckSocket.h
//  BaiduBoxApp
//
//  Created by houshaolong on 7/11/11.
//  Copyright 2011 Baidu Inc. All rights reserved.
//

// 头文件
#import <Foundation/Foundation.h>
#import <sys/socket.h>

// 前向声明
@protocol BBANetWorkCheckDelegate;

// @class - BBANetWorkCheckSocket
// @brief - 网络未连接状态测试类,但网络状态为WC时,也就是有信号,但没有连接时测试真正网络状态
@interface BBANetWorkCheckSocket : NSObject <NSStreamDelegate> 

// 属性
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, assign) id<BBANetWorkCheckDelegate> delegate;
@property (nonatomic, retain) NSTimer *overtimeTimer;
@property (nonatomic) double overtimeInterval;

- (void)createSocketStreamWithURLString:(NSString *)aURLString;
- (void)close; // 关闭socket

@end // BBANetWorkCheckSocket


// @protocol - NetWorkCheckDelegate
// @brief - NetWorkCheck相关回调
@protocol BBANetWorkCheckDelegate <NSObject>
@optional
- (void)netWorkCheckSocketErr:(BBANetWorkCheckSocket *)aSocket;
- (void)netWorkCheckSocketDidConnnect:(BBANetWorkCheckSocket *)aSocket;
- (void)netWorkCheckSocketOvertime:(BBANetWorkCheckSocket *)aSocket;

@end // NetWorkCheckDelegate
