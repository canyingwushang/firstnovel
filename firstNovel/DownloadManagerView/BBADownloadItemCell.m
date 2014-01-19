//
//  BBADownloadItemCell.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadItemCell.h"
#import "BBADownloadItem.h"
#import "CKCommonUtility.h"

// 宏定义
#define DOWNLOADCELL_LEFTMARGIN 12.0f
#define DOWNLOADCELL_TOP_MARGIN 18.0f

#define DOWNLOADCELL_NEWCELL_WIDTH  18.0f

#define DOWNLOADCELL_FILETYPE_BUTTONICON_HEIGHT     18.0f
#define DOWNLOADCELL_FILETYPE_BUTTONICON_WIDTH      18.0f
#define DOWNLOADCELL_TITLE_LEFT_MARGIN  3.0f
#define DOWNLOADCELL_TITLE_HEIGHT           16.0f
#define DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN (DOWNLOADCELL_TOP_MARGIN + DOWNLOADCELL_TITLE_HEIGHT + 5.0f + 11.0f)
#define DOWNLOADCELL_PROGRESSBAR_WIDTH  162.0f
#define DOWNLOADCELL_PROGRESSBAR_HEIGHT 8.0f
#define DOWNLOADCELL_PROGRESSBAR_HEIGHT_IOS7 2.0f
#define DOWNLOADCELL_SIZELABEL_HEIGHT 10.0f
#define DOWNLOADCELL_SIZEDURLABEL_HEIGHT 11.0f

#define DOWNLOADCELL_SIZELABEL_WIDTH 44.0f

#define DOWNLOADCELL_ACTIONBUTTON_WIDTH 50.0f
#define DOWNLOADCELL_ACTIONBUTTON_HEIGHT 32.0f



@interface BBADownloadItemCell ()

@end

@interface BBADownloadItemCell ()

@property (nonatomic, retain) UIImageView *fileTypeImage;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIProgressView *progressBar;
@property (nonatomic, retain) UILabel *sizeDurLabel;
@property (nonatomic, retain) UILabel *failedLabel;
@property (nonatomic, retain) UILabel *downloadSizeLabel;
@property (nonatomic, retain) UILabel *totalSizeLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UILabel *retryLabel;
@property (nonatomic, retain) UILabel *waitingLabel;

@end

@implementation BBADownloadItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    _dataSource.viewDelegate = nil;
	RELEASE_SET_NIL(_fileTypeImage);
    RELEASE_SET_NIL(_titleLabel);
    RELEASE_SET_NIL(_progressBar);
    RELEASE_SET_NIL(_sizeDurLabel);
    RELEASE_SET_NIL(_failedLabel);
    RELEASE_SET_NIL(_actionButton);
    RELEASE_SET_NIL(_downloadSizeLabel);
    RELEASE_SET_NIL(_totalSizeLabel);
    RELEASE_SET_NIL(_waitingLabel);
    RELEASE_SET_NIL(_retryLabel);
    RELEASE_SET_NIL(_newPoint);
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateProgress:(CGFloat)progress totalBytes:(long long)totalBytes reveivedBytes:(long long)receivedBytes
{
    [_progressBar setProgress:progress];
    _totalSizeLabel.text = [NSString stringWithFormat:@"/%@", [CKCommonUtility sizeStr:totalBytes]];
    NSString *downloadStr = [CKCommonUtility sizeStr:receivedBytes];
    CGSize downloadSize = [downloadStr sizeWithFont:_downloadSizeLabel.font];
    CGRect downloadRect = _downloadSizeLabel.frame;
    downloadRect.size.width = downloadSize.width;
    _downloadSizeLabel.frame = downloadRect;
    CGRect totalRect = _totalSizeLabel.frame;
    totalRect.origin.x = downloadRect.origin.x + downloadRect.size.width;
    _totalSizeLabel.frame = totalRect;
    _downloadSizeLabel.text = [CKCommonUtility sizeStr:receivedBytes];
    _sizeDurLabel.text = [NSString stringWithFormat:@"%@: %@", @"文件大小",[CKCommonUtility sizeStr:totalBytes]];
}

- (void)setDataSource:(BBADownloadItem *)dataSource
{
    _dataSource.viewDelegate = nil;
    _dataSource = dataSource;
}

- (void)updateNewIcon:(BOOL)show
{
    if (show == YES)
    {
        _newPoint.hidden = NO;
    }
    else
    {
        _newPoint.hidden = YES;
    }
}

