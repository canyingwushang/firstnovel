//
//  CKSettingsViewController.m
//  firstNovel
//
//  Created by 张超 on 1/19/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKSettingsViewController.h"
#import "CKCommonUtility.h"
#import "BBADownloadManagerViewController.h"
#import "CKRootViewController.h"
#import "BBADownloadDataSource.h"
#import "CKRootViewController.h"

enum ESettingSection {
    TSettingSectionDM = 0,
    TSettingSectionCommon,
    TSettingSectionCount
};

enum ESettingSectionDM {
    TSettingDMRowDownloadManager = 0,
    TSettingDMRowCount
};

enum ESettingSectionCommon {
    TSettingCommonRowFeedBack = 0,
    TSettingCommonRowRate,
    TSettingCommonRowCount
};

@interface CKSettingsViewController ()

@end

@implementation CKSettingsViewController

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
    [_settingsTable release];
    [UMFeedback sharedInstance].delegate = nil;;
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    
    _settingsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _settingsTable.frame = CGRectMake(0.0f, STATUS_HEIGHT + NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - STATUS_HEIGHT - NAVIGATIONBAR_HEIGHT);
    }
    else
    {
        _settingsTable.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT  - NAVIGATIONBAR_HEIGHT);
    }
    _settingsTable.dataSource = self;
    _settingsTable.delegate = self;
    _settingsTable.allowsMultipleSelection = NO;
    _settingsTable.allowsSelectionDuringEditing = NO;
    _settingsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _settingsTable.backgroundColor = [UIColor clearColor];
    _settingsTable.backgroundView = [[[UIView alloc] init] autorelease];
    [self.view addSubview:_settingsTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UMFeedback sharedInstance] setAppkey:UMENG_APPKEY delegate:self];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    //cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == TSettingSectionDM)
    {
        cell.textLabel.text = @"下载的小说";
        cell.imageView.image = [UIImage imageNamed:@"settings_download.png"];
        if ([[BBADownloadDataSource sharedInstance] totalCount] > 0)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[BBADownloadDataSource sharedInstance] totalCount]];
        }
    }
    else if (indexPath.section == TSettingSectionCommon)
    {
        if (indexPath.row == TSettingCommonRowFeedBack)
        {
            cell.textLabel.text = @"给点建议";
            cell.imageView.image = [UIImage imageNamed:@"settings_feedback.png"];
        }
        else if (indexPath.row == TSettingCommonRowRate)
        {
            cell.textLabel.text = @"给应用评分";
            cell.imageView.image = [UIImage imageNamed:@"settings_rate.png"];
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TSettingSectionDM && indexPath.row == TSettingDMRowDownloadManager)
    {
        BBADownloadManagerViewController *downloadViewController = [[BBADownloadManagerViewController alloc] init];
        [[CKRootViewController sharedInstance].rootNaviViewController pushViewController:downloadViewController animated:YES];
        [downloadViewController release];
        
        [MobClick event:@"settingsDownload"];
    }
    else if (indexPath.section == TSettingSectionCommon && indexPath.row == TSettingCommonRowFeedBack)
    {
        [MobClick event:@"settingsFeedback"];
        [UMFeedback showFeedback:[CKRootViewController sharedInstance] withAppkey:UMENG_APPKEY];
    }
    else if (indexPath.section == TSettingSectionCommon && indexPath.row == TSettingCommonRowRate)
    {
        [MobClick event:@"settingsRate"];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TSettingSectionDM)
    {
        return TSettingDMRowCount;
    }
    else if (section == TSettingSectionCommon)
    {
        return TSettingCommonRowCount;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TSettingSectionCount;
}

- (void)getFinishedWithError: (NSError *)error
{
    NSLog(@"%@", error);
}

- (void)postFinishedWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
