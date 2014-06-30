//
//  CKGlobalDefine.h
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <Foundation/Foundation.h>


#define INNER_SERVER                                @"http://m.baidu.com/searchbox"
#define INNER_VERSION                               @"5.4.0.0"
#define DISPLAY_VERSION                             @"5.4"
#define ACTIVATION_CHANNEL                          @"1099a"

#define MAID    @"_av5aYiJvtgo8viRia21a_P6-8l2Cvuw0iXTiYuhSNj6u2iKoavxuY8JHa0W8v8uhqqSB"


#define composeUpdateBodyVersionSec @"{\"captionv_v\":{\"sharehint_v\":\"0\"},\"hometab_v\":\"11\",\"xprompt_v\":{\"wallet_v\":\"1399978776\",\"walletsrv_v\":\"1403260589\",\"priv_v\":\"0\"},\"extra_v\":{\"cardsn_v\":\"0\",\"locperiod_v\":\"0\"},\"srchsvc_v\":\"1\",\"opres_v\":{\"poems_v\":\"0\"},\"passport_v\":\"0\",\"imgsearch_v\":\"1\",\"video_v\":\"1\",\"regx_v\":{\"websearch_v\":\"0\",\"adsrules_v\":\"0\",\"appid_v\":\"0\"},\"home_logo_v\":\"0\",\"goodsearch_v\":\"0\",\"promotion_v\":{\"hbanner_v\":[\"0\"]},\"prompt_v\":{\"card_v\":\"1\"},\"xcia_v\":{\"clk_v\":\"1\",\"priv_v\":\"6\"},\"newtab_v\":\"0\",\"ignore_v\":\"5.4.0.5\"}"

#define composeUpdateBodyDataSec @"{\"profile\":{\"freshers\":[{\"card_id\":\"003_%E5%AE%9E%E6%97%B6%E7%83%AD%E7%82%B9\",\"tplid\":\"3\",\"type\":\"0\",\"resource_name\":\"board\",\"csrc\":\"ext_server_pst\",\"card_key\":\"003_%E5%AE%9E%E6%97%B6%E7%83%AD%E7%82%B9\",\"interval\":\"3600\",\"query\":\"hotwords\",\"latest\":\"1404109716\",\"isrm\":\"0\",\"cue\":\"acf16107eab8f6ad9f20fd67c7ac7796\"}],\"weak_aider\":{},\"aider\":{},\"pretime\":\"1404109717\"},\"location\":\"116.174400,40.316000,---\"}"


#define UPDATE_POST_PARAM_VERSION_HEADER			@"version"
#define UPDATE_POST_PARAM_LOCATION					@"location"
#define UPDATE_POST_PARAM_BOOKMARK					@"bookmark"
#define UPDATE_POST_PARAM_PUSHSRV_HEADER            @"pushsrv"
#define POST_PARAM_DATA_HEADER                      @"data"


// 系统版本号枚举
#define IOS_2_0 @"2.0"
#define IOS_3_0 @"3.0"
#define IOS_4_0 @"4.0"
#define IOS_5_0 @"5.0"
#define IOS_6_0 @"6.0"
#define IOS_6_0_1 @"6.0.1"
#define IOS_7_0 @"7.0"
#define IOS_5_1 @"5.1"
#define IOS_5_0_1 @"5.0.1"

#define ORIGINAL_UA   @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B554a"

#define UMENG_APPKEY    @"52d369b456240b8c500ef4c1"
#define UMENG_APPSTORE  @"1099a"

#define kUUIDCheckSumBitNum		4		// 构建UUID时校验位的个数
#define kDefaultVesionValue		8		// 构建UUID时外部版本号不足4位时默认的版本号数字
#define kVerifiable_BBAUDID_Length	51 // UDID长度，不是这个长度的UDID视为非法的

#define OSNAME_VALUE            @"baiduboxapp"
#define OSBRANCH_VALUE          @"i0"
#define SEARCHBOX_SERVICE       @"bdbox"

#define UPDATE_URL_FORMAT_STRING					@"%@?action=update&network=%d&uuid=%@&%@&bim=%d&maid=%@"
#define ACTIVATION_URL_FORMAT_STRING_WITH_TYPEID	@"%@&typeid=%d" 
#define ACTIVATION_URL_FORMAT_STRING				@"%@?action=active&%@"


#define HTTP_PROTOCOL_VERSION_NUMBER						1.1f					// http协议的版本号
#define HTTP_METHOD_POST									@"POST"					// post请求方法名
#define HTTP_METHOD_GET										@"GET"					// get请求方法名
#define HTTP_HEADER_CONTENT_DISPOSITION                     @"Content-Disposition"
#define HTTP_HEADER_CONTENT_DISPOSITION_FILENAME            @"filename="
#define HTTP_HEADER_CONTENT_TYPE_KEY_NAME					@"Content-Type"			// http请求头中Content-Type字段名
#define HTTP_HEADER_CONTENT_LENGTH_KEY_NAME                 @"Content-Length"
#define HTTP_HEADER_CONTENT_TYPE_APPLICATION_OCTET_STREAM	@"application/octet-stream" // http请求头中application/octet-stream类型的Content-Type值
#define HTTP_HEADER_CONTENT_TYPE_APPLICATION_X_WWW_FORM_URLENCODED	@"application/x-www-form-urlencoded" // http请求头中application/x-www-form-urlencoded的Content-Type值



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

