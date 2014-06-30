//
//  BBAActivationManager.m
//  BaiduBoxApp
//
//  Created by canyingwushang on 12-9-19.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

// 头文件
#import "BBAActivationManager.h"
#import "CKFileManager.h"
#import "CKUrlManager.h"
#import <math.h>
#import "ASIFormDataRequest.h"

// 宏定义
#define ACTIVATION_STATUS_SUCCESS                 @"1"              // 激活成功标志
#define ACTIVATION_MAX_TRYTIMES                   3                 // 激活最大重试次数

// 私有方法
@interface BBAActivationManager ()

- (void)fireActivation;
- (BOOL)parseActivationResult:(NSData *)aData;

@end

// 类实现
@implementation BBAActivationManager

#pragma mark - alloc & dealloc

+ (BBAActivationManager *)sharedInstance
{
	static BBAActivationManager *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[BBAActivationManager alloc] init];
	}
	
	return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - check & request

+ (void)doActivation
{
    [[BBAActivationManager sharedInstance] performSelectorInBackground:@selector(fireActivation) withObject:nil];
}

- (void)fireActivation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *requestURL = [NSString stringWithFormat:ACTIVATION_URL_FORMAT_STRING_WITH_TYPEID, [[CKUrlManager sharedInstance] getActivationURL], 0];
	   
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request setTimeOutSeconds:30.0f];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (error)
    {
        NSLog(@"%@", error);
    }
    
	RELEASE_SET_NIL(pool);
}
@end // BBAActivationManager
