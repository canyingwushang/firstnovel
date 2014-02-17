//
//  CKBookLibraryViewController.h
//  firstNovel
//
//  Created by followcard on 1/12/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookLibraryViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) UIWebView *webView;

- (void)refresh;
- (void)updateBookLibrarySwitch:(BOOL)ok;

@end
