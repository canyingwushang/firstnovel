//
//  BBAUpdateManager.m
//  BaiduBoxApp
//
//  Created by BaiduBoxApp on 09/25/12.
//  Copyright (c) 2012 Baidu Inc. All rights reserved.
//

// 头文件
#import "BBAUpdateManager.h"
#import "ASIFormDataRequest.h"
#import "CKUrlManager.h"

// 宏定义
#define RETRY_TIME		3         // 重试请求次数

// 私有方法分类
@interface BBAUpdateManager ()
{
    NSString *_updateURL;
    ASIFormDataRequest *_updateReq;
}


@end // BBAUpdateManager

// 类实现
@implementation BBAUpdateManager
@synthesize updateURL = _updateURL;
@synthesize updateReq = _updateReq;

#pragma mark - init & dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
        _updateURL = [[[CKUrlManager sharedInstance] getUpdateURL] retain];
	}
	
	return self;
}

- (void)dealloc
{
	RELEASE_SET_NIL(_updateURL);
    RELEASE_SET_NIL(_updateReq);
	
	[super dealloc];
}

+ (BBAUpdateManager *)sharedInstance
{
	static BBAUpdateManager *_sharedInstance = nil;
	if (_sharedInstance == nil)
	{
		_sharedInstance = [[BBAUpdateManager alloc] init];
	}
	
	return _sharedInstance;
}

#pragma mark - Open API


- (void)sendUpdateRequest
{
    @try
    {
        @synchronized(self)
        {
            @autoreleasepool {
                ASIFormDataRequest *req = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:_updateURL]];
                self.updateReq = req;
                RELEASE_SET_NIL(req);
                [_updateReq setDelegate:self];
                [_updateReq addRequestHeader:HTTP_HEADER_CONTENT_TYPE_KEY_NAME value:HTTP_HEADER_CONTENT_TYPE_APPLICATION_X_WWW_FORM_URLENCODED];
                
                // 各种版本
                [_updateReq addPostValue:composeUpdateBodyVersionSec forKey:UPDATE_POST_PARAM_VERSION_HEADER];
                
                // Data
                [_updateReq addPostValue:composeUpdateBodyDataSec forKey:POST_PARAM_DATA_HEADER];
                
                [_updateReq setTimeOutSeconds:30.0f];
                [_updateReq startAsynchronous];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

#pragma mark - ASIHttpRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSMutableString *receiveStr = [[[NSMutableString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"%@", receiveStr);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.error);
}

@end // BBAUpdateManager
