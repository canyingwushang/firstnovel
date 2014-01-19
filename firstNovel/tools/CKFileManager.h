//
//  CKFileManager.h
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKFileManager : NSObject

+ (CKFileManager *)sharedInstance;

@property (nonatomic, retain) NSString *documentDir;
@property (nonatomic, retain) NSString *cacheDir;

- (NSString *)booksPlist;
- (NSString *)bookCoverPath:(NSString *)coverName;
- (NSString *)bookContentPath:(NSString *)bookid;
- (NSString *)bookContentCachePath:(NSString *)bookid;

- (NSString *)getDownloadCacheDir;
- (NSString *)getDownloadCacheDirForNovel;
- (NSString *)getDownloadListFile;

@end
