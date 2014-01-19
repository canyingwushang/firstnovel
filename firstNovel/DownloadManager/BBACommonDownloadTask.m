//
//  BBACommonDownloadTask.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-21.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBACommonDownloadTask.h"
#import "ASIHTTPRequest.h"
#import "CKFileManager.h"
#import "CKCommonUtility.h"

@interface BBACommonDownloadTask ()

@property (nonatomic, retain) ASIHTTPRequest *downloadRequest;
@property (nonatomic, retain) NSString *taskDir;

@end

@implementation BBACommonDownloadTask

#pragma mark - init & dealloc

- (id)init
{
    self = [super init];
    if (self)
    {
        _type = EDownloadFileTypeCommon;
        _status = EDownloadTaskStatusWaiting;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    BBACommonDownloadTask *task = [[BBACommonDownloadTask alloc] init];
    task.taskID = [[_taskID copyWithZone:zone] autorelease];
    task.downloadDestinationPath = [[_downloadDestinationPath copyWithZone:zone] autorelease];
    task.progress = _progress;
    task.status = _status;
    task.delegate = _delegate;
    task.sourceURL = [[_sourceURL copyWithZone:zone] autorelease];
    task.type = _type;
    task.downloadRequest = [[_downloadRequest copyWithZone:zone] autorelease];
    task.contentType = [[_contentType copyWithZone:zone] autorelease];
    return task;
}

- (void)dealloc
{
    _downloadRequest.delegate = nil;
	RELEASE_SET_NIL(_downloadRequest);
	RELEASE_SET_NIL(_downloadDestinationPath);
    RELEASE_SET_NIL(_taskID);
    RELEASE_SET_NIL(_sourceURL);
    RELEASE_SET_NIL(_redirectURL);
    RELEASE_SET_NIL(_contentType);
    RELEASE_SET_NIL(_playUrl);
    RELEASE_SET_NIL(_fileName);
    RELEASE_SET_NIL(_taskDir);
    
    [super dealloc];
}

#pragma mark - actions

- (void)start
{
    if (CHECK_STRING_INVALID(_sourceURL)) return;
    
    // 创建下载video工作目录
    NSString *videoDir = [[CKFileManager sharedInstance] getDownloadCacheDirForNovel];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoDir])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDir withIntermediateDirectories:NO attributes:nil error:&error];
        if (error != nil) return;
    }
    // 创建下载task工作目录
    NSString *taskDir = [videoDir stringByAppendingPathComponent:_taskID];
    self.taskDir = taskDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:taskDir])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:taskDir withIntermediateDirectories:NO attributes:nil error:&error];
        if (error != nil) return;
    }
    
    NSURL *targetURL = [NSURL URLWithString:_sourceURL];
    if (targetURL == nil) return;
    
    _downloadDestinationPath = [[taskDir stringByAppendingPathComponent:_taskID] retain];
    // 避免重复下载, 临时文件为.tmp的后缀, 非tmp后缀的文件则为完整文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:_downloadDestinationPath])
    {
        //self.status = EDownloadTaskStatusDup;
        [self requestFinished:nil];
        return;
    }
    
    if (_downloadRequest != nil)
    {
        _downloadRequest.delegate = nil;
		RELEASE_SET_NIL(_downloadRequest);
    }
    _downloadRequest = [[ASIHTTPRequest alloc] initWithURL:targetURL];
    _downloadRequest.delegate = self;
    _downloadRequest.downloadDestinationPath = _downloadDestinationPath;
    _downloadRequest.temporaryFileDownloadPath = [_downloadDestinationPath stringByAppendingString:@".tmp"]; // 添加临时下载文件以支持断点续传
    _downloadRequest.downloadProgressDelegate = self;
    _downloadRequest.timeOutSeconds = 30.0f;
    _downloadRequest.allowResumeForFileDownloads = YES; // 支持断点续传
    [_downloadRequest setAllowCompressedResponse:NO];  // 下载中心不支持gzip压缩数据
    [_downloadRequest startAsynchronous];
    self.status = EDownloadTaskStatusRunning;
}

- (void)restart
{
    [_downloadRequest clearDelegatesAndCancel];
    RELEASE_SET_NIL(_downloadRequest);
    [self setProgress:0.0f];
    NSString *videoDir = [[CKFileManager sharedInstance] getDownloadCacheDirForNovel];
    [[NSFileManager defaultManager] removeItemAtPath:[videoDir stringByAppendingPathComponent:_taskID] error:nil];
    self.status = EDownloadTaskStatusWaiting;
    [self start];
}

- (void)stop
{
    self.status = EDownloadTaskStatusSuspend;
    [_downloadRequest cancel];
    _downloadRequest.delegate = nil;
    RELEASE_SET_NIL(_downloadRequest);
}

- (void)clear
{
    [self stop];
    NSString *videoDir = [[CKFileManager sharedInstance] getDownloadCacheDirForNovel];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[videoDir stringByAppendingPathComponent:_taskID] error:&error];
}

