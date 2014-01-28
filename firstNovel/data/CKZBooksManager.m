//
//  CKZBooksManager.m
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKZBooksManager.h"
#import "CKFileManager.h"
#import "CKCommonUtility.h"
#import "ZipArchive.h"
#import "CKAppSettings.h"

@interface CKZBooksManager ()

@property (nonatomic, retain) NSMutableArray *localBooks;

@end

@implementation CKZBooksManager

+ (CKZBooksManager *)sharedInstance
{
    static CKZBooksManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CKZBooksManager alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [_localBooks release];
    
    [super dealloc];
}

- (NSArray *)books
{
    @synchronized(self)
    {
        if (_localBooks == nil)
        {
            _localBooks = [[NSMutableArray array] retain];
            NSString *booksListFile = [[CKFileManager sharedInstance] documentBooksListFile];
            if (![[NSFileManager defaultManager] fileExistsAtPath:booksListFile])
            {
                booksListFile = [[CKFileManager sharedInstance] booksPlist];
            }
            [_localBooks addObjectsFromArray:[NSArray arrayWithContentsOfFile:booksListFile]];
            if ([CKAppSettings sharedInstance].lastReadIndex > 0 && [CKAppSettings sharedInstance].lastReadIndex < _localBooks.count)
            {
                id lastReadObj = [_localBooks objectAtIndex:[CKAppSettings sharedInstance].lastReadIndex];
                [_localBooks exchangeObjectAtIndex:0 withObjectAtIndex:[CKAppSettings sharedInstance].lastReadIndex];
            }
        }
        return [[_localBooks retain] autorelease];
    }
}

- (NSString *)unzipBookChapters:(NSString *)bookID
{
    if (CHECK_STRING_INVALID(bookID)) return nil;
    
    NSString *cacheBookDir = [[CKFileManager sharedInstance] bookContentCachePath:bookID];
    NSString *chapertsFilePath = [cacheBookDir stringByAppendingPathComponent:@"chapters.text"];
    BOOL isDir = NO;
    if (!([[NSFileManager defaultManager] fileExistsAtPath:cacheBookDir isDirectory:&isDir] && isDir && [[NSFileManager defaultManager] fileExistsAtPath:chapertsFilePath]))
    {
        NSString *zipBookPath = [[CKFileManager sharedInstance] bookContentPath:bookID];
        if ([[NSFileManager defaultManager] fileExistsAtPath:zipBookPath])
        {
            NSString *cacheZipBookPath = [[[CKFileManager sharedInstance] cacheDir] stringByAppendingPathComponent:[zipBookPath lastPathComponent]];
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:zipBookPath toPath:cacheZipBookPath error:&error];
            ZipArchive *zipArchive = [[ZipArchive alloc] init];
            [zipArchive UnzipOpenFile:cacheZipBookPath Password:@"ck"];
            [zipArchive UnzipFileTo:[[CKFileManager sharedInstance] cacheDir] overWrite:YES];
            [zipArchive UnzipCloseFile];
            [[NSFileManager defaultManager] removeItemAtPath:cacheZipBookPath error:&error];
        }
        else
        {
            cacheBookDir = nil;
        }
    }
    return cacheBookDir;
}

- (void)dealBooksData
{
    NSString *listFile = [[CKFileManager sharedInstance].documentDir stringByAppendingPathComponent:@"list"];
    NSArray *books = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:listFile] options:0 error:nil];
    NSMutableArray *mutableBooks = [NSMutableArray array];
    NSUInteger index = 0;
    for (NSDictionary *book in books)
    {
        NSMutableDictionary *mutableBook = [NSMutableDictionary dictionary];
        [mutableBook setDictionary:book];
        
        // 删除多余字段
        [mutableBook removeObjectForKey:@"catid"];
        [mutableBook removeObjectForKey:@"iscommend"];
        [mutableBook removeObjectForKey:@"isdown"];
        
        // 生成新的id
        NSString *bookid = [mutableBook objectForKey:@"id"];
        NSString *newbookid = [NSString stringWithFormat:@"%04d", index];
        [mutableBook setObject:newbookid forKey:@"id"];
        
        // desc替换
        NSString *desc = [mutableBook objectForKey:@"desc"];
        desc = [desc stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
        desc = [desc stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        desc = [desc stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
        desc = [desc stringByReplacingOccurrencesOfString:@"&rdquo;;" withString:@"“"];
        [mutableBook setObject:desc forKey:@"desc"];
        
        // 替换图片
        NSString *cover = [mutableBook objectForKey:@"cover"];
        NSString *name = [mutableBook objectForKey:@"bookname"];
        NSString *coverPath = [[[CKFileManager sharedInstance].documentDir stringByAppendingPathComponent:@"covers"] stringByAppendingPathComponent:cover];
        if ([[NSFileManager defaultManager] fileExistsAtPath:coverPath])
        {
            NSString *coverNewName = [NSString stringWithFormat:@"%@.png", [CKCommonUtility md5:[NSString stringWithFormat:@"%@%ld", name, (long)([[NSDate date] timeIntervalSince1970])]]];
            NSString *coverNewPath = [[[[CKFileManager sharedInstance] documentDir] stringByAppendingPathComponent:@"covers"] stringByAppendingPathComponent:coverNewName];
            [[NSFileManager defaultManager] moveItemAtPath:coverPath toPath:coverNewPath error:nil];
            [mutableBook setObject:coverNewName forKey:@"cover"];
        }
        
        // 处理图书的内容
        NSString *bookdir = [[[[CKFileManager sharedInstance] documentDir] stringByAppendingPathComponent:@"content"] stringByAppendingPathComponent:[NSString stringWithFormat:@"book_%@", bookid]];
        NSString *newbookdir = [[[[CKFileManager sharedInstance] documentDir] stringByAppendingPathComponent:@"content"] stringByAppendingPathComponent:[NSString stringWithFormat:@"book_%@", newbookid]];
        [[NSFileManager defaultManager] moveItemAtPath:bookdir toPath:newbookdir error:nil];
        NSString *chaptersPath = [newbookdir stringByAppendingPathComponent:@"chapters.txt"];
        NSDictionary *chaptersDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:chaptersPath] options:0 error:nil];
        NSArray *chaptersArray = [chaptersDict objectForKey:@"chapters"];
        for (NSDictionary *chapter in chaptersArray)
        {
            NSString *chapterid = [chapter objectForKey:@"id"];
            NSString *chapterPath = [newbookdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", chapterid]];
            NSDictionary *chapterDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:chapterPath] options:0 error:nil];
            NSString *chapterContent = [chapterDict objectForKey:@"content"];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"“"];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"<p>　　" withString:@""];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
            chapterContent = [chapterContent stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
            [chapterContent writeToFile:chapterPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        NSString *zipPath = [newbookdir stringByAppendingPathExtension:@"zip"];
        
        ZipArchive *zip = [[ZipArchive alloc] init];
        [zip CreateZipFile2:zipPath Password:@"ck"];
        [zip addFileToZip:newbookdir newname:[newbookdir lastPathComponent]];
        [zip CloseZipFile2];
        [zip release];
        
        index++;
        [mutableBooks addObject:mutableBook];
    }
    NSString *listPlist = [[CKFileManager sharedInstance].documentDir stringByAppendingPathComponent:@"list.plist"];
    [mutableBooks writeToFile:listPlist atomically:YES];
}

@end
