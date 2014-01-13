//
//  CKMainViewController.h
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKSlidingTabBarViewController.h"

@interface CKMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CKSlidingTabBarChanging>

@property (nonatomic, retain) CKSlidingTabBarViewController *slidingTabBarVC;

@end
