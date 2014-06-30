//
//  CKRootViewController.m
//  firstNovel
//
//  Created by followcard on 1/11/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import "CKRootViewController.h"
#import "CKCommonUtility.h"
#import "CKZBooksManager.h"
#import "WKReaderConfig.h"
#import "CKFileManager.h"
#import "CKAppSettings.h"
#import "Reachability.h"
#import "BBAUpdateManager.h"
#import "BBAActivationManager.h"

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
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
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
    
    [BBAActivationManager doActivation];
    
    [[BBAUpdateManager sharedInstance] sendUpdateRequest];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showRateAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"马上有钱" message:@"业余时间搞了这个应用, 送给那些爱读书的朋友们,【绝无广告】,你觉得如何?" delegate:self cancelButtonTitle:@"飘过" otherButtonTitles:@"赞一个", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [MobClick event:@"rateAlertNO"];
    }
    else if (buttonIndex == 1)
    {
        [MobClick event:@"rateAlertOK"];
        [CKCommonUtility goRating];
    }
}

- (void)reachabilityChanged:(NSNotification *)aNotification
{
    Reachability* curReach = [aNotification object];
    if ([curReach currentReachabilityStatus] != kReachableViaWWAN && [curReach currentReachabilityStatus] != kReachableViaWiFi)
    {
        dispatch_async(GCD_MAIN_QUEUE, ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络不给力" message:@"貌似断网了哎, 去检查一下吧" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
}

@end
