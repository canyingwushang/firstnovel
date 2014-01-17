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

@end
