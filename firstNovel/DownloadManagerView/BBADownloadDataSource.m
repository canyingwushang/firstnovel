//
//  BBADownloadDataSource.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadDataSource.h"
#import "BBADownloadItem.h"
#import "BBADownloadManager.h"
#import "Reachability.h"
#import "BBANetworkManager.h"
#import "CKCommonUtility.h"
#import "CKFileManager.h"


#define ALERT_TAG_CHANHE_WWAN       1000000
#define ALERT_TAG_CURRENT_WWAN      1000001
#define ALERT_TAG_DUPDOWNLOAD       1000002

// 宏定义
#define AVAIABLE_DISK_SIZE_MUST_MUCHMORE    500.0f  // 可用空间下限 (MB)

#define DOWNLOAD_VIDEO_BUTTON_FRAME                     CGRectMake([BBACommonUtility getApplicationSize].width - 21.0f - 45.0f, [BBACommonUtility getApplicationSize].height - 65.0f - 45.0f, 45.0f, 45.0f)

@interface BBADownloadDataSource ()

@property (nonatomic, retain) NSMutableDictionary *downloadListDict; // 下载任务列表(Key:taskID)
@property (nonatomic, retain) NSMutableArray *downloadList; // 下载任务列表

@property (nonatomic, retain) NSString *cacheUrl; // 移动网络提示时暂存下载任务url
@property (nonatomic, retain) NSString *cacheTitle;
@property (nonatomic) TDownloadBusinessType cacheBusinessType; // 下载业务类型
@property (nonatomic) BOOL cacheAnimationed; // 下载业务类型

@end

@implementation BBADownloadDataSource

#pragma mark - init & dealloc

+ (BBADownloadDataSource *)sharedInstance
{
	static BBADownloadDataSource *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[BBADownloadDataSource alloc] init];
	}
	
	return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _downloadListDict = [[NSMutableDictionary alloc] init];
        _downloadList = [[NSMutableArray alloc] init];
        
        [BBADownloadManager sharedInstance].delegate = self; // 关联下载中心
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(saveDowloadlist) name: UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self loadDownloadList];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
	RELEASE_SET_NIL(_cacheTitle);
    RELEASE_SET_NIL(_cacheUrl);
    RELEASE_SET_NIL(_downloadList);
    RELEASE_SET_NIL(_downloadListDict);
    
    [super dealloc];
}

#pragma mark - BBADownloadItem actions

- (NSUInteger)totalCount
{
    return _downloadList.count;
}

- (NSUInteger)unReadTasksCount
{
    @synchronized(self)
    {
        int count = 0;
        for (BBADownloadItem *item in _downloadList)
        {
            if (item.status == EDownloadTaskStatusFinished && item.needShownNew)
            {
                count++;
            }
        }
        return count;
    }
}

- (NSUInteger)unfinishedCount
{
    @synchronized(self)
    {
        int count = 0;
        for (BBADownloadItem *item in _downloadList)
        {
            if (item.status == EDownloadTaskStatusFinished)
            {
                count++;
            }
        }
        return _downloadList.count - count;
    }
}

- (BOOL)shouldShowNewIcon
{
    @synchronized(self)
    {
        for (BBADownloadItem *item in _downloadList)
        {
            if (item.needShownNew)
            {
                return YES;
            }
        }
        return NO;
    }
}

- (BBADownloadItem *)downloadItemByID:(NSString *)taskID
{
    if (CHECK_STRING_INVALID(taskID)) return nil;
    return [[[_downloadListDict objectForKey:taskID] retain] autorelease];
}

