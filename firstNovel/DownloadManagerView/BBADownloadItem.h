//
//  BBADownloadItem.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBADownloadDataSource.h"

@class BBADownloadItemCell;

// 宏定义
#define DOWNLOADITEM_KEY_TITILE         @"title"
#define DOWNLOADITEM_KEY_PROGRESS       @"progress"
#define DOWNLOADITEM_KEY_STATUS         @"status"
#define DOWNLOADITEM_KEY_TYPE           @"type"
#define DOWNLOADITEM_KEY_TOTALBYTES     @"totalbytes"
#define DOWNLOADITEM_KEY_RECEIVEDBYTES  @"receivedbytes"
#define DOWNLOADITEM_KEY_TASKID         @"taskid"
#define DOWNLOADITEM_KEY_SOURCEURL      @"sourceurl"
#define DOWNLOADITEM_KEY_PLAYURL        @"playurl"
#define DOWNLOADITEM_KEY_SHOWNNEW       @"needshownnew"
#define DOWNLOADITEM_KEY_BUSINESS_TYPE           @"businesstype"
#define DOWNLOADITEM_KEY_FILENAME       @"filename"
#define DOWNLOADITEM_KEY_FILEINDEX      @"fileindex"

// @class - BBADownloadItem
// @brief - 下载项
@interface BBADownloadItem : NSObject

@property (nonatomic, retain) NSString *title; // 标题
@property (nonatomic, assign) CGFloat progress; // 进度
@property (nonatomic, assign) enum TDownloadTaskStatus status; // 任务状态
@property (nonatomic, assign) long long totalBytes; // 总大小
@property (nonatomic, assign) long long receivedBytes; // 总大小
@property (nonatomic, retain) NSString *taskID;
@property (nonatomic, retain) NSString *sourceURL;
@property (nonatomic, assign) BBADownloadItemCell *viewDelegate; // 视图代理
@property (nonatomic, retain) NSString *playurl; // 可播放展示URL
@property (nonatomic, assign) BOOL needShownNew;
@property (nonatomic, assign) TDownloadBusinessType businessType; // 业务类型
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, assign) NSUInteger fileIndex; // 重复下载任务的编号

- (NSDictionary *)descriptionDict; // 返回描述字典, 序列化使用
- (void)updateProgress:(CGFloat)progress totalBytes:(long long)totalBytes receivedBytes:(long long)receivedBytes;
@end
