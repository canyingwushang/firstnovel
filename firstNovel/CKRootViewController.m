//
//  CKRootViewController.m
//  firstNovel
//
//  Created by 张超 on 1/11/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKRootViewController.h"
#import "CKCommonUtility.h"
#import "CKZBooksManager.h"
#import "WKReaderConfig.h"
#import "CKFileManager.h"
#import "CKAppSettings.h"

@interface CKRootViewController ()

@end

@implementation CKRootViewController

+ (CKRootViewController *)sharedInstance
{
    static CKRootViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CKRootViewController alloc] init];
    });
    return instance;
}

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
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    
    CKMainViewController *tmpMainViewController = [[CKMainViewController alloc] init];
    tmpMainViewController.view.frame = self.view.bounds;
    self.mainViewController = tmpMainViewController;
    [tmpMainViewController release];
    
    UINavigationController *naviViewController = [[UINavigationController alloc] initWithRootViewController:_mainViewController];
    naviViewController.view.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT);
    [self.view addSubview:naviViewController.view];
    self.rootNaviViewController = naviViewController;
    [naviViewController release];
    
    // 文库sdk配置
    //[WKReaderConfig setDatabaseFolderPath:@"Library/WKSDKDatabase"];
    [WKReaderConfig setCUID:@"DSFAJHFADEHJQHFJEWHFJKDSAHFKJSDAH1289"];
    
    if ([[CKAppSettings sharedInstance] launchTimes] == 3)
    {
        [self showRateAlert];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _rootNaviViewController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor, nil];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        [_rootNaviViewController.navigationBar setBarTintColor:[UIColor colorWithRed:(232.0f/255.0f) green:(222.0f/255.0f) blue:(203.0f/255.0f) alpha:1.0f]];
    }
    else
    {
        [_rootNaviViewController.navigationBar setBackgroundImage:[UIImage imageNamed:@"toolbar_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRateAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新年快乐" message:@"业余时间搞了这个应用, 献给那些爱读书的朋友, 绝无广告~" delegate:self cancelButtonTitle:@"飘过" otherButtonTitles:@"赞一个", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ;
}

@end
