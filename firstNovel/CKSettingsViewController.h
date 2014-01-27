//
//  CKSettingsViewController.h
//  firstNovel
//
//  Created by 张超 on 1/19/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@interface CKSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UMFeedbackDataDelegate>

@property (nonatomic, retain) UITableView *settingsTable;

@end
