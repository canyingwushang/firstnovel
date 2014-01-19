//
//  BBADownloadItemCell.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBADownloadDataSource.h"

#define DOWNLOADCELL_HEIGHT 70.0f

// @class - BBADownloadItemCellDelegate
// @brief - 下载中心表格按钮代理
@protocol BBADownloadItemCellDelegate <NSObject>

@optional
- (void)stop:(NSString *)taskID;
- (void)resume:(NSString *)taskID;
- (void)play:(NSString *)taskID;
- (void)retry:(NSString *)taskID;

@end

// @class - BBADownloadItemCell
// @brief - 下载中心表格
@interface BBADownloadItemCell : UITableViewCell

@property (nonatomic, assign) enum TDownloadTaskStatus status; // 任务状态
@property (nonatomic, assign) BBADownloadItem *dataSource; // 表格对应的数据源
@property (nonatomic, assign) id<BBADownloadItemCellDelegate> actionDelegate;
@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UIImageView *newPoint;
@property (nonatomic, assign) TDownloadBusinessType type;

- (void)updateProgress:(CGFloat)progress totalBytes:(long long)totalBytes reveivedBytes:(long long)reveivedBytes;
- (void)setFileType:(TDownloadBusinessType)type;
- (void)drawCellWithItem:(BBADownloadItem *)item;

@end // BBADownloadItemCell
