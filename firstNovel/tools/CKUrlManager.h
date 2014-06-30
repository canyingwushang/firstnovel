//
//  CKUrlManager.h
//  firstNovel
//
//  Created by canyingwushang on 6/30/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKUrlManager : NSObject

+ (CKUrlManager *)sharedInstance;

@property (nonatomic, retain) NSString *staticParamAndValue;

- (NSString *)getUpdateURL;
- (NSString *)getActivationURL;
- (NSString *)composeUserAgentParameter;

@end
