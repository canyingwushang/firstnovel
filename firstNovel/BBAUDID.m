//
//  BBAUDID.m
//  BaiduBoxApp
//
//  Created by wang cong on 13-8-19.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "BBAUDID.h"
#import "CHKeychain.h"
#import <CommonCrypto/CommonDigest.h>

#define RANDOM_MAX_UINTEGER (4294967295) // pow(2.0f, 32.0f)-1

// ------以下Key值可能会存有脏数据，废弃使用
//#define kVerifiableBaiduUDIDKeychainIdentify		@"verifiablebaiduopenudid"
// ------

#define kVerifiable_BaiduUDIDKeychainIdentify_Old	@"verifiable_baiduopenudid" // BaiduOpenUDID生成的带校验位UDID所存储的Keychain对应的Key值，不能保证51位长度
#define kVerifiable_BBAUDIDKeychainIdentify_New	@"verifiable_baiduopenudid_51b" // App自身生成的带校验位UDID所存储的Keychain对应的Key值，保证51位长度

// 私有
@interface BBAUDID ()

+ (NSString *)generateFreshUDID; // 生成40位不带校验位的原始UDID串
+ (NSString *)verifiyUDID:(NSString *)aUDID; // 加密一个UDID

@end

// 类实现
@implementation BBAUDID

#pragma mark - public api

+ (NSString *)verifiableValue
{
	NSString *openUDID = nil;
	// step1:首先从新的keychain中取值
	openUDID = [CHKeychain load:kVerifiable_BBAUDIDKeychainIdentify_New];
	
	// 新keychain中的值即为正确值
	if ([openUDID isKindOfClass:[NSString class]] && [openUDID length] == kVerifiable_BBAUDID_Length && [openUDID rangeOfString:@" "].location == NSNotFound)
	{
		return openUDID;
	}
	
	// step2:假如没有从新keychain中获取到数据，则从老keychain中取值
	openUDID = [CHKeychain load:kVerifiable_BaiduUDIDKeychainIdentify_Old];
	
	// step3:若新老keychain中获取到的数据都不正确，则重新生成
	if (![openUDID isKindOfClass:[NSString class]] || [openUDID length] != kVerifiable_BBAUDID_Length || [openUDID rangeOfString:@" "].location != NSNotFound)
	{
		openUDID = [BBAUDID verifiyUDID:[BBAUDID generateFreshUDID]];
	}

	// 做一步容错，生成的值不对则返回空
	if ([openUDID length] != kVerifiable_BBAUDID_Length || [openUDID rangeOfString:@" "].location != NSNotFound)
	{
		return nil;
	}
	
	// step4:写入新keychain并返回
	[CHKeychain save:kVerifiable_BBAUDIDKeychainIdentify_New data:openUDID];
	
	return openUDID;
}

#pragma mark - private api

+ (NSString *)generateFreshUDID
{
    NSString* _openUDID = nil;
	CFUUIDRef uuid = nil;
	CFStringRef cfstring = nil;
	const char *cStr = NULL;
	
    uuid = CFUUIDCreate(kCFAllocatorDefault);
    if (uuid != nil)
    {
        cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        if (cfstring != nil)
        {
            cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        }
    }
        
	unsigned char result[16];
	if (cStr == NULL || strlen(cStr) == 0)
	{
		int randomLength = 17;
		char *tcStr = (char *)malloc(randomLength * sizeof(char));
		memset(tcStr, 0, randomLength);
		sprintf(tcStr, "%08x", (NSUInteger)(arc4random() % RANDOM_MAX_UINTEGER));
		CC_MD5( tcStr, strlen(tcStr), result );
		free(tcStr);
	}
	else
	{
		CC_MD5( cStr, strlen(cStr), result );
	}
    
	_openUDID = [NSString stringWithFormat:
				 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08x",
				 result[0], result[1], result[2], result[3],
				 result[4], result[5], result[6], result[7],
				 result[8], result[9], result[10], result[11],
				 result[12], result[13], result[14], result[15],
				 (NSUInteger)(arc4random() % RANDOM_MAX_UINTEGER)]; 
	
	if (uuid != nil)
    {
        CFRelease(uuid);
    }
    if (cfstring != nil)
    {
        CFRelease(cfstring);
    }
    return _openUDID;
}

+ (NSString *)verifiyUDID:(NSString *)aUDID
{
    NSString *sourceUID = aUDID;
    NSString *timeStampStr = [NSString stringWithFormat:@"%010ld", (long)[[NSDate date] timeIntervalSince1970]];
    if (timeStampStr.length > 10)
    {
        timeStampStr = [timeStampStr substringWithRange:NSMakeRange(0, 10)];
    }
    int numIndex = 0;
    int numCount = timeStampStr.length;
    NSMutableString *encryptStamp = [NSMutableString string];
    for (; numIndex < numCount; numIndex++)
    {
        unichar t = ([timeStampStr characterAtIndex:numIndex] - 48) % 10;
        int randt = ((NSUInteger)(arc4random() % NSUIntegerMax))%2;
        int charcode = 0;
        switch (t)
        {
            case 0:
            {
                charcode = randt ? 69:80;
                break;
            }
            case 1:
            {
                charcode = randt ? 70:79;
                break;
            }
            case 2:
            {
                charcode = randt ? 68:81;
                break;
            }
            case 3:
            {
                charcode = randt ? 71:78;
                break;
            }
            case 4:
            {
                charcode = randt ? 67:82;
                break;
            }
            case 5:
            {
                charcode = randt ? 72:77;
                break;
            }
            case 6:
            {
                charcode = randt ? 66:83;
                break;
            }
            case 7:
            {
                charcode = randt ? 73:76;
                break;
            }
            case 8:
            {
                charcode = randt ? 65:84;
                break;
            }
            case 9:
            {
                charcode = randt ? 74:75;
                break;
            }
            default:
            {
                charcode = randt ? 69:80; // 与0的处理相同
                break;
            }
        }
        charcode += 32; // 转为小写
        [encryptStamp appendFormat:@"%c", charcode];
    }
    NSString *combinSourceStampStr = [NSString stringWithFormat:@"%@%@", sourceUID, timeStampStr];
    int combinIndex = 0;
    int combinCount = combinSourceStampStr.length;
    char pNum[2];
    pNum[0] = '\0';
    pNum[1] = '\0';
    NSInteger sum = 0;
    for (; combinIndex < combinCount; combinIndex++)
    {
        pNum[0] = (char)[combinSourceStampStr characterAtIndex:combinIndex];
        NSInteger dnum = strtol(pNum, NULL, 16);
        double powy = (double)(14-combinIndex%14);
        double powx = (double)2.0;
        long powt = (long)pow(powx, powy);
        sum += (dnum * (powt%13));
    }
    NSInteger validateCodeNum = sum%16;
    NSString *BaiduOpenUDID = [NSString stringWithFormat:@"%@%x%@", sourceUID, validateCodeNum, encryptStamp];
    return BaiduOpenUDID;
}

@end // BBAUDID
