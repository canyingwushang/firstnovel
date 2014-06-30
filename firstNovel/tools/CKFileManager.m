//
//  CKFileManager.m
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import "CKFileManager.h"

@implementation CKFileManager

+ (CKFileManager *)sharedInstance
{
    static CKFileManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CKFileManager alloc] init];
    });
    return instance;
}

- (id)init
{
	self = [super init];
	if (self)
	{
        // Document Dir
		NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if (path && [path count])
		{
			_documentDir = [[path objectAtIndex:0] retain];
		}
        
        // Cache Dir
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (paths && [paths count])
        {
            _cacheDir = [[paths objectAtIndex:0] retain];
        }
        
        // Library Dir
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        if (paths && [paths count])
        {
            _libraryDir = [[paths objectAtIndex:0] retain];
        }
	}
    
	return self;
}

- (void)dealloc
{
    [_documentDir release];
    [_cacheDir release];
    RELEASE_SET_NIL(_libraryDir);
    
    [super dealloc];
}

- (NSString *)booksPlist
{
    return [[NSBundle mainBundle] pathForResource:@"list" ofType:@"plist"];
}

- (NSString *)documentBooksListFile
{
    return [_documentDir stringByAppendingPathComponent:@"list.plist"];
}

- (NSString *)bookCoverPath:(NSString *)coverName
{
    return [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"covers"] stringByAppendingPathComponent:coverName];
}

- (NSString *)bookContentPath:(NSString *)bookid
{
    return [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"content"] stringByAppendingPathComponent:[NSString stringWithFormat:@"book_%@.zip", bookid]];
}

// 迁移后的下载目录，在library下
- (NSString *)getDownloadLibraryDir
{
    return [_libraryDir stringByAppendingPathComponent:@"downloadcache"];
}


- (NSString *)bookContentCachePath:(NSString *)bookid
{
    return [_cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"book_%@", bookid]];
}

- (NSString *)getDownloadCacheDir
{
    return [_cacheDir stringByAppendingPathComponent:@"downloadcache"];
}

- (NSString *)getDownloadCacheDirForNovel
{
    return [[self getDownloadCacheDir] stringByAppendingPathComponent:@"novel"];
}

- (NSString *)getDownloadListFile
{
    return [_documentDir stringByAppendingPathComponent:@"novellist.plist"];
}

- (NSString *)getAppSettingsFile
{
    return [_documentDir stringByAppendingPathComponent:@"appsettings.plist"];
}

@end
