//
//  NSURL+KeyValueParsing.h
//  BaiduBoxApp
//
//  Created by canyingwushang on 13-1-16.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (KeyValueParsing)

- (NSDictionary *)keysAndValuesOfString:(NSString *)string;
- (NSDictionary *)keysAndValuesOfFragment;
- (NSDictionary *)keysAndValuesOfQuery;

@end