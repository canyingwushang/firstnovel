//
//  CKMainViewController.h
//  firstNovel
//
//  Created by followcard on 1/12/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKSlidingTabBarViewController.h"

@interface CKMainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CKSlidingTabBarChanging>

@property (nonatomic, retain) CKSlidingTabBarViewController *slidingTabBarVC;

@end
