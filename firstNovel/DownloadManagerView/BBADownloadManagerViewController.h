//
//  BBADownloadManagerViewController.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadDataSource.h"
#import "BBADownloadItemCell.h"
#import "WKReaderSwitch.h"

// @class - BBADownloadManagerViewController
// @brief - 下载中心主界面
@interface BBADownloadManagerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, BBADownloadDataSourceDelegate, BBADownloadItemCellDelegate, WKReaderViewControllerDelegate>

@property (nonatomic, retain) UITableView *bookShelfTable;

@end // BBADownloadManagerViewController
