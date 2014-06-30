//
//  CHKeychain.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-7-5.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteService:(NSString *)service;

@end
