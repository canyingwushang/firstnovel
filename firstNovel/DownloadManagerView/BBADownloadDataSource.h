//
//  BBADownloadDataSource.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBADownloadManager.h"
#import "BBACommonDownloadTask.h"

// 下载的业务类型
typedef enum _DownloadBusinessType
{
    EDownloadBusinessTypeUnkown = 0,
    EDownloadBusinessTypeVideo,             // 视频业务类型
    EDownloadBusinessTypeNovel,             // 小说业务类型
    EDownloadBusinessTypeMusic,             // 音乐业务类型
    EDownloadBusinessTypeImage,             // 图片业务类型
    EDownloadBusinessTypeText,              // 文本业务类型
}TDownloadBusinessType;

@class BBADownloadItem;

// @class - BBADownloadDataSourceDelegate
// @brief - 下载中心任务数据源代理
@protocol BBADownloadDataSourceDelegate <NSObject>

- (void)updateDownloadList:(NSArray *)downloadList; // 更新视图列表

@end

// @class - BBADownloadDataSource
// @brief - 下载中心任务数据源
@interface BBADownloadDataSource : NSObject <BBADownloadManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain, readonly) NSMutableArray *downloadList; //当前下载任务列表
@property (nonatomic, assign) id<BBADownloadDataSourceDelegate> delegate;
@property (nonatomic, assign) NSUInteger unReadTasksCount;

+ (BBADownloadDataSource *)sharedInstance;

- (BOOL)addDownloadItemWithURL:(NSString *)sourceUrl Title:(NSString *)title businessType:(TDownloadBusinessType)aBusinessType; // 添加下载任务，判断网络和磁盘容量，并增加业务类型，支持小说，视频

- (void)removeDownloadItem:(NSString *)aTaskID; // 删除下载任务
- (void)stopDownloadItem:(NSString *)aTaskID; // 暂停下载任务
- (void)retryDownloadItem:(NSString *)aTaskID; // 重试
- (void)resumeDownloadItem:(NSString *)aTaskID; // 恢复下载
- (NSUInteger)totalCount;
- (NSUInteger)unfinishedCount;
- (NSUInteger)unReadTasksCount;
- (BBADownloadItem *)downloadItemByID:(NSString *)taskID; // 获取下载任务信息
- (void)saveDowloadlist;
- (BOOL)shouldShowNewIcon;

@end // BBADownloadDataSource
