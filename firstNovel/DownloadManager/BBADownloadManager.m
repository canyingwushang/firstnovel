//
//  BBADownloadManager.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-21.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadManager.h"
#import "CKFileManager.h"
#import "ASIHTTPRequest.h"
#import "CKCommonUtility.h"

@interface BBADownloadManager ()

@property (nonatomic, retain) NSMutableArray *waitingQueue;
@property (nonatomic, retain) NSMutableArray *wokingQueue;
@property (nonatomic, retain) NSMutableArray *finishedQueue;
@property (nonatomic, retain) NSMutableArray *suspendQueue;
@property (nonatomic, retain) NSMutableArray *failedQueue;
@property (nonatomic, assign) NSInteger currentConcurrent;
@property (nonatomic, assign) BOOL allowRunning;

@end

@implementation BBADownloadManager

#pragma mark - init & dealloc

+ (BBADownloadManager *)sharedInstance
{
	static BBADownloadManager *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[BBADownloadManager alloc] init];
	}
	
	return sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        //创建下载中心缓存目录
        NSString *cacheDir = [[CKFileManager sharedInstance] getDownloadCacheDir];
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        _allowRunning = YES;
        _currentConcurrent = 0;
        _maxConcurrent = 1; // 默认最大同步任务数为1
        _waitingQueue = [[NSMutableArray alloc] init];
        _wokingQueue = [[NSMutableArray alloc] init];
        _finishedQueue = [[NSMutableArray alloc] init];
        _suspendQueue = [[NSMutableArray alloc] init];
        _failedQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
	RELEASE_SET_NIL(_waitingQueue);
    RELEASE_SET_NIL(_wokingQueue);
    RELEASE_SET_NIL(_finishedQueue);
    RELEASE_SET_NIL(_failedQueue);
    RELEASE_SET_NIL(_suspendQueue);
    
    [super dealloc];
}

#pragma mark - deal download url

- (NSString *)addTask:(NSString *)aTaskURL fileIndex:(NSUInteger) fileIndex
{
    if (CHECK_STRING_INVALID(aTaskURL)) return nil;
    NSURL *taskURL = [NSURL URLWithString:aTaskURL];
    if (taskURL == nil) return nil;
    BBACommonDownloadTask *newTask = [[[BBACommonDownloadTask alloc] init] autorelease];
    newTask.sourceURL = aTaskURL;
    newTask.delegate = self;
    NSString *taskID = nil;
    if (fileIndex == 0)
    {
        taskID = [CKCommonUtility md5:aTaskURL];
    }
    else
    {
        taskID = [NSString stringWithFormat:@"%@%d", [CKCommonUtility md5:aTaskURL], fileIndex];
    }
    newTask.taskID = taskID;
    [self addNewTask:newTask];
    return newTask.taskID;
}

- (NSString *)addSuspendTask:(NSString *)aTaskURL fileIndex:(NSUInteger) fileIndex
{
    if (CHECK_STRING_INVALID(aTaskURL)) return nil;
    NSURL *taskURL = [NSURL URLWithString:aTaskURL];
    if (taskURL == nil) return nil;
    BBACommonDownloadTask *newTask = [[[BBACommonDownloadTask alloc] init] autorelease];
    newTask.sourceURL = aTaskURL;
    newTask.delegate = self;
    NSString *taskID = nil;
    if (fileIndex == 0)
    {
        taskID = [CKCommonUtility md5:aTaskURL];
    }
    else
    {
        taskID = [NSString stringWithFormat:@"%@%d", [CKCommonUtility md5:aTaskURL], fileIndex];
    }
    newTask.taskID = taskID;
    @synchronized(self)
    {
        [_suspendQueue addObject:newTask];
    }
    return newTask.taskID;
}

- (void)startAllTask
{
    @synchronized(self)
    {
        _allowRunning = YES;
        [_waitingQueue addObjectsFromArray:_suspendQueue];
        [_suspendQueue removeAllObjects];
    }
    [self run];
}

- (void)stopAllTask
{
    @synchronized(self)
    {
        _allowRunning = NO;
        for (BBACommonDownloadTask *task in _wokingQueue)
        {
            [task stop];
        }
        _currentConcurrent = 0;
        [_suspendQueue addObjectsFromArray:_wokingQueue];
        [_wokingQueue removeAllObjects];
    }
}

- (void)resumeTask:(NSString *)taskID
{
    @synchronized(self)
    {
        BBACommonDownloadTask *targetTask = nil;
        for (BBACommonDownloadTask *task in _suspendQueue)
        {
            if ([task.taskID isEqualToString:taskID])
            {
                targetTask = task;
                break;
            }
        }
        if (targetTask != nil)
        {
            [_waitingQueue addObject:targetTask];
            [_suspendQueue removeObject:targetTask];
        }
    }
    [self run];
}

- (void)stopTask:(NSString *)taskID
{
    @synchronized(self)
    {
        BBACommonDownloadTask *targetTask = nil;
        for (BBACommonDownloadTask *task in _wokingQueue)
        {
            if ([task.taskID isEqualToString:taskID])
            {
                targetTask = task;
                break;
            }
        }
        if (targetTask != nil)
        {
            [targetTask stop];
            if ([_suspendQueue indexOfObject:targetTask] == NSNotFound)
            {
                [_suspendQueue addObject:targetTask];
                [_wokingQueue removeObject:targetTask];
                _currentConcurrent--;
            }
        }
        else
        {
            for (BBACommonDownloadTask *task in _waitingQueue)
            {
                if ([task.taskID isEqualToString:taskID])
                {
                    targetTask = task;
                    break;
                }
            }
            if (targetTask != nil)
            {
                [targetTask stop];
                if ([_suspendQueue indexOfObject:targetTask] == NSNotFound)
                {
                    [_suspendQueue addObject:targetTask];
                    [_waitingQueue removeObject:targetTask];
                }
            }
        }
        
    }
    [self run];
}

