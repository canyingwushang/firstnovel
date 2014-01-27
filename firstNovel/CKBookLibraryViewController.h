//
//  CKBookLibraryViewController.h
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookLibraryViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UIWebView *webView;

- (void)refresh;
- (void)updateBookLibrarySwitch:(BOOL)ok;

@end
