//
//  BBANetworkManager.m
//  BaiduBoxApp
//
//  Created by naonao on 12-9-20.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

// 头文件
#import "BBANetworkManager.h"
#import "Reachability.h"
#import "BBANetWorkCheckSocket.h"

// 宏定义
#define NETWORK_DETECT_DURATION_TIMES		10
#define CHECK_NET_URL						@"http://www.baidu.com:80"

// 私有方法分类
@interface BBANetworkManager ()
{
	BOOL currentNetWorkStatus;               				// 当前网络状态
	BOOL isNeedAlert;
	BBANetWorkCheckSocket *_netWorkCheckSocket; // 网络状态为WC下测试是否正常的socket类
	
	NSTimer *_netWorkChangeDruationTimer;
	BOOL isNetWorkChanging;                  				// 判断当前网络是否是在进行切换,特别时2G和3G之间的切换
	NSInteger durationTimes;
    
    Reachability *_hostReach;
	unsigned int curRequestNetStatus;   //0－》无联网状态
	
	NSMutableArray *_loadingWebViewControllers; // 当前正在联网的webview列表
}

// 属性
@property (nonatomic) BOOL currentNetWorkStatus;
@property (nonatomic) BOOL isNeedAlert;
@property (nonatomic, retain) NSTimer *netWorkChangeDruationTimer;
@property (nonatomic) BOOL isNetWorkChanging;
@property (nonatomic) NSInteger durationTimes;
@property (nonatomic, retain) NSMutableArray *loadingWebViewControllers;

- (void)alertCurrentNetStatusFlag:(BOOL)aCurrentNetStatus;
- (void)rigisterNetWorkDetection;                           // 注册网络监听
- (void)startDetectNotifier;                                // 启动监听通知
- (void)checkNetWorkWithSocket;                             // 利用socket到www.baidu.com测试网络真正的联通性

// --以下方法主要是为了解决网络切换过程中产生的网络状态变化太快而造成的频繁弹框的问题, 解决办法:
//      1 程序进入前台工作后10秒内不提示错误提示
//      2 10秒对应于一个均衡的网络切换时间,程序认为10秒会完成网络切换
//      3 10秒内默认网络状态为正常
//   注意:每次app进入前台后有10秒的时间不显示网络错误提示
- (void)startNetWorkChangeDuration;                         // 开始网络切换过程计时
- (void)freeOvertimeTimer;
- (void)willEnterForeground:(id)sender;
- (void)didEnterBackground:(id)sender;

@end

// 类实现
@implementation BBANetworkManager
@synthesize currentNetWorkStatus;
@synthesize isNeedAlert;
@synthesize netWorkCheckSocket = _netWorkCheckSocket;
@synthesize netWorkChangeDruationTimer = _netWorkChangeDruationTimer;
@synthesize isNetWorkChanging;
@synthesize durationTimes;
@synthesize loadingWebViewControllers = _loadingWebViewControllers;

#pragma mark - init & dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		_hostReach = nil;
		currentNetWorkStatus = YES;
		isNeedAlert = NO;
		isNetWorkChanging = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
		
		if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
		{
			if ([UIDevice currentDevice].multitaskingSupported)
			{
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
			}
		}
		
		_loadingWebViewControllers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self freeOvertimeTimer];
	RELEASE_SET_NIL(_netWorkCheckSocket);
	[self stopDetectNetwork];
	RELEASE_SET_NIL(_hostReach);
	RELEASE_SET_NIL(_loadingWebViewControllers);
    
	[super dealloc];
}

+ (BBANetworkManager *)sharedInstance
{
	static BBANetworkManager *_sharedInstance = nil;
	
	if (_sharedInstance == nil)
	{
		_sharedInstance = [[BBANetworkManager alloc] init];
	}
	
	return _sharedInstance;
}

#pragma mark - lock access methods

- (void)setCurrentNetWorkStatus:(BOOL)aValue
{
	@synchronized(self)
	{
		currentNetWorkStatus = aValue;
	}
}

- (BOOL)currentNetWorkStatus
{
	BOOL value = NO;
	
	@synchronized(self)
	{
		value = currentNetWorkStatus;
	}
	return value;
}

- (void)setIsNeedAlert:(BOOL)aValue
{
	@synchronized(self)
	{
		isNeedAlert = aValue;
	}
}

- (BOOL)isNeedAlert
{
	BOOL value = NO;
	
	@synchronized(self)
	{
		value = isNeedAlert;
	}
	return value;
}

