//
//  CKBookChaptersViewController.m
//  firstNovel
//
//  Created by 张超 on 1/18/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookChaptersViewController.h"
#import "CKZBooksManager.h"
#import "CKCommonUtility.h"
#import "WKReaderSwitch.H"
#import "CKRootViewController.h"

@interface CKBookChaptersViewController ()

@property (nonatomic, retain) UITableView *chaptersTable;
@property (nonatomic, retain) NSMutableArray *chaptersArray;
@property (nonatomic, retain) UIActivityIndicatorView *loadingView;
@property (nonatomic, retain) NSString *bookDir;
@property (nonatomic, retain) WKReaderViewController *novelReaderViewController;

@end

@implementation CKBookChaptersViewController

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
    [_chaptersTable release];
    [_chaptersArray release];
    [_bookData release];
    [_loadingView release];
    [_bookDir release];
    [_novelReaderViewController release];
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    NSString *title = [_bookData objectForKey:@"bookname"];
    if (CHECK_STRING_INVALID(title))
    {
        title = @"章节";
    }
    
    self.navigationItem.title = title;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    
    CGRect tableFrame = CGRectMake(STATUS_HEIGHT / 2, STATUS_HEIGHT / 2, APPLICATION_FRAME_WIDTH - STATUS_HEIGHT, APPLICATION_FRAME_HEIGHT - STATUS_HEIGHT);
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        tableFrame = CGRectMake(STATUS_HEIGHT / 2, STATUS_HEIGHT / 2, APPLICATION_FRAME_WIDTH - STATUS_HEIGHT, APPLICATION_FRAME_HEIGHT - STATUS_HEIGHT - NAVIGATIONBAR_HEIGHT);
    }
    
    _chaptersTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    _chaptersTable.dataSource = self;
    _chaptersTable.delegate = self;
    _chaptersTable.backgroundColor = [UIColor clearColor];
    _chaptersTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_chaptersTable];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingView.frame = CGRectMake((APPLICATION_FRAME_WIDTH - 30.0f)/2, 200.0f, 30.0f, 30.0f);
    [self.view addSubview:_loadingView];
    [_loadingView startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @try
    {
        dispatch_async(GCD_GLOBAL_QUEUQ, ^{
            NSString *bookDir = [[CKZBooksManager sharedInstance] unzipBookChapters:[_bookData objectForKey:@"id"]];
            if (CHECK_STRING_INVALID(bookDir)) return;
            self.bookDir = bookDir;
            NSString *chaptersFilePath = [bookDir stringByAppendingPathComponent:@"chapters.txt"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:chaptersFilePath])
            {
                NSData *chaptersData = [NSData dataWithContentsOfFile:chaptersFilePath];
                if (chaptersData != nil)
                {
                    NSDictionary *chapertsDict = [NSJSONSerialization JSONObjectWithData:chaptersData options:0 error:nil];
                    self.chaptersArray = [chapertsDict objectForKey:@"chapters"];
                    dispatch_async(GCD_MAIN_QUEUE, ^{
                        if (_chaptersArray == nil || _chaptersArray.count == 0)
                        {
                            [self showErrorAlert];
                        }
                        else
                        {
                            [_chaptersTable reloadData];
                            [_loadingView stopAnimating];
                        }
                    });
                }
            }
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    //[MobClick beginEvent:@"bookShelfReadTime" label:[_bookData objectForKey:@"bookname"]];
    
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[MobClick endEvent:@"bookShelfReadTime" label:[_bookData objectForKey:@"bookname"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showErrorAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不是吧" message:@"这本书的章节莫名其妙的丢失了, 要不你清理下缓存试试" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"chaptersCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor clearColor];
        cell.imageView.image = [UIImage imageNamed:@"chapter_icon_novel.png"];
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    NSDictionary *chapterDict = [_chaptersArray objectAtIndex:indexPath.row];
    if (chapterDict == nil) return nil;
    NSString *chapterName = [chapterDict objectForKey:@"title"];
    cell.textLabel.text = chapterName;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *chapterDict = [_chaptersArray objectAtIndex:indexPath.row];
    NSString *chapterName = [chapterDict objectForKey:@"title"];
    NSString *chapterFileName = [[chapterDict objectForKey:@"id"]stringByAppendingPathExtension:@"txt"];
    NSString *chapterFilePath = [_bookDir stringByAppendingPathComponent:chapterFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:chapterFilePath]) return;
    
    self.novelReaderViewController = [WKReaderSwitch openBookWithFile:chapterFilePath fileName:chapterName fileType:@"txt" pushAnimation:NO];
    _novelReaderViewController.readerViewControllerDelegate = self;
    [[CKRootViewController sharedInstance] presentViewController:_novelReaderViewController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _chaptersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (void)wkReaderViewController:(WKReaderViewController *)readerViewController backAtPercentage:(CGFloat)percentage
{
    [_novelReaderViewController dismissViewControllerAnimated:YES completion:nil];
    self.novelReaderViewController = nil;
}

- (void)addNavigationBarLeftButton
{
    ;
}

@end
