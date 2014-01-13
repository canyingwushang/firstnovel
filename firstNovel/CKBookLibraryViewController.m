//
//  CKBookLibraryViewController.m
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookLibraryViewController.h"
#import "CKCommonUtility.h"

@interface CKBookLibraryViewController ()

@property (nonatomic, retain) UIWebView *webView;

@end

@implementation CKBookLibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_webView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - IOS7_TOPMARGIN - TABBAR_HEIGHT)];
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.baidu.com/book"]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