- (void)setIsNetWorkChanging:(BOOL)aValue
{
	@synchronized(self)
	{
		isNetWorkChanging = aValue;
	}
}

- (BOOL)isNetWorkChanging
{
	BOOL value = NO;
	
	@synchronized(self)
	{
		value = isNetWorkChanging;
	}
	return value;
}

#pragma mark - Network check methods

- (void)rigisterNetWorkDetection
{
	_hostReach = [[Reachability reachabilityForInternetConnection] retain];
}

- (void)startDetectNotifier
{
	[_hostReach startNotifier];
}

- (void)stopDetectNetwork
{
	[_hostReach stopNotifier];
}

- (void)reachabilityChanged:(NSNotification* )note
{
	NSParameterAssert([[note object] isKindOfClass: [Reachability class]]);
	BOOL currentNetStatus = [self detectSynchronization:YES];
	
	[self alertCurrentNetStatusFlag:currentNetStatus];
}

- (void)alertCurrentNetStatusFlag:(BOOL)aCurrentNetStatus
{
	self.currentNetWorkStatus = aCurrentNetStatus;
	if (self.currentNetWorkStatus && self.isNeedAlert == YES)
	{
		self.isNeedAlert = NO;
	}
}

- (BOOL)detectSynchronization:(BOOL)aConnRequired
{
	BOOL currentNetStatus = NO;
	NetworkStatus netStatus = [_hostReach currentReachabilityStatus];
	BOOL connectionRequired= [_hostReach connectionRequired];
	
	if (netStatus == ReachableViaWWAN)
	{
		currentNetStatus = YES;
	}
	else if (netStatus == ReachableViaWiFi)
    {
		currentNetStatus = YES;
	}
	else
	{
		return NO;
	}
	
	if (connectionRequired)
	{
		if (aConnRequired)
		{
			[self checkNetWorkWithSocket];
			currentNetStatus = NO;
		}
	}
	
	return currentNetStatus;
}

- (void)startDetectNetwork
{
	self.isNeedAlert = NO;
	self.isNetWorkChanging = NO;
	[self rigisterNetWorkDetection];
	BOOL currentNetStatus = [self detectSynchronization:NO];
	[self alertCurrentNetStatusFlag:currentNetStatus];
	[self startDetectNotifier];
}

- (BOOL)checkCurrentNetwork
{
	if (self.isNetWorkChanging)
	{
		// 如果网络正在切换,默认网络状态为好的 ,以避免影响用户体验
		[self alertCurrentNetStatusFlag:YES];
		return YES;
	}
	
	[self alertCurrentNetStatusFlag:self.currentNetWorkStatus];
	
	if (!self.currentNetWorkStatus)
	{
		// 建立socket连接测试
		BOOL connectionRequired= [_hostReach connectionRequired];
		if (connectionRequired)
		{
			[self checkNetWorkWithSocket];
		}
	}
	else
	{
		// connection normal
	}
	
	return self.currentNetWorkStatus;
}

- (void)checkNetWorkWithSocket
{
	if (_netWorkCheckSocket)
	{
		// 如果正在检测就中断前一个检测
		[_netWorkCheckSocket close];
		self.netWorkCheckSocket = nil;
	}
    
	BBANetWorkCheckSocket *tmpSocket = [[BBANetWorkCheckSocket alloc] init];
	tmpSocket.overtimeInterval = 30.0f;
	tmpSocket.delegate = self;
	self.netWorkCheckSocket = tmpSocket;
	RELEASE_SET_NIL(tmpSocket);
	[_netWorkCheckSocket createSocketStreamWithURLString:CHECK_NET_URL]; //@"htt://imo.baidu.com:9000"
}

#pragma mark - NetWork status alert hint

- (BOOL)isNeedAlertHint
{
    return YES;//本版本需要在无网络时，如有交互则一直弹框。
	BOOL ret = NO;
	
	if (self.isNetWorkChanging == NO && self.currentNetWorkStatus == NO)
	{
		if (self.isNeedAlert == NO)
		{
			self.isNeedAlert = YES;
			ret = YES;
		}
	}
	
	return ret;
}

- (void)alertNetWorkBadHint
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:@"网络连接错误，请重试"
													   delegate:self
											  cancelButtonTitle:@"重试"
											  otherButtonTitles:nil , nil];
	[alertView show];
	RELEASE_SET_NIL(alertView);
}

