//
//  WKReaderSwitch.h
//  WKTXTReader
//
//  Created by zhonghaoqing on 13-9-23.
//  Copyright (c) 2013年 zhonghaoqing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKReaderViewController.h"

#define ThemeDay @"day"
#define ThemeNighty @"night"

@interface WKReaderSwitch : NSObject

///
///打开文档接口，全文阅读；fileURL:输入文档的绝对路径 needPush:是否采用默认的push view controller

+ (WKReaderViewController *)openBookWithFile:(NSString *)fileURL
                               pushAnimation:(BOOL)needPush;

///
/// fileType: @"txt" 目前仅支持txt格式 needPush:是否采用默认的push view controller
///
+ (WKReaderViewController *)openBookWithFile:(NSString *)fileURL
                                    fileName:(NSString *)fileName
                                    fileType:(NSString *)fileType
                               pushAnimation:(BOOL)needPush;

///添加bookID
///
+ (WKReaderViewController *)openBookWithBookID:(NSString *)bookID
                                      filePath:(NSString *)fileURL
                                 pushAnimation:(BOOL)needPush;

///添加bookID
///
+ (WKReaderViewController *)openBookWithBookID:(NSString *)bookID
                                      filePath:(NSString *)fileURL
                                      fileName:(NSString *)fileName
                                      fileType:(NSString *)fileType
                                 pushAnimation:(BOOL)needPush;

@end
