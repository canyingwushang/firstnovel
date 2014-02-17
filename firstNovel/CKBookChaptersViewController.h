//
//  CKBookChaptersViewController.h
//  firstNovel
//
//  Created by followcard on 1/18/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKReaderViewController.h"

@interface CKBookChaptersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WKReaderViewControllerDelegate>

@property (nonatomic, retain) NSDictionary *bookData;

@end
