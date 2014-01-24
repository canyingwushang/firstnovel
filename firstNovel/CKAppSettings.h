//
//  CKAppSettings.h
//  firstNovel
//
//  Created by 张超 on 1/19/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPSETTINGS_LASTVERSION     @"lastVersion"
#define APPSETTINGS_LAUNCHTIMES     @"launchTimes"

@interface CKAppSettings : NSObject

@property (nonatomic, assign) BOOL isFirstLaunchAfterUpdate;
@property (nonatomic, retain) NSString *lastVersion;
@property (nonatomic, assign) NSUInteger launchTimes;
@property (nonatomic, retain) NSDictionary *onlineParams;

+ (CKAppSettings *)sharedInstance;
- (void)saveAppSettingWithKey:(NSString *)akey Value:(id)anObject;
- (void)saveAppSettingWithDict:(NSDictionary *)aDict;

@end