- (void)addDownloadItem:(BBADownloadItem *)aItem
{
    if ([_downloadListDict objectForKey:aItem.taskID] != nil) return;
    @synchronized(self)
    {
        aItem.status = EDownloadTaskStatusWaiting;
        
        [_downloadList insertObject:aItem atIndex:0];
        DICTIONARY_SET_OBJECT_FOR_KEY(_downloadListDict, aItem, aItem.taskID);
    }
    [[BBADownloadManager sharedInstance] addTask:aItem.sourceURL fileIndex:aItem.fileIndex];
    // 更新下载中心视图列表
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

- (BOOL)addDownloadItemWithURL:(NSString *)sourceUrl Title:(NSString *)title businessType:(TDownloadBusinessType)aBusinessType animationed:(BOOL)aAnimationed
{
    NSString *aSourceUrl = [sourceUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // 参数错误
    if (CHECK_STRING_INVALID(aSourceUrl) || CHECK_STRING_INVALID(title))
    {
        [self downloadParamErrorAlert];
        return NO;
    }
    
    // 未完成的任务不允许重复添加下载任务
    BBADownloadItem *dupItem = [_downloadListDict objectForKey:[CKCommonUtility md5:aSourceUrl]];
    if (dupItem != nil && dupItem.status != EDownloadTaskStatusFinished)
    {
        [self duplicateDownloadAlert];
        return NO;
    }
    
    // 检查网络链接
    if (![[BBANetworkManager sharedInstance] checkCurrentNetwork] || (![[BBANetworkManager sharedInstance] isWifiNetwork] && ![[BBANetworkManager sharedInstance] isWWANNetwork]))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BBANetworkManager sharedInstance] alertNetWorkBadHint];
        });
        return NO;
    }
    
    // 磁盘剩余容量
    if ([CKCommonUtility avaiableDiskStorage] < AVAIABLE_DISK_SIZE_MUST_MUCHMORE)
    {
        [self storageAlert];
        return NO;
    }
    
    // wifi网络检查
    if (![[BBANetworkManager sharedInstance] isWifiNetwork])
    {
        self.cacheTitle = title;
        self.cacheUrl = sourceUrl;
        self.cacheBusinessType = aBusinessType;
        self.cacheAnimationed = aAnimationed;
        [self WWANAlert];
        return NO;
    }
    
    return [self addDownloadItemWithURLDirectly:sourceUrl Title:title businessType:aBusinessType];
}

- (BOOL)addDownloadItemWithURLDirectly:(NSString *)sourceUrl Title:(NSString *)title
{
    return [self addDownloadItemWithURLDirectly:sourceUrl Title:title businessType:EDownloadBusinessTypeUnkown];
}

- (BOOL)addDownloadItemWithURLDirectly:(NSString *)sourceUrl Title:(NSString *)title businessType:(TDownloadBusinessType)aBusinessType
{
    int fileIndex = 0;
    // 计算重复下载任务的文件序列
    BBADownloadItem *dupItem = [_downloadListDict objectForKey:[CKCommonUtility md5:sourceUrl]];
    if (dupItem != nil)
    {
        int startIndex = 1;
        for (; startIndex < 100; startIndex++)
        {
            BBADownloadItem *dupItem = [_downloadListDict objectForKey:[NSString stringWithFormat:@"%@%d", [CKCommonUtility md5:sourceUrl], startIndex]];
            if (dupItem == nil) break;
        }
        fileIndex = startIndex;
    }
    
    NSString *taskID = nil;
    if (fileIndex == 0)
    {
        taskID = [CKCommonUtility md5:sourceUrl];
    }
    else
    {
        taskID = [NSString stringWithFormat:@"%@%d", [CKCommonUtility md5:sourceUrl], fileIndex];
    }
    
    BBADownloadItem *tmpItem = [[[BBADownloadItem alloc] init] autorelease];
    tmpItem.title = title;
    tmpItem.sourceURL = sourceUrl;
    tmpItem.taskID = taskID;
    tmpItem.status = EDownloadTaskStatusWaiting;
    tmpItem.progress = 0.0f;
    tmpItem.totalBytes = 0;
    tmpItem.receivedBytes = 0;
    tmpItem.viewDelegate = nil;
    tmpItem.businessType = aBusinessType;
    tmpItem.fileIndex = fileIndex;
    [[BBADownloadDataSource sharedInstance] addDownloadItem:tmpItem];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    
    return YES;
}

