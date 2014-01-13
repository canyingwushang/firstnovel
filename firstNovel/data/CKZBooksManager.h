//
//  CKZBooksManager.h
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKZBooksManager : NSObject

+ (CKZBooksManager *)sharedInstance;

- (NSArray *)books;

@end
