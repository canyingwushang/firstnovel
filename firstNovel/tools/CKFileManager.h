//
//  CKFileManager.h
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKFileManager : NSObject

+ (CKFileManager *)sharedInstance;

@property (nonatomic, retain) NSString *documentDir;
@property (nonatomic, retain) NSString *cacheDir;
@property (nonatomic, retain) NSString *libraryDir;

- (NSString *)booksPlist;
- (NSString *)documentBooksListFile;
- (NSString *)bookCoverPath:(NSString *)coverName;
- (NSString *)bookContentPath:(NSString *)bookid;
- (NSString *)bookContentCachePath:(NSString *)bookid;

- (NSString *)getDownloadLibraryDir;
- (NSString *)getDownloadCacheDir;
- (NSString *)getDownloadCacheDirForNovel;
- (NSString *)getDownloadListFile;

- (NSString *)getAppSettingsFile;
- (NSString *)getSDKUIDFilePath;

- (NSString *)getActivationFilePath;

@end
