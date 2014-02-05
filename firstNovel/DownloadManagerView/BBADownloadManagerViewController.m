//
//  BBADownloadManagerViewController.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadManagerViewController.h"
#import "BBADownloadItemCell.h"
#import "BBADownloadItem.h"
#import "BBADownloadDataSource.h"
#import "BBACommonDownloadTask.h"
#import "CKCommonUtility.h"
#import "CKRootViewController.h"

// 宏定义

#define DM_TITLE_BAR_HEIGHT (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0)?64.0f:0.0f)
#define DM_TABLE_HEADER_HEIGHT     200.0f
#define DM_TABLE_HEIGHT    (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0)?(APPLICATION_FRAME_HEIGHT - DM_TITLE_BAR_HEIGHT - DOWNLOAD_TABLE_BOTTOM_MARGIN):(APPLICATION_FRAME_HEIGHT - 44.0f - DOWNLOAD_TABLE_BOTTOM_MARGIN))

#define DOWNLOAD_TABLE_BOTTOM_MARGIN    20.0f

@interface BBADownloadManagerViewController ()

@property (nonatomic, retain) UITableView *downloadTable;
@property (nonatomic, retain) UILabel *emptyView;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) WKReaderViewController *novelReaderViewController;

@end

@implementation BBADownloadManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [BBADownloadDataSource sharedInstance].delegate = nil;
    NSArray *downloadList = [BBADownloadDataSource sharedInstance].downloadList;
    for (BBADownloadItem *item in downloadList)
    {
        item.viewDelegate = nil;
    }
    
    _downloadTable.delegate = nil;
    _downloadTable.dataSource = nil;
    RELEASE_SET_NIL(_emptyView);
    RELEASE_SET_NIL(_backButton);
    RELEASE_SET_NIL(_novelReaderViewController);
    
    
    [super dealloc];
}

#pragma mark - reset datasource delegate

- (void)resignDataSourceDelegate
{
    [BBADownloadDataSource sharedInstance].delegate = nil;
    NSArray *downloadList = [BBADownloadDataSource sharedInstance].downloadList;
    for (BBADownloadItem *item in downloadList)
    {
        item.viewDelegate = nil;
    }
}

#pragma mark - View lifestyle

- (void)loadView
{
	[super loadView];

    self.navigationItem.title = @"随时看";
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
	// frame
	CGSize applicationSize = [CKCommonUtility getApplicationSize];
	self.view.frame = CGRectMake(0.0f, 0.0f, applicationSize.width, applicationSize.height);
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
	// table
	UITableView *tmpTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, DM_TITLE_BAR_HEIGHT, self.view.frame.size.width, DM_TABLE_HEIGHT) style:UITableViewStylePlain];
	self.downloadTable = tmpTable;
	RELEASE_SET_NIL(tmpTable);
	[self.view addSubview:_downloadTable];
	_downloadTable.dataSource = self;
	_downloadTable.delegate = self;
    _downloadTable.allowsSelection = YES;
    _downloadTable.allowsSelectionDuringEditing = NO;
    _downloadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _downloadTable.backgroundColor = [UIColor clearColor];
    
    //添加footerview隐藏多余分割线
    UIView *tmpFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _downloadTable.frame.size.width, 0.0f)];
    self.downloadTable.tableFooterView = tmpFooterView;
    tmpFooterView.backgroundColor = [UIColor clearColor];
	RELEASE_SET_NIL(tmpFooterView);
    
    // 无下载内容提示文字Label
    CGRect labelFrame = CGRectMake(30.0f, 240.0f, 260.0f, 70.0f);  // 添加在_emptyView上的Frame.
    _emptyView = [[UILabel alloc] initWithFrame:labelFrame];
    _emptyView.numberOfLines = 3;
    _emptyView.text = @"还没有离线小说哦~赶紧去书城看看吧~我们推荐把小说离线以后再阅读,体验会更佳~";
    _emptyView.font = [UIFont systemFontOfSize:16.0f];
    _emptyView.textColor = [CKCommonUtility RGBColorFromHexString:@"#666666" alpha:1.0f];
    _emptyView.backgroundColor = [UIColor clearColor];
    _emptyView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_emptyView];
    
    [BBADownloadDataSource sharedInstance].delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[BBADownloadDataSource sharedInstance] totalCount] == 0)
    {
        _downloadTable.hidden = YES;
        _emptyView.hidden = NO;
    }
    else
    {
        _downloadTable.hidden = NO;
        _emptyView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES; 	// 取消自动锁屏
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO; //  支持自动锁屏
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)backAction:(id)sender
{
    [self resignDataSourceDelegate];
    [self.navigationController popViewControllerAnimated:YES];
}

// 编辑
- (void)editAction:(id)sender
{
    if (!_downloadTable.editing && [BBADownloadDataSource sharedInstance].totalCount > 0)
    {
        _backButton.hidden = YES;
        [_downloadTable setEditing:YES animated:YES];
        [_downloadTable reloadData];
    }
    else
    {
        _backButton.hidden = NO;
        [_downloadTable setEditing:NO animated:YES];
        [_downloadTable reloadData];
    }
}

