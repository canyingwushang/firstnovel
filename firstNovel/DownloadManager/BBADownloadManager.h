//
//  BBADownloadManager.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-21.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBACommonDownloadTask.h"

// @protocol - BBADownloadManagerDelegate
// @brief    - 下载中心管理器代理
@protocol BBADownloadManagerDelegate <NSObject>

@optional
- (void)taskStarted:(BBACommonDownloadTask *)aTask;
- (void)taskFinished:(BBACommonDownloadTask *)aTask;
- (void)taskFailed:(BBACommonDownloadTask *)aTask;
- (void)taskProgress:(BBACommonDownloadTask *)aTask;
- (void)allTasksFinished;
- (void)taskStatusChanged:(BBACommonDownloadTask *)aTask;

@end // BBADownloadManagerDelegate

// @class - BBADownloadManager
// @brief - 下载中心管理类
@interface BBADownloadManager : NSObject <BBACommonDownloadTaskDelegate>

@property (nonatomic, assign) NSInteger maxConcurrent; // 最大同步任务数
@property (nonatomic, assign) id<BBADownloadManagerDelegate> delegate;

+ (BBADownloadManager *)sharedInstance;

- (NSString *)addTask:(NSString *)aTaskURL fileIndex:(NSUInteger) fileIndex;
- (NSString *)addSuspendTask:(NSString *)aTaskURL fileIndex:(NSUInteger) fileIndex; // 新建暂停任务
- (void)startAllTask; // 全部启动
- (void)stopAllTask; // 全部暂停
- (void)stopTask:(NSString *)taskID; // 暂停
- (void)resumeTask:(NSString *)taskID;// 恢复
- (void)removeTask:(NSString *)taskID; // 删除
- (void)retryTask:(NSString *)taskID; // 重试
- (NSUInteger)totalTaskCount; // 总任务数
- (NSUInteger)finishedTaskCount; // 已完成任务数
- (NSUInteger)wokingTaskCount;

@end //BBADownloadManager
