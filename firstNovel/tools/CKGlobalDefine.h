//
//  CKGlobalDefine.h
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

// 系统版本号枚举
#define IOS_2_0 @"2.0"
#define IOS_3_0 @"3.0"
#define IOS_4_0 @"4.0"
#define IOS_5_0 @"5.0"
#define IOS_6_0 @"6.0"
#define IOS_6_0_1 @"6.0.1"
#define IOS_7_0 @"7.0"

// detect current system version upon 5.0
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LOWWER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define STATUS_HEIGHT           (20.0f)
#define NAVIGATIONBAR_HEIGHT    (44.0f)
#define TABBAR_HEIGHT           (57.0f)

// GCD
#define GCD_GLOBAL_QUEUQ (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
#define GCD_MAIN_QUEUE (dispatch_get_main_queue())

// check字符串
#define CHECK_STRING_VALID(targetString)				\
(targetString != nil && [targetString length] != 0)

#define CHECK_STRING_INVALID(targetString)              \
(targetString == nil || [targetString length] == 0)

// 设置dictionary的键值对
#define DICTIONARY_SET_OBJECT_FOR_KEY(dictionay,object,key)			\
do{																	\
if ((object) != nil && (key) != nil)                                \
{                                                                   \
[(dictionay) setObject:(object) forKey:(key)];                      \
}                                                                   \
}while(0)

// RELEASE_SET_NIL
#define RELEASE_SET_NIL(aobj)							\
do{[aobj release]; aobj = nil;}while(0)


#define KJSGetHTMLTagInnerHTML  @"document.getElementsByTagName('html')[0].innerHTML"
