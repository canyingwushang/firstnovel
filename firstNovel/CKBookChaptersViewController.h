//
//  CKBookChaptersViewController.h
//  firstNovel
//
//  Created by 张超 on 1/18/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKReaderViewController.h"

@interface CKBookChaptersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WKReaderViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *bookData;

@end
