//
//  CKRootViewController.h
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKMainViewController.h"

@interface CKRootViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) CKMainViewController *mainViewController;
@property (nonatomic, retain) UINavigationController *rootNaviViewController;

+ (CKRootViewController *)sharedInstance;

@end