- (void)setFileType:(TDownloadBusinessType)type
{
    _type = type;
    if (type == EDownloadBusinessTypeVideo)
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_video.png"]];
    }
    else if (type == EDownloadBusinessTypeNovel)
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_novel.png"]];
    }
    else if (type == EDownloadBusinessTypeMusic)
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_music.png"]];
    }
    else if (type == EDownloadBusinessTypeImage)
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_image.png"]];
    }
    else if (type == EDownloadBusinessTypeText)
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_text.png"]];
    }
    else
    {
        [_fileTypeImage setImage:[UIImage imageNamed:@"dm_icon_others.png"]];
    }
}

- (void)setStatus:(enum TDownloadTaskStatus)status
{
    _status = status;
    [self reCreateActionButton:status];
    if (status == EDownloadTaskStatusWaiting)
    {
        _progressBar.hidden = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_5_0))
        {
            _progressBar.trackImage = [UIImage imageNamed:@"dm_progress_active_background.png"];
            _progressBar.progressImage = [UIImage imageNamed:@"dm_progress_active_foreground.png"];
        }
        _waitingLabel.hidden = NO;
        [self bringSubviewToFront:_waitingLabel];
        _failedLabel.hidden = YES;
        _retryLabel.hidden = YES;
        _sizeDurLabel.hidden = YES;
        _totalSizeLabel.hidden = YES;
        _downloadSizeLabel.hidden = YES;
    }
    else if (status == EDownloadTaskStatusRunning)
    {
        _progressBar.hidden = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_5_0))
        {
            _progressBar.trackImage = [UIImage imageNamed:@"dm_progress_active_background.png"];
            _progressBar.progressImage = [UIImage imageNamed:@"dm_progress_active_foreground.png"];
        }
        _waitingLabel.hidden = YES;
        _failedLabel.hidden = YES;
        _retryLabel.hidden = YES;
        _sizeDurLabel.hidden = YES;
        _totalSizeLabel.hidden = NO;
        _downloadSizeLabel.hidden = NO;
    }
    else if (status == EDownloadTaskStatusFinished)
    {
        _progressBar.hidden = YES;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_5_0))
        {
            _progressBar.trackImage = [UIImage imageNamed:@"dm_progress_active_background.png"];
            _progressBar.progressImage = [UIImage imageNamed:@"dm_progress_active_foreground.png"];
        }
        _waitingLabel.hidden = YES;
        _failedLabel.hidden = YES;
        _retryLabel.hidden = YES;
        _sizeDurLabel.hidden = NO;
        _totalSizeLabel.hidden = YES;
        _downloadSizeLabel.hidden = YES;
    }
    else if (status == EDownloadTaskStatusFailed)
    {
        _progressBar.hidden = YES;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_5_0))
        {
            _progressBar.trackImage = [UIImage imageNamed:@"dm_progress_active_background.png"];
            _progressBar.progressImage = [UIImage imageNamed:@"dm_progress_active_foreground.png"];
        }
        _waitingLabel.hidden = YES;
        _failedLabel.hidden = NO;
        _retryLabel.hidden = NO;
        _sizeDurLabel.hidden = YES;
        _totalSizeLabel.hidden = YES;
        _downloadSizeLabel.hidden = YES;
    }
    else if (status == EDownloadTaskStatusSuspend)
    {
        _progressBar.hidden = NO;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_5_0))
        {
            _progressBar.trackImage = [UIImage imageNamed:@"dm_progress_pause_background.png"];
            _progressBar.progressImage = [UIImage imageNamed:@"dm_progress_pause_foreground.png"];
        }
        _waitingLabel.hidden = YES;
        _failedLabel.hidden = YES;
        _retryLabel.hidden = YES;
        _sizeDurLabel.hidden = YES;
        _totalSizeLabel.hidden = NO;
        _downloadSizeLabel.hidden = NO;
    }
    
    if (status == EDownloadTaskStatusFailed)
    {
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_retrybutton_normal.png"] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_retrybutton_highlighted.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_pausebutton_normal.png"] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_pausebutton_highlighted.png"] forState:UIControlStateHighlighted];
    }
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)drawCellWithItem:(BBADownloadItem *)item
{
    // new图标
    _newPoint = [[UIImageView alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN, DOWNLOADCELL_TOP_MARGIN, DOWNLOADCELL_NEWCELL_WIDTH, DOWNLOADCELL_NEWCELL_WIDTH)];
    _newPoint.image = [UIImage imageNamed:@"common_list_new.png"];
    _newPoint.hidden = YES;
    [self.contentView addSubview:_newPoint];
    
    CGFloat leftNewMargin = 0.0f;
    if (item.needShownNew == YES)
    {
        _newPoint.hidden = NO;
        leftNewMargin = DOWNLOADCELL_FILETYPE_BUTTONICON_WIDTH;
    }
    
    // 文件类型：视频和非视频
    if (_fileTypeImage == nil)
    {
        _fileTypeImage = [[UIImageView alloc] init];
        _fileTypeImage.frame = CGRectMake(DOWNLOADCELL_LEFTMARGIN + leftNewMargin, DOWNLOADCELL_TOP_MARGIN, DOWNLOADCELL_FILETYPE_BUTTONICON_WIDTH, DOWNLOADCELL_FILETYPE_BUTTONICON_HEIGHT);
        [self.contentView addSubview:_fileTypeImage];
    }
    
    // 标题
    if (_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN + DOWNLOADCELL_FILETYPE_BUTTONICON_WIDTH + DOWNLOADCELL_TITLE_LEFT_MARGIN + leftNewMargin, DOWNLOADCELL_TOP_MARGIN + 1.0f, 200.0f, DOWNLOADCELL_TITLE_HEIGHT)];
        [_titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [_titleLabel setTextColor:[CKCommonUtility RGBColorFromHexString:@"#222222" alpha:1.0f]];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    
    // 进度条
    if (_progressBar == nil)
    {
        _progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
        {
            _progressBar.frame = CGRectMake(DOWNLOADCELL_LEFTMARGIN, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN + DOWNLOADCELL_PROGRESSBAR_HEIGHT/2, DOWNLOADCELL_PROGRESSBAR_WIDTH, DOWNLOADCELL_PROGRESSBAR_HEIGHT_IOS7);
        }
        else
        {
            _progressBar.frame = CGRectMake(DOWNLOADCELL_LEFTMARGIN, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN, DOWNLOADCELL_PROGRESSBAR_WIDTH, DOWNLOADCELL_PROGRESSBAR_HEIGHT);
        }
        [self.contentView addSubview:_progressBar];
    }
    
    // 时长和大小
    if (_sizeDurLabel == nil)
    {
        _sizeDurLabel = [[UILabel alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN - 5.0f, DOWNLOADCELL_PROGRESSBAR_WIDTH, DOWNLOADCELL_SIZEDURLABEL_HEIGHT)];
        _sizeDurLabel.font = [UIFont systemFontOfSize:11.0f];
        _sizeDurLabel.backgroundColor = [UIColor clearColor];
        _sizeDurLabel.textColor = [CKCommonUtility RGBColorFromHexString:@"#999999" alpha:1.0f];
        [self.contentView addSubview:_sizeDurLabel];
        _sizeDurLabel.text = @"未知大小";
    }
    
    // 下载失败
    if (_failedLabel == nil)
    {
        _failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN, (DOWNLOADCELL_TOP_MARGIN + DOWNLOADCELL_FILETYPE_BUTTONICON_HEIGHT + 5.0f), 48.0f, 15.0f)];
        _failedLabel.font = [UIFont systemFontOfSize:11.0f];
        _failedLabel.textColor = [UIColor whiteColor];
        _failedLabel.backgroundColor = [CKCommonUtility RGBColorFromHexString:@"#ff4900" alpha:1.0f];
        _failedLabel.text = @"下载失败";
        [self.contentView addSubview:_failedLabel];
    }
    
    // 点击重试
    if (_retryLabel == nil)
    {
        _retryLabel = [[UILabel alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN + 50.0f, (DOWNLOADCELL_TOP_MARGIN + DOWNLOADCELL_FILETYPE_BUTTONICON_HEIGHT + 5.0f), 48.0f, 15.0f)];
        _retryLabel.font = [UIFont systemFontOfSize:11.0f];
        _retryLabel.textColor = [CKCommonUtility RGBColorFromHexString:@"#999999" alpha:1.0f];
        _retryLabel.backgroundColor = [UIColor clearColor];
        _retryLabel.text = @"重试";
        [self.contentView addSubview:_retryLabel];
    }
    
    // 已下载大小
    if (_downloadSizeLabel == nil)
    {
        _downloadSizeLabel = [[UILabel alloc] init];
        _downloadSizeLabel.font = [UIFont systemFontOfSize:10.0f];
        _downloadSizeLabel.textColor = [CKCommonUtility RGBColorFromHexString:@"#288c37" alpha:1.0f];
        _downloadSizeLabel.textAlignment = NSTextAlignmentLeft;
        _downloadSizeLabel.frame = CGRectMake(DOWNLOADCELL_LEFTMARGIN + DOWNLOADCELL_PROGRESSBAR_WIDTH + 4.0f, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN, DOWNLOADCELL_SIZELABEL_WIDTH, DOWNLOADCELL_SIZELABEL_HEIGHT);
        _downloadSizeLabel.backgroundColor = [UIColor clearColor];
        _downloadSizeLabel.text = @"未知";
        [self.contentView addSubview:_downloadSizeLabel];
    }
    
    // 总大小
    if (_totalSizeLabel == nil)
    {
        _totalSizeLabel = [[UILabel alloc] init];
        _totalSizeLabel.font = [UIFont systemFontOfSize:10.0f];
        _totalSizeLabel.textColor = [CKCommonUtility RGBColorFromHexString:@"#555555" alpha:1.0f];
        _totalSizeLabel.textAlignment = NSTextAlignmentLeft;
        _totalSizeLabel.frame = CGRectMake(DOWNLOADCELL_LEFTMARGIN + DOWNLOADCELL_PROGRESSBAR_WIDTH + 2.0f + DOWNLOADCELL_SIZELABEL_WIDTH, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN , DOWNLOADCELL_SIZELABEL_WIDTH, DOWNLOADCELL_SIZELABEL_HEIGHT);
        _totalSizeLabel.backgroundColor = [UIColor clearColor];
        _totalSizeLabel.text = [NSString stringWithFormat:@"/%@", @"未知", nil];
        [self.contentView addSubview:_totalSizeLabel];
    }
    
    //等待标签
    if (_waitingLabel == nil)
    {
        _waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(DOWNLOADCELL_LEFTMARGIN + DOWNLOADCELL_PROGRESSBAR_WIDTH + 6.0f, DOWNLOADCELL_PROGRESSBAR_TOP_MARGIN, 50.0f, 10.0f)];
        _waitingLabel.font = [UIFont systemFontOfSize:10.0f];
        _waitingLabel.textColor = [CKCommonUtility RGBColorFromHexString:@"#999999" alpha:1.0f];
        _waitingLabel.text = @"等待中";
        _waitingLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_waitingLabel];
    }
    [self updateProgress:item.progress totalBytes:item.totalBytes reveivedBytes:item.receivedBytes];
    [self setStatus:item.status];
    [self setFileType:item.businessType];
    [self reCreateActionButton:item.status];
    if (item.fileIndex == 0)
    {
        [self setTitle:item.title];
    }
    else
    {
        [self setTitle:[NSString stringWithFormat:@"%@(%d)", item.title, item.fileIndex]];
    }
}

