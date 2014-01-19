//
//  BBANetWorkCheckSocket.m
//  BaiduSearch
//
//  Created by houshaolong on 7/11/11.
//  Copyright 2011 Baidu Inc. All rights reserved.
//

// 头文件
#import "BBANetWorkCheckSocket.h"

// 私有方法分类
@interface BBANetWorkCheckSocket ()
{
	NSInputStream *_inputStream;
	id<BBANetWorkCheckDelegate> delegate;
	double overtimeInterval;
	NSTimer *_overtimeTimer;
}

- (void)releaseStream;
- (void)freeOvertimeTimer;

@end

// 类实现
@implementation BBANetWorkCheckSocket
@synthesize inputStream = _inputStream;
@synthesize delegate;
@synthesize overtimeInterval;
@synthesize overtimeTimer = _overtimeTimer;

#pragma mark - Init and Dealloc

- (id)init
{
	self = [super init];
	if (self)
	{
		overtimeInterval = 0.0f;
	}

	return self;
}

- (void)dealloc
{
	[self freeOvertimeTimer];
	[self releaseStream];
	
	[super dealloc];
}

#pragma mark - Socket method

- (void)createSocketStreamWithURLString:(NSString *)aURLString
{
	[self releaseStream];

	if (aURLString && [aURLString length])
	{
		NSURL *tmpURL = [NSURL URLWithString:aURLString];

		CFReadStreamRef readStream = NULL;
		CFWriteStreamRef writeStream = NULL;
		if (tmpURL && [tmpURL host])
			CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[tmpURL host], [[tmpURL port] unsignedIntValue], &readStream, &writeStream);

		if (readStream && writeStream)
		{
			self.inputStream = (NSInputStream *)readStream;
			CFRelease(readStream);
			CFRelease(writeStream);
			[_inputStream setDelegate:self];
			[_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
			[_inputStream open];

			if (overtimeInterval > 0.0f)
			{
				NSDate *tmpDate = [[NSDate alloc] initWithTimeIntervalSinceNow:overtimeInterval];
				NSTimer *tmpTimer = [[NSTimer alloc] initWithFireDate:tmpDate interval:0.0f target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
				RELEASE_SET_NIL(tmpDate);
				self.overtimeTimer = tmpTimer;
				RELEASE_SET_NIL(tmpTimer);
				[[NSRunLoop currentRunLoop] addTimer:_overtimeTimer forMode:NSDefaultRunLoopMode];
			}
		}
		else
		{
			if (delegate && [delegate respondsToSelector:@selector(netWorkCheckSocketErr:)])
				[delegate netWorkCheckSocketErr:self];
		}
	}
}

- (void)close
{
	[self releaseStream];
	[self freeOvertimeTimer];
}

#pragma mark - resources release method

- (void)releaseStream
{
	if (_inputStream)
	{
		[_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		_inputStream.delegate = nil;
		[_inputStream close];
		self.inputStream = nil;
	}
}

- (void)freeOvertimeTimer
{
	if (_overtimeTimer)
	{
		if ([_overtimeTimer isValid])
			[_overtimeTimer invalidate];
		self.overtimeTimer = nil;
	}
}

- (void)timerFired:(id)sender
{
	[self freeOvertimeTimer];
	[self close];
    
	if (delegate && [delegate respondsToSelector:@selector(netWorkCheckSocketOvertime:)])
		[delegate netWorkCheckSocketOvertime:self];
}

#pragma mark - NSInputStream Delegate Method

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	switch (eventCode)
	{
        case NSStreamEventOpenCompleted:
        {
            if (delegate && [delegate respondsToSelector:@selector(netWorkCheckSocketDidConnnect:)])
                [delegate netWorkCheckSocketDidConnnect:self];
            
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            [self close];
            
            if (delegate && [delegate respondsToSelector:@selector(netWorkCheckSocketErr:)])
                [delegate netWorkCheckSocketErr:self];
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self close];
            break;
        }
        default:
            break;
	}
}

@end // BBANetWorkCheckSocket
