//
//  CKBookLibraryViewController.m
//  firstNovel
//
//  Created by followcard on 1/12/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import "CKBookLibraryViewController.h"
#import "CKCommonUtility.h"
#import "NSURL+KeyValueParsing.h"
#import "NSString-URLArguments.h"
#import "BBADownloadDataSource.h"
#import "CKAppSettings.h"

#define DOWNLOAD_ALERT_TAG  1111111
#define DOWNLOAD_ALERT_TIP  1111112

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
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ONLINEBOOKS_ADDRESS]]];
    
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
    
    CGRect webViewFrame = _webView.frame;
    _errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, webViewFrame.origin.y, webViewFrame.size.width - 100.0f, webViewFrame.size.height)];
    _errorLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    _errorLabel.numberOfLines = 5;
    _errorLabel.text = @"很遗憾, 由于版权的问题, 我们无法再提供该服务, 我们会尽快恢复~";
    [self.view addSubview:_errorLabel];
    _webView.hidden = NO;
    _errorLabel.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)updateBookLibrarySwitch:(BOOL)ok
{
    _webView.hidden = !ok;
    _errorLabel.hidden = ok;
}

- (void)goBackAction:(id)sender
{
    if ([_webView canGoBack])
    {
        [_webView goBack];
    }
}

- (void)refresh
{
    [self refreshAction:nil];
}

- (void)refreshAction:(id)sender
{
    NSURL *url = [_webView request].URL;
    if ([url host] != nil)
    {
        [_webView reload];
    }
    else
    {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ONLINEBOOKS_ADDRESS]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![[CKAppSettings sharedInstance] onlineBookLibrarySexAvaiable])
    {
        [self removeHTMLElements:webView];
        
        if ([request.URL.absoluteString rangeOfString:@"#recommend"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"#cates"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"book_search"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"book_pocket"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"pocket?"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"word="].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"tj=book_store"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"book?"].location != NSNotFound)
        {
            return NO;
        }
        if ([request.URL.absoluteString rangeOfString:@"zhidao.baidu.com/mmisc/senovel?"].location != NSNotFound)
        {
            return NO;
        }
    }
    
    NSDictionary *kvs = [[request URL] keysAndValuesOfQuery];
    NSString *downsrc = [kvs objectForKey:@"downsrc"];
    NSString *title = [kvs objectForKey:@"title"];
    if (CHECK_STRING_VALID(downsrc) && CHECK_STRING_VALID(title))
    {
        if ([[CKAppSettings sharedInstance] onlineBookLibraryDownloadAvaiable])
        {
            [[BBADownloadDataSource sharedInstance] addDownloadItemWithURL:[downsrc stringByUnescapingFromURLArgument] Title:[title stringByUnescapingFromURLArgument] businessType:EDownloadBusinessTypeNovel];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_ADD_NEW_DOWNLOAD" object:nil];
            if (![[CKAppSettings sharedInstance] hasShownDownloadTip])
            {
                [self showDownloadTip];
            }
        }
        else
        {
            [self showDownloadAlert];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (![[CKAppSettings sharedInstance] onlineBookLibrarySexAvaiable])
    {
        [self removeHTMLElements:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (![[CKAppSettings sharedInstance] onlineBookLibrarySexAvaiable])
    {
        [self removeHTMLElements:webView];
    }
}

- (void)removeHTMLElements:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:KJSDeleteElementByID(@"icoSearch")];
    [webView stringByEvaluatingJavaScriptFromString:KJSDeleteElementByID(@"backPocket")];
    [webView stringByEvaluatingJavaScriptFromString:KJSDeleteElementByID(@"store_recommend")];
    [webView stringByEvaluatingJavaScriptFromString:KJSDeleteElementByID(@"store_cates")];
}

- (void)showDownloadTip
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友好提醒" message:@"看, 底下的更多有一个红点, 点进去就能看见你下载的小说" delegate:self cancelButtonTitle:@"去看看" otherButtonTitles:nil];
    alert.tag = DOWNLOAD_ALERT_TIP;
    [alert show];
    [alert release];
}

- (void)showDownloadAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"抱歉" message:@"很遗憾, 由于版权的问题, 我们无法再提供该服务, 我们会尽快恢复~" delegate:self cancelButtonTitle:@"好吧" otherButtonTitles:nil];
    alert.tag = DOWNLOAD_ALERT_TAG;
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DOWNLOAD_ALERT_TIP)
    {
        if (buttonIndex == 0)
        {
            [[CKAppSettings sharedInstance] saveAppSettingWithKey:APPSETTINGS_SHOWN_DOWNLOADTIP Value:[NSNumber numberWithBool:YES]];
        }
    }
}

@end
