//
//  CKZBooksManager.h
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKZBooksManager : NSObject

+ (CKZBooksManager *)sharedInstance;

- (NSArray *)books;

- (NSString *)unzipBookChapters:(NSString *)bookID;

@end