- (void)setType:(enum TDownloadFileType)type
{
    _type = type;
}

- (void)setStatus:(enum TDownloadTaskStatus)status
{
    _status = status;
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commonTaskStatusChanged:)])
        {
            [_delegate commonTaskStatusChanged:self];
        }
    });
}

#pragma mark - ASI delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    _receivedBytes = 0;
    _totalBytes = 0;
    _progress = 0.0f;
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
    self.contentType = contentType;
    if (CHECK_STRING_VALID(contentType))
    {
        if ([[CKCommonUtility videoTypeList] indexOfObject:[contentType lowercaseString]] != NSNotFound)
        {
            self.type = EDownloadFileTypeVideo;
        }
        else if ([CKCommonUtility isM3U8:contentType])
        {
            self.type = EDownloadFileTypeTEXTM3U8; // m3u8索引
        }
        else if ([CKCommonUtility isTextHtml:contentType])
        {
            self.type = EDownloadFileTypeTEXTHTML; // html
        }
        else if ([CKCommonUtility isTextPlain:contentType])
        {
            self.type = EDownloadFileTypeTEXTPLAIN; // 纯文本
        }
        else if ([CKCommonUtility isAudioMP3:contentType]) // mp3
        {
            self.type = EDownloadFileTypeAudioMp3;
        }
        else if ([CKCommonUtility isImage:contentType]) // image
        {
            self.type = EDownloadFileTypeImage;
        }
    }
    NSString *pathExtension = [[request.url absoluteString] pathExtension]; // 后缀名
    // 猜测为mp3文件
    if (_type == EDownloadFileTypeCommon && [[pathExtension lowercaseString] isEqualToString:@"mp3"])
    {
        self.type = EDownloadFileTypeAudioMp3;
    }
    // 猜测为图片文件
    if (_type == EDownloadFileTypeCommon && [[CKCommonUtility imageTypeList] indexOfObject:pathExtension] != NSNotFound)
    {
        self.type = EDownloadFileTypeImage;
    }
    
    // response Header中包含Content-Disposition
    NSString *contentDisposition = [responseHeaders objectForKey:@"Content-Disposition"];
    if (CHECK_STRING_VALID(contentDisposition))
    {
        // "filename=xxxxxx"
        NSRange fileNameRange = [contentDisposition rangeOfString:@"Content-Disposition"];
        if (fileNameRange.location != NSNotFound && fileNameRange.length > 0)
        {
            self.fileName = [contentDisposition substringFromIndex:fileNameRange.location + fileNameRange.length];
        }
    }
    
    NSString *contentLength = [responseHeaders objectForKey:@"Content-Length"];
    if (contentLength != nil && [contentLength isKindOfClass:[NSString class]])
    {
        _totalBytes = [contentLength longLongValue];
    }
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commonTaskStarted:)])
        {
            [_delegate commonTaskStarted:self];
        }
    });
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        
        self.redirectURL = [request.url absoluteString];
        
        if (_totalBytes == 0)
        {
            _totalBytes = _receivedBytes;
        }
        
        // 鉴于很多Server不能返回ContentType，采用最终完成的大小作为总大小
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:_downloadDestinationPath error:nil];
        _totalBytes = [[fileAttrs objectForKey:NSFileSize] longLongValue];
        _receivedBytes = _totalBytes;
        
        self.status = EDownloadTaskStatusFinished;
        self.playUrl = _downloadDestinationPath;
        
        // 若response-headers取不到filename则使用url的最后一段
        if (CHECK_STRING_INVALID(_fileName))
        {
            self.fileName = [[[request url] absoluteString] lastPathComponent];
        }
        
        // 判断为文本或小说
        if (_type == EDownloadFileTypeTEXTPLAIN)
        {
            NSString *textFilePath = [_downloadDestinationPath stringByAppendingPathExtension:@"txt"];
            [[NSFileManager defaultManager] moveItemAtPath:_downloadDestinationPath toPath:textFilePath error:nil];
            self.playUrl = textFilePath;
            if (CHECK_STRING_VALID(_fileName) && [_fileName rangeOfString:@"."].location == NSNotFound)
            {
                self.fileName = [_fileName stringByAppendingPathExtension:@"txt"];
            }
        }
        
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commonTaskFinished:)])
        {
            [_delegate commonTaskFinished:self];
        }
    });
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.status = EDownloadTaskStatusFailed;

    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (_delegate != nil && [_delegate respondsToSelector:@selector(commonTaskFailed:)])
        {
            [_delegate commonTaskFailed:self];
        }
    });
}

#pragma mark - progress

- (void)setProgress:(float)newProgress
{
    _progress = newProgress;
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    _receivedBytes += bytes;
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(commonTaskProgress:)])
        {
            [self.delegate commonTaskProgress:self];
        }
    });
}

@end // BBACommonDownloadTask
