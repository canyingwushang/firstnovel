//
//  CKGlobalDefine.h
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
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

#define BOX_UA   @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B554a baiduboxapp/0_4.0.1.5_enohpi_6311_046/4.0.7_2C2%255enohPi/1099a/FBBE6ECA80E747E8B9D91F550C2A964B56CF0103AFNTHLPGGJG/1"

#ifndef _LITEBOOK
    #define UMENG_APPKEY    @"52d369b456240b8c500ef4c1"
#else
    #define UMENG_APPKEY    @"52ff5a5b56240b0452164d5f"
#endif
#define UMENG_APPSTORE  @"1099a"

// detect current system version upon 5.0
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LOWWER_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#define STATUS_HEIGHT           (20.0f)
#define NAVIGATIONBAR_HEIGHT    (44.0f)
#define TABBAR_HEIGHT           (57.0f)
#define CONTAINER_HEIGHT (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT)

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

#define KJSDeleteElementByID(ID) @"var _element = document.getElementById('" ID"');var _parentElement = _element.parentNode; if(_parentElement){ _parentElement.removeChild(_element);}"

#define RATE_FOR_IOS6_URL_STRING     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=814922547" // rate URL string 好评 （< ios 7）
#define RATE_FOR_IOS7_URL_STRING     @"itms-apps://itunes.apple.com/app/id814922547" // rate URL string 详情页 （ios 7）

#define BAIDU_RATE_FOR_IOS6_URL_STRING     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=382201985" // rate URL string 好评 （< ios 7）
#define BAIDU_RATE_FOR_IOS7_URL_STRING     @"itms-apps://itunes.apple.com/app/id382201985" // rate URL string 详情页 （ios 7）


// 在线参数

#define ONLINEBOOKS_SWITCH              @"onlinebooks"
#define ONLINEBOOKS_DOWNLOAD_SWITCH     @"onlinebooksdownload"
#define ONLINEBOOKS_SEX_SWITCH     @"onlinebookssex"

#define ONLINEBOOKS_ADDRESS         @"http://m.baidu.com/book#rank"