- (void)removeDownloadItem:(NSString *)aTaskID
{
    if (CHECK_STRING_INVALID(aTaskID)) return;
    [[NSFileManager defaultManager] removeItemAtPath:[[[CKFileManager sharedInstance] getDownloadCacheDirForNovel] stringByAppendingPathComponent:aTaskID] error:nil];
    [[BBADownloadManager sharedInstance] removeTask:aTaskID];
    @synchronized(self)
    {
        BBADownloadItem *item = [_downloadListDict objectForKey:aTaskID];
        item.viewDelegate = nil;
        if (item != nil)
        {
            [_downloadListDict removeObjectForKey:aTaskID];
            [_downloadList removeObject:item];
            dispatch_async(GCD_GLOBAL_QUEUQ, ^{
                [self saveDowloadlist];
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

- (void)stopAll
{
    @synchronized(self)
    {
        for (BBADownloadItem *item in _downloadList)
        {
            if (item != nil && item.status != EDownloadTaskStatusFinished)
            {
                item.status = EDownloadTaskStatusSuspend;
            }
        }
    }
    [[BBADownloadManager sharedInstance] stopAllTask];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

- (void)startAll
{
    // 检查网络链接
    if (![[BBANetworkManager sharedInstance] checkCurrentNetwork] || (![[BBANetworkManager sharedInstance] isWifiNetwork] && ![[BBANetworkManager sharedInstance] isWWANNetwork]))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BBANetworkManager sharedInstance] alertNetWorkBadHint];
        });
        return;
    }
    
    if ([CKCommonUtility avaiableDiskStorage] < AVAIABLE_DISK_SIZE_MUST_MUCHMORE)
    {
        [self storageAlert];
        return;
    }
    if (![[BBANetworkManager sharedInstance] isWifiNetwork])
    {
        [self WWANAlert];
        return;
    }
    [self startAllTasks];
}

- (void)startAllTasks
{
    @synchronized(self)
    {
        for (BBADownloadItem *item in _downloadList)
        {
            if (item != nil && (item.status == EDownloadTaskStatusSuspend || item.status == EDownloadTaskStatusRunning))
            {
                item.status = EDownloadTaskStatusWaiting;
            }
        }
    }
    [[BBADownloadManager sharedInstance] startAllTask];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}


- (void)stopDownloadItem:(NSString *)aTaskID
{
    if (CHECK_STRING_INVALID(aTaskID)) return;
    @synchronized(self)
    {
        BBADownloadItem *item = [_downloadListDict objectForKey:aTaskID];
        if (item != nil && (item.status == EDownloadTaskStatusRunning || item.status == EDownloadTaskStatusWaiting))
        {
            item.status = EDownloadTaskStatusSuspend;
        }
    }
    [[BBADownloadManager sharedInstance] stopTask:aTaskID];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

- (void)retryDownloadItem:(NSString *)aTaskID
{
    // 检查网络链接
    if (![[BBANetworkManager sharedInstance] checkCurrentNetwork] || (![[BBANetworkManager sharedInstance] isWifiNetwork] && ![[BBANetworkManager sharedInstance] isWWANNetwork]))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BBANetworkManager sharedInstance] alertNetWorkBadHint];
        });
        return;
    }
    
    if ([CKCommonUtility avaiableDiskStorage] < AVAIABLE_DISK_SIZE_MUST_MUCHMORE)
    {
        [self storageAlert];
        return;
    }
    if (![[BBANetworkManager sharedInstance] isWifiNetwork])
    {
        [self WWANAlert];
        return;
    }
    
    if (CHECK_STRING_INVALID(aTaskID)) return;
    
    @synchronized(self)
    {
        BBADownloadItem *item = [_downloadListDict objectForKey:aTaskID];
        if (item != nil)
        {
            item.status = EDownloadTaskStatusWaiting;
        }
    }
    [[BBADownloadManager sharedInstance] retryTask:aTaskID];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

- (void)resumeDownloadItem:(NSString *)aTaskID
{
    // 检查网络链接
    if (![[BBANetworkManager sharedInstance] checkCurrentNetwork] || (![[BBANetworkManager sharedInstance] isWifiNetwork] && ![[BBANetworkManager sharedInstance] isWWANNetwork]))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BBANetworkManager sharedInstance] alertNetWorkBadHint];
        });
        return;
    }
    
    if ([CKCommonUtility avaiableDiskStorage] < AVAIABLE_DISK_SIZE_MUST_MUCHMORE)
    {
        [self storageAlert];
        return;
    }
    if (![[BBANetworkManager sharedInstance] isWifiNetwork])
    {
        [self WWANAlert];
        return;
    }
    
    if (CHECK_STRING_INVALID(aTaskID)) return;

    @synchronized(self)
    {
        BBADownloadItem *item = [_downloadListDict objectForKey:aTaskID];
        if (item != nil)
        {
            item.status = EDownloadTaskStatusWaiting;
        }
    }
    [[BBADownloadManager sharedInstance] resumeTask:aTaskID];
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
        {
            [_delegate updateDownloadList:self.downloadList];
        }
    });
}

#pragma mark - download manager delegate