#pragma mark - Network mode check methods

- (BOOL)isWifiNetwork
{
	BOOL viaWiFi = [_hostReach isReachableViaWiFi];
	return viaWiFi;
	
//    NetworkStatus netStatus = [_hostReach currentReachabilityStatus];
//    return netStatus == ReachableViaWiFi;
}

- (BOOL)isWWANNetwork
{
	BOOL viaWWAN = [_hostReach isReachableViaWWAN];
	return viaWWAN;
	
//    NetworkStatus netStatus = [_hostReach currentReachabilityStatus];
//    return netStatus == ReachableViaWWAN;
}

#pragma mark - BBANetWorkCheckSocket delegate

- (void)netWorkCheckSocketDidConnnect:(BBANetWorkCheckSocket *)aSocket
{
	[self alertCurrentNetStatusFlag:YES];
	self.isNetWorkChanging = NO;
	if (_netWorkCheckSocket)
	{
		[_netWorkCheckSocket close];
	}
	
	self.netWorkCheckSocket = nil;
}

- (void)netWorkCheckSocketErr:(BBANetWorkCheckSocket *)aSocket
{
	[self alertCurrentNetStatusFlag:NO];
	self.netWorkCheckSocket = nil;
}

- (void)netWorkCheckSocketOvertime:(BBANetWorkCheckSocket *)aSocket
{
	[self alertCurrentNetStatusFlag:NO];
	self.netWorkCheckSocket = nil;
}

#pragma mark - App enter foreground methods

- (void)netWorkChectStart
{
	self.durationTimes++;
	if (self.durationTimes == NETWORK_DETECT_DURATION_TIMES)
	{
		// 开启错误检测 ,同时进行网络判断
		self.isNetWorkChanging = NO;
		[self freeOvertimeTimer];
		BOOL currentNetStatus = [self detectSynchronization:YES];
		[self alertCurrentNetStatusFlag:currentNetStatus];
	}
}

- (void)freeOvertimeTimer
{
	if (_netWorkChangeDruationTimer)
	{
		if ([_netWorkChangeDruationTimer isValid])
			[_netWorkChangeDruationTimer invalidate];
		self.netWorkChangeDruationTimer = nil;
	}
}

- (void)startNetWorkChangeDuration
{
	self.isNetWorkChanging = YES;
	NSDate *tmpDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.0f];
	NSTimer *tmpTimer = [[NSTimer alloc] initWithFireDate:tmpDate interval:1.0f target:self selector:@selector(netWorkChectStart) userInfo:nil repeats:YES];
	
	if (_netWorkChangeDruationTimer)
		[self freeOvertimeTimer];
	
	durationTimes = 0;
	self.netWorkChangeDruationTimer = tmpTimer;
	[[NSRunLoop currentRunLoop] addTimer:_netWorkChangeDruationTimer forMode:NSDefaultRunLoopMode];
	RELEASE_SET_NIL(tmpDate);
	RELEASE_SET_NIL(tmpTimer);
}

- (void)willEnterForeground:(id)sender
{
	[self startNetWorkChangeDuration];
}

- (void)didEnterBackground:(id)sender
{
	self.isNetWorkChanging = NO;
	
	if (_netWorkChangeDruationTimer)
		[self freeOvertimeTimer];
}

- (void)startNetRequest:(enum TNetRequestType)aNetRequestType object:(id)aObject
{
	if (aNetRequestType == ENetRequestKeyWordSearch)
	{
		if ([_loadingWebViewControllers indexOfObject:aObject] == NSNotFound)
		{
            [_loadingWebViewControllers addObject:aObject];
		}
	}
	else
	{
		curRequestNetStatus = curRequestNetStatus | aNetRequestType;
	}
    
	if (curRequestNetStatus != 0 || [_loadingWebViewControllers count] != 0)
	{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)endNetRequest:(enum TNetRequestType)aNetRequestType object:(id)aObject
{
	// 停止某类网络请求
	if (aNetRequestType == ENetRequestKeyWordSearch)
	{
		[_loadingWebViewControllers removeObject:aObject];
	}
	else
	{
		curRequestNetStatus = curRequestNetStatus & (0xffff - aNetRequestType);
	}
    
	// 所有的请求都停止，联网状态不显示
	if (curRequestNetStatus == 0 && [_loadingWebViewControllers count] == 0)
	{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

@end // BBANetworkManager