#pragma mark - table delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBADownloadItem *item = [[BBADownloadDataSource sharedInstance].downloadList objectAtIndex:indexPath.row];
    if (item == nil) return nil;
    
    BBADownloadItemCell *cell = [[[BBADownloadItemCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil] autorelease];
    [cell drawCellWithItem:item];
    cell.dataSource = item; // cell的数据来源
    cell.actionDelegate = self; // cell各按钮的响应代理
    item.viewDelegate = cell; // 下载项数据的视图代理
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_downloadTable.editing)
    {
        cell.actionButton.hidden = YES;
    }
    else
    {
        cell.actionButton.hidden = NO;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [BBADownloadDataSource sharedInstance].downloadList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DOWNLOADCELL_HEIGHT;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BBADownloadItemCell *deleteCell = (BBADownloadItemCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (deleteCell != nil)
        {
            NSString *taskID = [deleteCell.dataSource.taskID retain];
            deleteCell.dataSource = nil;
            [[BBADownloadDataSource sharedInstance] removeDownloadItem:taskID];
			RELEASE_SET_NIL(taskID);
            NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            NSArray *theIndex = [[[NSArray alloc] initWithObjects:tempIndex, nil] autorelease];
            [tableView deleteRowsAtIndexPaths:theIndex withRowAnimation:UITableViewRowAnimationFade];
            if ([[BBADownloadDataSource sharedInstance] totalCount] == 0)
            {
                _downloadTable.hidden = YES;
                _emptyView.hidden = NO;
            }
            else
            {
                _downloadTable.hidden = NO;
                _emptyView.hidden = YES;
            }
            if ([BBADownloadDataSource sharedInstance].totalCount == 0)
            {
                [self editAction:nil];
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        // 避免删除按钮遮挡
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        BBADownloadItemCell *cell = (BBADownloadItemCell *)[tableView cellForRowAtIndexPath:path];
        cell.actionButton.hidden = YES;
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        [_downloadTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBADownloadItemCell *cell = (BBADownloadItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        if (cell.status == EDownloadTaskStatusRunning || cell.status == EDownloadTaskStatusWaiting)
        {
            [self stop:cell.dataSource.taskID];
        }
        else if (cell.status == EDownloadTaskStatusSuspend)
        {
            [self resume:cell.dataSource.taskID];
        }
        else if (cell.status == EDownloadTaskStatusFailed)
        {
            [self retry:cell.dataSource.taskID];
        }
        else if (cell.status == EDownloadTaskStatusFinished)
        {
            [self play:cell.dataSource.taskID];
        }
        
        if (cell.dataSource.needShownNew == YES)
        {
            cell.dataSource.needShownNew = NO;
            dispatch_async(GCD_GLOBAL_QUEUQ, ^{
                [[BBADownloadDataSource sharedInstance] saveDowloadlist];
            });
            NSIndexPath *currentPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:currentPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)updateDownloadList:(NSArray *)downloadList
{
    for (BBADownloadItem *item in downloadList)
    {
        // 在downloadList数量发生时重置各viewDelegate，避免发生多对一的情况
        item.viewDelegate = nil;
    }
    [_downloadTable reloadData];
}

#pragma mark - cell delegate

- (void)stop:(NSString *)taskID
{
    [[BBADownloadDataSource sharedInstance] stopDownloadItem:taskID];
}

- (void)resume:(NSString *)taskID
{
    [[BBADownloadDataSource sharedInstance] resumeDownloadItem:taskID];
}

- (void)play:(NSString *)taskID
{
    if (CHECK_STRING_INVALID(taskID)) return;
    
    [_downloadTable setEditing:NO];
    
    BBADownloadItem *item = [[BBADownloadDataSource sharedInstance] downloadItemByID:taskID];
    if (CHECK_STRING_INVALID(item.playurl)) return;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:item.playurl])
    {
        [self showNoFileAlert];
        return;
    }
    
    // 置为已读
    if (item.needShownNew == YES)
    {
        item.needShownNew = NO;
        dispatch_async(GCD_GLOBAL_QUEUQ, ^{
            [[BBADownloadDataSource sharedInstance] saveDowloadlist];
        });
        dispatch_async(dispatch_get_current_queue(), ^{
            
            NSUInteger indexPath = [[BBADownloadDataSource sharedInstance].downloadList indexOfObject:item];
            if (indexPath < [[BBADownloadDataSource sharedInstance].downloadList count])
            {
                NSIndexPath *currentPath = [NSIndexPath indexPathForRow:indexPath inSection:0];
                [_downloadTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:currentPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
    
    if (item.businessType == EDownloadBusinessTypeNovel)
    {
        // 如果是小说，则调起来小说阅读器
        if ([[NSFileManager defaultManager] fileExistsAtPath:item.playurl])
        {
            NSString *novelFileName = item.title; // 用于阅读时显示标题，所以优先选择title
            
            if (CHECK_STRING_INVALID(novelFileName))
            {
                novelFileName = item.fileName;
            }
            
            if (CHECK_STRING_INVALID(novelFileName))
            {
                novelFileName = @"无标题";
            }
            
            self.novelReaderViewController = [WKReaderSwitch openBookWithFile:item.playurl fileName:novelFileName fileType:@"txt" pushAnimation:NO];
            _novelReaderViewController.readerViewControllerDelegate = self;
            [[CKRootViewController sharedInstance] presentViewController:_novelReaderViewController animated:YES completion:nil];
            
            return;
        }

    }
}

- (void)retry:(NSString *)taskID
{
    [[BBADownloadDataSource sharedInstance] retryDownloadItem:taskID];
}

- (void)showNoFileAlert
{
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:@"很抱歉,小说文件没有找到,你还是重新再下载一次吧!" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
    [view show];
    [view release];
}

- (void)wkReaderViewController:(WKReaderViewController *)readerViewController backAtPercentage:(CGFloat)percentage
{
    [_novelReaderViewController dismissViewControllerAnimated:YES completion:nil];
    self.novelReaderViewController = nil;
}

@end // BBADownloadManagerViewController
