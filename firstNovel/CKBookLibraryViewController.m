//
//  CKBookLibraryViewController.m
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookLibraryViewController.h"
#import "CKCommonUtility.h"
#import "NSURL+KeyValueParsing.h"
#import "NSString-URLArguments.h"
#import "BBADownloadDataSource.h"

@interface CKBookLibraryViewController ()

@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIButton *goBackButton;
@property (nonatomic, retain) UILabel *errorLabel;

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
    [_refreshButton release];
    [_goBackButton release];
    [_errorLabel release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _webView.frame = CGRectMake(0.0f, STATUS_HEIGHT + NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - STATUS_HEIGHT - NAVIGATIONBAR_HEIGHT);
    }
    else
    {
        _webView.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT  - NAVIGATIONBAR_HEIGHT);
    }
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.baidu.com/book"]]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _goBackButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - 35.0f), 37.0f, 32.0f)];
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(278.0f, (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - 35.0f), 37.0f, 32.0f)];
    }
    else
    {
        _goBackButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - 35.0f), 37.0f, 32.0f)];
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(278.0f, (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - 35.0f), 37.0f, 32.0f)];
    }
    _goBackButton.backgroundColor = [UIColor colorWithRed:(223.0f/255.0f) green:(223.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f];
    _refreshButton.backgroundColor = [UIColor colorWithRed:(223.0f/255.0f) green:(223.0f/255.0f) blue:(223.0f/255.0f) alpha:1.0f];
    _goBackButton.alpha = 0.8f;
    _refreshButton.alpha = 0.8f;
    [_goBackButton setImage:[UIImage imageNamed:@"toolbar_goback_normal.png"] forState:UIControlStateNormal];
    [_goBackButton setImage:[UIImage imageNamed:@"toolbar_goback_highlighted.png"] forState:UIControlStateHighlighted];
    [_goBackButton addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_goBackButton];
    
    [_refreshButton setImage:[UIImage imageNamed:@"toolbar_refresh_normal.png"] forState:UIControlStateNormal];
    [_refreshButton setImage:[UIImage imageNamed:@"toolbar_refresh_highlighted.png"] forState:UIControlStateHighlighted];
    [_refreshButton addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshButton];
    
    _errorLabel = [[UILabel alloc] initWithFrame:_webView.frame];
    _errorLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    _errorLabel.text = @"很遗憾, 由于版权的问题, 我们无法再提供该服务, 我们会尽快恢复~";
    [self.view addSubview:_errorLabel];
	// Do any additional setup after loading the view.
}

- (void)goBackAction:(id)sender
{
    if ([_webView canGoBack])
    {
        [_webView goBack];
    }
}

- (void)refreshAction:(id)sender
{
    [_webView reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSDictionary *kvs = [[request URL] keysAndValuesOfQuery];
    NSString *downsrc = [kvs objectForKey:@"downsrc"];
    NSString *title = [kvs objectForKey:@"title"];
    if (CHECK_STRING_VALID(downsrc) && CHECK_STRING_VALID(title))
    {
        [[BBADownloadDataSource sharedInstance] addDownloadItemWithURL:[downsrc stringByUnescapingFromURLArgument] Title:[title stringByUnescapingFromURLArgument] businessType:EDownloadBusinessTypeNovel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_ADD_NEW_DOWNLOAD" object:nil];
        return NO;
    }
    return YES;
}

@end