- (void)taskStarted:(BBACommonDownloadTask *)aTask
{
    NSString *taskid = aTask.taskID;
    if (CHECK_STRING_INVALID(taskid)) return;
    BBADownloadItem *item = [_downloadListDict objectForKey:taskid];
    if (item != nil)
    {
        item.status = EDownloadTaskStatusRunning;
        // 当文件类型未指定时则使用程序猜测的类型
        if (item.businessType == EDownloadBusinessTypeUnkown)
        {
            if (aTask.type == EDownloadFileTypeVideo || aTask.type == EDownloadFileTypeTEXTM3U8 || aTask.type == EDownloadFileTypeVideoM3U8)
            {
                item.businessType = EDownloadBusinessTypeVideo;
            }
            else if (aTask.type == EDownloadFileTypeAudioMp3)
            {
                item.businessType = EDownloadBusinessTypeMusic;
            }
            else if (aTask.type == EDownloadFileTypeImage)
            {
                item.businessType = EDownloadBusinessTypeImage;
            }
            else if (aTask.type == EDownloadFileTypeTEXTPLAIN)  // 如果是文本格式，统一使用小说阅读sdk打开
            {
                item.businessType = EDownloadBusinessTypeNovel;
            }
            else
            {
                item.businessType = EDownloadBusinessTypeUnkown;
            }
        }
    }
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
}

- (void)taskFinished:(BBACommonDownloadTask *)aTask
{
    NSString *taskid = aTask.taskID;
    if (CHECK_STRING_INVALID(taskid)) return;
    BBADownloadItem *item = [_downloadListDict objectForKey:taskid];
    if (item != nil)
    {
        item.status = EDownloadTaskStatusFinished;
        item.playurl = aTask.playUrl;
        item.totalBytes = aTask.receivedBytes;
        item.progress = 1.0f;
        item.fileName = aTask.fileName;
        @synchronized(self)
        {
            // 调整下载完成的任务到队伍的末尾
            [_downloadList removeObject:item];
            [_downloadList addObject:item];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self taskFinishedAlert:item.title];
                
                if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadList:)])
                {
                    [_delegate updateDownloadList:self.downloadList];
                }
            });
        }
    }
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
}

- (void)taskFailed:(BBACommonDownloadTask *)aTask
{
    NSString *taskid = aTask.taskID;
    if (CHECK_STRING_INVALID(taskid)) return;
    BBADownloadItem *item = [_downloadListDict objectForKey:taskid];
    if (item != nil)
    {
        item.status = EDownloadTaskStatusFailed;
    }
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [self saveDowloadlist];
    });
}

- (void)taskProgress:(BBACommonDownloadTask *)aTask
{
    NSString *taskid = aTask.taskID;
    if (CHECK_STRING_INVALID(taskid)) return;
    BBADownloadItem *item = [_downloadListDict objectForKey:taskid];
    if (item != nil)
    {
        if (aTask.type == EDownloadFileTypeTEXTM3U8) return;
        if (aTask.type == EDownloadFileTypeVideoM3U8)
        {
            item.totalBytes = 0;
        }
        else
        {
            if (item.totalBytes == 0)
            {
                item.totalBytes = aTask.totalBytes;
            }
        }
        if (item.progress > 0.999999 || item.progress < aTask.progress)
        {
            item.progress = aTask.progress;
        }
        if (item.receivedBytes < aTask.receivedBytes)
        {
            item.receivedBytes = aTask.receivedBytes;
        }
        [item updateProgress:item.progress totalBytes:item.totalBytes receivedBytes:item.receivedBytes];
    }
}

- (void)allTasksFinished
{
    ;
}

- (void)taskStatusChanged:(BBACommonDownloadTask *)aTask
{
    NSString *taskid = aTask.taskID;
    if (CHECK_STRING_INVALID(taskid)) return;
    BBADownloadItem *item = [_downloadListDict objectForKey:taskid];
    if (item != nil)
    {
        item.status = aTask.status;
        [item setStatus:aTask.status];
    }
}

#pragma mark - alerts

// 容量警示
- (void)storageAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"手机容量好像不够了哎!" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
		RELEASE_SET_NIL(alertView);
    });
}

- (void)WWANAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前使用的是移动网络, 你确定要开始下载嘛?" delegate:self cancelButtonTitle:@"必须的" otherButtonTitles:@"那算了", nil];
        alertView.tag = ALERT_TAG_CURRENT_WWAN;
        [alertView show];
		RELEASE_SET_NIL(alertView);
    });
}

- (void)changeToWWANAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前正在使用3G/2G移动网络, 下载已被暂停" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
		RELEASE_SET_NIL(alertView);
    });
}

