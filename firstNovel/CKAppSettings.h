//
//  CKAppSettings.h
//  firstNovel
//
//  Created by 张超 on 1/19/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APPSETTINGS_LASTVERSION         @"lastVersion"
#define APPSETTINGS_LAUNCHTIMES         @"launchTimes"
#define APPSETTINGS_SHOWN_DOWNLOADTIP   @"hasShownDownloadTip"
#define APPSETTINGS_LASTREAD_INDEX      @"lastReadIndex"

@interface CKAppSettings : NSObject

@property (nonatomic, assign) BOOL isFirstLaunchAfterUpdate;
@property (nonatomic, retain) NSString *lastVersion;
@property (nonatomic, assign) NSUInteger launchTimes;
@property (nonatomic, retain) NSDictionary *onlineParams;
@property (nonatomic, assign) BOOL hasShownDownloadTip;
@property (nonatomic, assign) NSInteger lastReadIndex;

+ (CKAppSettings *)sharedInstance;
- (void)saveAppSettingWithKey:(NSString *)akey Value:(id)anObject;
- (void)saveAppSettingWithDict:(NSDictionary *)aDict;
- (BOOL)onlineBookLibraryAvaiable;
- (BOOL)onlineBookLibraryDownloadAvaiable;
- (BOOL)onlineBookLibrarySexAvaiable;

@end
