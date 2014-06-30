//
//  CKUrlManager.m
//  firstNovel
//
//  Created by canyingwushang on 6/30/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKUrlManager.h"
#import "CKAppSettings.h"
#import "NSString-URLArguments.h"
#import "CKCommonUtility.h"
#import "CKFileManager.h"
#import "BBAUDID.h"
#import "UIDevice-Extend.h"

@interface CKUrlManager ()

@property (nonatomic, retain) NSString *uuid;

@end

@implementation CKUrlManager

+ (CKUrlManager *)sharedInstance
{
    static CKUrlManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CKUrlManager alloc] init];
    });
    return instance;
}

- (void)dealloc
{
    [_staticParamAndValue release];
    [_uuid release];
    
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _staticParamAndValue = [[self composeCommonServerParameter] retain];
        _uuid = [[self createUUID] retain];
    }
    return self;
}

- (NSString *)getUpdateURL
{
	NSString *urlString = [[NSString alloc] initWithFormat:UPDATE_URL_FORMAT_STRING, INNER_SERVER, 1, [self.uuid stringByEscapingForURLArgument], self.staticParamAndValue, 1, [MAID stringByEscapingForURLArgument]];
	return [urlString autorelease];
}

- (NSString *)getActivationURL
{
	NSString *urlString = [[NSString alloc] initWithFormat:ACTIVATION_URL_FORMAT_STRING, INNER_SERVER, self.staticParamAndValue];
    
	return [urlString autorelease];
}

- (NSString *)composeCommonServerParameter
{
	NSString *commonServerParameter = @"";
	
	// 方便服务器端调试，保证顺序
    // 4.7开始默认使用SDKUID，5.0开始client删除开关下发逻辑
    commonServerParameter = [commonServerParameter stringByAppendingFormat:@"uid=%@", [self readUIDValue]];
    
	commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&ua=%@", [self readUAValue]];
	commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&ut=%@", [self readUTValue]];
	commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&from=%@", [ACTIVATION_CHANNEL stringByEscapingForURLArgument]];
	commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&osname=%@", OSNAME_VALUE]; // 产品线标识，固定值
    commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&osbranch=%@", OSBRANCH_VALUE]; // 平台号，随发版改变
    commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&cfrom=%@", [ACTIVATION_CHANNEL stringByEscapingForURLArgument]];
    commonServerParameter = [commonServerParameter stringByAppendingFormat:@"&service=%@", SEARCHBOX_SERVICE];
	return commonServerParameter;
}

// 返回经过URLEncode后的UT
- (NSString *)readUTValue
{
	return [[[NSString alloc] initWithString:[[[UIDevice currentDevice] getDeviceInfo] stringByEscapingForURLArgument]] autorelease];
}

// 返回经过URLEncode后的UA
- (NSString *)readUAValue
{
	// 手机平台是固定的iphone，只可能随发版改变。
	// 0是hardcode的屏幕密度，和刘魁协定iOS固定用0，屏幕是否是高清由服务器端根据UT参数中的机型来定，不同于android的实现。
    return [[[NSString alloc] initWithFormat:@"%@_iphone_%@_0",  [CKCommonUtility getScreenResolution], [INNER_VERSION stringByEscapingForURLArgument]] autorelease];
}

- (NSString *)createSDKUID
{
	NSString *uidString = [BBAUDID verifiableValue];
    if (CHECK_STRING_VALID(uidString))
    {
        return [uidString uppercaseString];
    }
	
    return [[NSString stringWithString:[CKCommonUtility md5:OSNAME_VALUE]] uppercaseString];
}

// 返回经过URLEncode后的SDKUID
- (NSString *)readUIDValue
{
	NSString *uidPath = [[CKFileManager sharedInstance] getSDKUIDFilePath];
	NSString *uidString = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:uidPath])
	{
        uidString = [[[NSString alloc] initWithContentsOfFile:uidPath encoding:NSUTF8StringEncoding error:nil] autorelease];
		// 位数不是51位则视为错误数据
		if ([uidString length] == kVerifiable_BBAUDID_Length && [uidString rangeOfString:@" "].location == NSNotFound)
		{
			return [uidString stringByEscapingForURLArgument];
		}
		else
		{
			[[NSFileManager defaultManager] removeItemAtPath:uidPath error:nil];
		}
	}
    
	uidString = [self createSDKUID];
	[uidString writeToFile:uidPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	return [uidString stringByEscapingForURLArgument];
}

// 关于里面的UUID
- (NSString *)createUUID
{
    NSString *productID = @"31"; // iOS的百度搜索的产品标识为11、掌百的标识是21、百度App是31.
    
	NSString *deviceID = [self readUIDValue];
    NSString *md5DeviceID = [[CKCommonUtility md5:deviceID] uppercaseString];
    NSArray *versionNumArray = [DISPLAY_VERSION componentsSeparatedByString:@"."];
    NSMutableString *checkSumString = [[NSMutableString alloc] init];
    
    int start = 0;
    int index;
    for (int i = 0; i < kUUIDCheckSumBitNum; i++)
    {
        if (i < [versionNumArray count])
        {
            start += [[versionNumArray objectAtIndex:i] intValue];
        }
        else
        {
            start += kDefaultVesionValue;
        }
        index = start % md5DeviceID.length;
        if (index < md5DeviceID.length)
        {
            [checkSumString appendFormat:@"%c", [md5DeviceID characterAtIndex:index]];
        }
    }
    NSMutableString *uuid = [[NSMutableString alloc] initWithFormat:@"%@",productID];
    @try
    {
        [uuid appendString:[md5DeviceID substringToIndex:md5DeviceID.length / 2]];
        [uuid appendString:checkSumString];
        [uuid appendString:[md5DeviceID substringFromIndex:md5DeviceID.length / 2]];
    }
    @catch (NSException *exception) {
        ;
    }
    @finally {
        ;
    }
	RELEASE_SET_NIL(checkSumString);
    return [uuid autorelease];
}

- (NSString *)composeUserAgentParameter
{
    NSString *orginalUserAgent = ORIGINAL_UA;
    if (CHECK_STRING_VALID(orginalUserAgent))
    {
        NSString *composeUserAgentParameter = @"";
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:nil withParam:OSNAME_VALUE];
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:composeUserAgentParameter withParam:[CKCommonUtility reverseString:[self readUAValue]]];
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:composeUserAgentParameter withParam:[CKCommonUtility reverseString:[self readUTValue]]];
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:composeUserAgentParameter withParam:@"1099a"];
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:composeUserAgentParameter withParam:[self readUIDValue]];
        composeUserAgentParameter = [self addUserAgentParamWithOriginalUserAgent:composeUserAgentParameter withParam:@"1"];
        
        composeUserAgentParameter = [orginalUserAgent stringByAppendingFormat:@" %@", composeUserAgentParameter];
        
        return composeUserAgentParameter;
    }
    return ORIGINAL_UA;
}

- (NSString *)addUserAgentParamWithOriginalUserAgent:(NSString *)originalUa withParam:(NSString *)param
{
    if (!originalUa)
    {
        return [param stringByEscapingForURLArgument];
    }
    else
    {
        return [originalUa stringByAppendingFormat:@"/%@", [param stringByEscapingForURLArgument]];
    }
}

@end
