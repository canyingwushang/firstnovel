//
//  BBACommonDownloadTask.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-21.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIProgressDelegate.h"
#import "ASIHTTPRequest.h"

@class BBACommonDownloadTask;

// 枚举
enum TDownloadFileType {
    EDownloadFileTypeCommon = 0,
    EDownloadFileTypeVideo,
    EDownloadFileTypeTEXTHTML,
    EDownloadFileTypeTEXTM3U8,
    EDownloadFileTypeTEXTPLAIN,
    EDownloadFileTypeVideoM3U8,
    EDownloadFileTypeAudioMp3,
    EDownloadFileTypeImage
};

enum TDownloadTaskStatus {
    EDownloadTaskStatusWaiting = 0,
    EDownloadTaskStatusRunning,
    EDownloadTaskStatusSuspend,
    EDownloadTaskStatusFailed,
    EDownloadTaskStatusFinished
};

// @protocol - BBACommonDownloadTaskDelegate
// @brief    - 通用下载任务代理
@protocol BBACommonDownloadTaskDelegate <NSObject>

- (void)commonTaskStarted:(BBACommonDownloadTask *)aTask;
- (void)commonTaskFinished:(BBACommonDownloadTask *)aTask;
- (void)commonTaskFailed:(BBACommonDownloadTask *)aTask;
- (void)commonTaskProgress:(BBACommonDownloadTask *)aTask;
- (void)commonTaskStatusChanged:(BBACommonDownloadTask *)aTask;

@end

// @class - BBACommonDownloadTask
// @brief - 通用下载任务（单文件）
@interface BBACommonDownloadTask : NSObject <ASIHTTPRequestDelegate, ASIProgressDelegate, NSCopying>

@property (nonatomic, retain) NSString *taskID;
@property (nonatomic, retain) NSString *downloadDestinationPath; //下载目标文件路径
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) enum TDownloadTaskStatus status;
@property (nonatomic, assign) id<BBACommonDownloadTaskDelegate> delegate;
@property (nonatomic, retain) NSString *sourceURL; // 源地址
@property (nonatomic, assign) enum TDownloadFileType type; // 文件类型
@property (nonatomic, retain) NSString *contentType; // MIME type
@property (nonatomic, assign) long long receivedBytes;
@property (nonatomic, assign) long long totalBytes; // 总大小
@property (nonatomic, retain) NSString *playUrl; // 可播放本地地址
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *redirectURL; // 302跳转链接

- (void)start;
- (void)restart;
- (void)stop;
- (void)clear;

@end // BBACommonDownloadTask
