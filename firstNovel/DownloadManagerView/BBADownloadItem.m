//
//  BBADownloadItem.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-10-29.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBADownloadItem.h"
#import "BBADownloadItemCell.h"
#import "CKFileManager.h"

@implementation BBADownloadItem

#pragma mark - init & dealloc

- (id)init
{
    self = [super init];
    if (self)
    {
        _businessType = EDownloadBusinessTypeUnkown;
        _fileIndex = 0;
    }
    
    return self;
}

- (void)dealloc
{
    _viewDelegate.dataSource = nil;
    
	RELEASE_SET_NIL(_title);
    RELEASE_SET_NIL(_sourceURL);
    RELEASE_SET_NIL(_taskID);
    RELEASE_SET_NIL(_playurl);
    RELEASE_SET_NIL(_fileName);
    
    [super dealloc];
}

- (void)setStatus:(enum TDownloadTaskStatus)status
{
    _status = status;
    if (_status == EDownloadTaskStatusFinished)
    {
        _needShownNew = YES; // 显示new图标
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_viewDelegate != nil)
        {
            if ([_viewDelegate respondsToSelector:@selector(setStatus:)])
            {
                [_viewDelegate setStatus:status];
            }
        }
    });
}

- (void)setBusinessType:(TDownloadBusinessType)businessType
{
    _businessType = businessType;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_viewDelegate != nil)
        {
            if ([_viewDelegate respondsToSelector:@selector(setFileType:)])
            {
                [_viewDelegate setFileType:businessType];
            }
        }
    });
}

- (void)setProgress:(CGFloat)progress
{
    if (_progress > 0.999999 || _progress <= progress)
    {
        _progress = progress;
    }
}

- (void)updateProgress:(CGFloat)progress totalBytes:(long long)totalBytes receivedBytes:(long long)receivedBytes
{
    self.progress = progress;
    self.totalBytes = totalBytes;
    self.receivedBytes = receivedBytes;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_viewDelegate != nil)
        {
            if ([_viewDelegate respondsToSelector:@selector(updateProgress:totalBytes:reveivedBytes:)])
            {
                [_viewDelegate updateProgress:self.progress totalBytes:self.totalBytes reveivedBytes:self.receivedBytes];
            }
        }
    });
}

- (NSDictionary *)descriptionDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, _title, DOWNLOADITEM_KEY_TITILE);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithFloat:_progress], DOWNLOADITEM_KEY_PROGRESS);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithInt:_status], DOWNLOADITEM_KEY_STATUS);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithLongLong:_totalBytes], DOWNLOADITEM_KEY_TOTALBYTES);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, _taskID, DOWNLOADITEM_KEY_TASKID);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, _sourceURL, DOWNLOADITEM_KEY_SOURCEURL);
    
    // 保存相对路径
    if ([_playurl hasPrefix:[CKFileManager sharedInstance].cacheDir])
    {
        DICTIONARY_SET_OBJECT_FOR_KEY(dict, [_playurl stringByReplacingOccurrencesOfString:[CKFileManager sharedInstance].cacheDir withString:@""], DOWNLOADITEM_KEY_PLAYURL);
    }
    else
    {
        DICTIONARY_SET_OBJECT_FOR_KEY(dict, _playurl, DOWNLOADITEM_KEY_PLAYURL);
    }

    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithLongLong:_receivedBytes], DOWNLOADITEM_KEY_RECEIVEDBYTES);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithBool:_needShownNew], DOWNLOADITEM_KEY_SHOWNNEW);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithInt:_businessType], DOWNLOADITEM_KEY_BUSINESS_TYPE);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, _fileName, DOWNLOADITEM_KEY_FILENAME);
    DICTIONARY_SET_OBJECT_FOR_KEY(dict, [NSNumber numberWithInt:_fileIndex], DOWNLOADITEM_KEY_FILEINDEX);
    return dict;
}

@end // BBADownloadItem