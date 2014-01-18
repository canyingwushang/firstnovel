//
//  WKReaderConfig.h
//  WKTXTReader
//
//  Created by PiosaJiang on 13-10-15.
//  Copyright (c) 2013年 Baidu.com. All rights reserved.
//

@interface WKReaderConfig : NSObject

//设置调用方的CUID, 用于统计, 必需调用
+ (void)setCUID:(NSString *)cuidString;

+ (void)switchTheme:(NSString *)themeName; //默认自带 @“day” 、@"night" 两套皮肤

///配置阅读SDK的数据库存放路径，默认的存放路径为Documents
+ (void)setDatabaseFolderPath:(NSString *)folderPath;

///删除书籍阅读信息
+ (BOOL)deleteBookData:(NSString *)fileURL;

///停止统计事件
+(void)stopTracker;

///允许统计事件
+(void)startTracker;

@end
