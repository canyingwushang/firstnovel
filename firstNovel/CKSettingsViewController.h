//
//  CKSettingsViewController.h
//  firstNovel
//
//  Created by followcard on 1/19/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMFeedback.h"

@interface CKSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UMFeedbackDataDelegate>

@property (nonatomic, retain) UITableView *settingsTable;

@end
