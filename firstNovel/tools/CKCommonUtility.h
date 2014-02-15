//
//  CKCommonUtility.h
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

// 宏定义
// ApplicationFrameWidth
#define APPLICATION_FRAME_WIDTH      ([CKCommonUtility getApplicationSize].width)
// ApplicationFrameHeight
#define APPLICATION_FRAME_HEIGHT    ([CKCommonUtility getApplicationSize].height)

@interface CKCommonUtility : NSObject

+ (CGSize)getApplicationSize;

+ (NSString *)md5:(NSString *)aInput;

+ (BOOL)isiPhone5;

+ (NSArray *)videoTypeList; // Content-Type: Video
+ (BOOL)isM3U8:(NSString *)aContentType; // Content-Type: m3u8
+ (BOOL)isTextHtml:(NSString *)aContentType;// Content-Type: text/html
+ (BOOL)isTextPlain:(NSString *)aContentType; // Content-Type:text/plain
+ (BOOL)isAudioMP3:(NSString *)aContentType; // Content-Type audio/mp3
+ (BOOL)isImage:(NSString *)aContentType; // Content-Type image/*
+ (BOOL)isMP4File:(NSString *)contentType;
+ (NSArray *)imageTypeList;

+ (CGFloat)avaiableDiskStorage; // 系统可用容量 单位：MB
+ (CGFloat)totalDiskStorage; // 系统总容量 单位：MB
+ (NSString *)sizeStr:(long long)bytes;

+ (UIColor *)RGBColorFromHexString:(NSString *)aHexStr alpha:(float)aAlpha;

+ (void)goRating;
+ (void)goPro;

@end