- (void)reCreateActionButton:(enum TDownloadTaskStatus) status
{
    if (_actionButton)
    {
        [_actionButton removeFromSuperview];
        RELEASE_SET_NIL(_actionButton);
    }
    if (_actionButton == nil)
    {
        _actionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _actionButton.frame = CGRectMake(260.0f, (DOWNLOADCELL_HEIGHT - DOWNLOADCELL_ACTIONBUTTON_HEIGHT)/2, DOWNLOADCELL_ACTIONBUTTON_WIDTH, DOWNLOADCELL_ACTIONBUTTON_HEIGHT);
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_pausebutton_normal.png"] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:@"dm_pausebutton_highlighted.png"] forState:UIControlStateHighlighted];
        [_actionButton setTitleColor:[CKCommonUtility RGBColorFromHexString:@"#3497f3" alpha:1.0f] forState:UIControlStateNormal];
        [_actionButton setTitleColor:[CKCommonUtility RGBColorFromHexString:@"#ffffff" alpha:1.0f] forState:UIControlStateHighlighted];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self.contentView addSubview:_actionButton];
    }
    if (status == EDownloadTaskStatusFailed)
    {
        [_actionButton setTitleColor:[CKCommonUtility RGBColorFromHexString:@"#ec3759" alpha:1.0f] forState:UIControlStateNormal];
        [_actionButton setTitle:@"重试" forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (status == EDownloadTaskStatusFinished)
    {
        [_actionButton setTitle:@"阅读" forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (status == EDownloadTaskStatusRunning || status == EDownloadTaskStatusWaiting)
    {
        [_actionButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (status == EDownloadTaskStatusSuspend)
    {
        [_actionButton setTitle:@"继续" forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.editing)
    {
        _actionButton.hidden = YES;
    }
}

#pragma mark - actions

- (void)stop:(id)sender
{
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(stop:)])
    {
        [_actionDelegate stop:_dataSource.taskID];
    }
}

- (void)resume:(id)sender
{
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(resume:)])
    {
        [_actionDelegate resume:_dataSource.taskID];
    }
}

- (void)play:(id)sender
{
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(play:)])
    {
        [_actionDelegate play:_dataSource.taskID];
    }
}

- (void)retry:(id)sender
{
    if (_actionDelegate && [_actionDelegate respondsToSelector:@selector(retry:)])
    {
        [_actionDelegate retry:_dataSource.taskID];
    }
}

@end