- (void)removeTask:(NSString *)taskID
{
    [taskID retain];
    @synchronized(self)
    {
        NSMutableArray *totalQueue = [NSMutableArray array];
        [totalQueue addObjectsFromArray:_wokingQueue];
        [totalQueue addObjectsFromArray:_waitingQueue];
        [totalQueue addObjectsFromArray:_finishedQueue];
        [totalQueue addObjectsFromArray:_failedQueue];
        [totalQueue addObjectsFromArray:_suspendQueue];
        
        // 查找id对应的task对象
        BBACommonDownloadTask *targetTask = nil;
        for (BBACommonDownloadTask *task in totalQueue)
        {
            if ([task.taskID isEqualToString:taskID])
            {
                targetTask = task;
                break;
            }
        }
        if (targetTask != nil)
        {
            [targetTask clear];
            if ([_wokingQueue indexOfObject:targetTask] != NSNotFound)
            {
                [_wokingQueue removeObject:targetTask];
                _currentConcurrent--;
            }
            else
            {
                [_waitingQueue removeObject:targetTask];
                [_finishedQueue removeObject:targetTask];
                [_failedQueue removeObject:targetTask];
                [_suspendQueue removeObject:targetTask];
            }
        }
    }
    [self run];
	RELEASE_SET_NIL(taskID);
}

- (void)retryTask:(NSString *)taskID
{
    @synchronized(self)
    {
        BBACommonDownloadTask *targetTask = nil;
        for (BBACommonDownloadTask *task in _failedQueue)
        {
            if ([task.taskID isEqualToString:taskID])
            {
                targetTask = task;
                break;
            }
        }
        if (targetTask != nil)
        {
            [_waitingQueue addObject:targetTask];
            [_failedQueue removeObject:targetTask];
        }
    }
    [self run];
}

- (NSUInteger)totalTaskCount
{
    @synchronized(self)
    {
        return (_wokingQueue.count + _waitingQueue.count + _finishedQueue.count + _failedQueue.count + _suspendQueue.count);
    }
}

- (NSUInteger)finishedTaskCount
{
    @synchronized(self)
    {
        return _finishedQueue.count;
    }
}

- (NSUInteger)wokingTaskCount
{
    @synchronized(self)
    {
        return _wokingQueue.count;
    }
}

#pragma mark - queue actions

- (void)addNewTask:(BBACommonDownloadTask *)aNewTask
{
    @synchronized(self)
    {
        aNewTask.delegate = self;
        [_waitingQueue addObject:aNewTask];
    }
    [self run];
}

#pragma mark - task delegate

- (void)commonTaskStarted:(BBACommonDownloadTask *)aTask
{
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(taskStarted:)])
        {
            [_delegate taskStarted:aTask];
        }
    });
}

- (void)commonTaskFinished:(BBACommonDownloadTask *)aTask
{
    @synchronized(self)
    {
        if ([_finishedQueue indexOfObject:aTask] == NSNotFound)
        {
            [_finishedQueue addObject:aTask];
            [_wokingQueue removeObject:aTask];
            _currentConcurrent--;
        }
    }

    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(taskFinished:)])
        {
            [_delegate taskFinished:aTask];
        }
    });
    
    [self run];
}

- (void)commonTaskFailed:(BBACommonDownloadTask *)aTask
{
    @synchronized(self)
    {
        if ([_failedQueue indexOfObject:aTask] == NSNotFound)
        {
            [_failedQueue addObject:aTask];
            [_wokingQueue removeObject:aTask];
            _currentConcurrent--;
        }
    }
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(taskFailed:)])
        {
            [_delegate taskFailed:aTask];
        }
    });
    [self run];
}

- (void)commonTaskProgress:(BBACommonDownloadTask *)aTask
{
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(taskProgress:)])
        {
            [_delegate taskProgress:aTask];
        }
    });
}

- (void)commonTaskStatusChanged:(BBACommonDownloadTask *)aTask
{
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(taskStatusChanged:)])
        {
            [_delegate taskStatusChanged:aTask];
        }
    });
}

#pragma mark - check

// 任务调度
- (void)run
{
    @synchronized(self)
    {
        if (!_allowRunning) return;
        if (_wokingQueue.count == 0 && _waitingQueue.count == 0 && _failedQueue.count == 0 && _suspendQueue.count == 0)
        {
            if (_delegate != nil && [_delegate respondsToSelector:@selector(allTasksFinished)])
            {
                [_delegate allTasksFinished];
                return;
            }
        }
        while (_currentConcurrent < _maxConcurrent && _waitingQueue.count > 0 && _wokingQueue.count <_maxConcurrent)
        {
            BBACommonDownloadTask *waitingTask = [_waitingQueue objectAtIndex:0];
            if (waitingTask == nil) break;
            [_wokingQueue addObject:waitingTask];
            _currentConcurrent++;
            [_waitingQueue removeObject:waitingTask];
            dispatch_async(GCD_GLOBAL_QUEUQ, ^{
                [waitingTask start];
            });
        }
    }
}
@end // BBADownloadManager