- (void)reachabilityChanged:(NSNotification *)aNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        Reachability* curReach = [aNotification object];
        if ([curReach currentReachabilityStatus] == kReachableViaWWAN)
        {
            if ([BBADownloadManager sharedInstance].totalTaskCount - [BBADownloadManager sharedInstance].finishedTaskCount > 0 && [[BBADownloadManager sharedInstance] wokingTaskCount] > 0)
            {
                [self stopAll];
                [self changeToWWANAlert];
            }
        }
        else if ([curReach currentReachabilityStatus] == kReachableViaWiFi)
        {
            [self startAll];
        }
    });
}

- (void)downloadParamErrorAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ;
    });
}

- (void)duplicateDownloadAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ;
    });
}

- (void)taskFinishedAlert:(NSString *)title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ;
    });
}

#pragma mark - alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (alertView.tag == ALERT_TAG_CURRENT_WWAN)
        {
            if (CHECK_STRING_VALID(_cacheUrl) && CHECK_STRING_VALID(_cacheTitle))
            {
                [self addDownloadItemWithURLDirectly:_cacheUrl Title:_cacheTitle businessType:_cacheBusinessType];

                self.cacheUrl = nil;
                self.cacheTitle = nil;
                self.cacheAnimationed = NO;
                self.cacheBusinessType = EDownloadBusinessTypeUnkown;
            }
            else
            {
                [self startAllTasks];
            }
        }
    }
}

#pragma mark - Serialization

- (void)saveDowloadlist
{
    @synchronized(self)
    {
        NSMutableArray *downloadList = [NSMutableArray array];
        for (BBADownloadItem *item in _downloadList)
        {
            [downloadList addObject:[item descriptionDict]];
        }
        [downloadList writeToFile:[[CKFileManager sharedInstance] getDownloadListFile] atomically:NO];
    }
}

// 加载本地存储的下载任务列表
- (void)loadDownloadList
{
    NSArray *downloadList = [NSArray arrayWithContentsOfFile:[[CKFileManager sharedInstance] getDownloadListFile]];
    if (downloadList != nil)
    {
        for (NSDictionary *itemDict in downloadList)
        {
            BBADownloadItem *item = [[BBADownloadItem new] autorelease];
            item.taskID = [itemDict objectForKey:DOWNLOADITEM_KEY_TASKID];
            if (CHECK_STRING_INVALID(item.taskID))continue;
            item.title = [itemDict objectForKey:DOWNLOADITEM_KEY_TITILE];
            if (CHECK_STRING_INVALID(item.title))continue;
            item.progress = [[itemDict objectForKey:DOWNLOADITEM_KEY_PROGRESS] floatValue];
            item.status = [[itemDict objectForKey:DOWNLOADITEM_KEY_STATUS] integerValue];
            if ([[itemDict objectForKey:DOWNLOADITEM_KEY_STATUS] integerValue] != EDownloadTaskStatusFinished)
            {
                item.status = EDownloadTaskStatusSuspend;
                dispatch_async(GCD_GLOBAL_QUEUQ, ^{
                    [[BBADownloadManager sharedInstance] addSuspendTask:item.sourceURL fileIndex:item.fileIndex];
                });
            }
            item.totalBytes = [[itemDict objectForKey:DOWNLOADITEM_KEY_TOTALBYTES] longLongValue];
            item.receivedBytes = [[itemDict objectForKey:DOWNLOADITEM_KEY_RECEIVEDBYTES] longLongValue];
            item.sourceURL = [itemDict objectForKey:DOWNLOADITEM_KEY_SOURCEURL];

            NSString *tmpPlayUrl = [itemDict objectForKey:DOWNLOADITEM_KEY_PLAYURL];
            item.playurl = [[CKFileManager sharedInstance].cacheDir stringByAppendingPathComponent:tmpPlayUrl];
            
            item.needShownNew = [[itemDict objectForKey:DOWNLOADITEM_KEY_SHOWNNEW] boolValue];
            id typeObj = [itemDict objectForKey:DOWNLOADITEM_KEY_BUSINESS_TYPE];
            if (typeObj == nil)
            {
                typeObj = [itemDict objectForKey:DOWNLOADITEM_KEY_TYPE];
            }
            item.businessType = [typeObj integerValue];
            item.fileName = [itemDict objectForKey:DOWNLOADITEM_KEY_FILENAME];
            item.fileIndex = [[itemDict objectForKey:DOWNLOADITEM_KEY_FILEINDEX] integerValue];
            [_downloadList addObject:item];
            [_downloadListDict setObject:item forKey:item.taskID];
        }
    }
}

@end
