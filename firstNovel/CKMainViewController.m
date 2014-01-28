//
//  CKMainViewController.m
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKMainViewController.h"
#import "CKCommonUtility.h"
#import "CKZBooksManager.h"
#import "CKBookShelfCell.h"
#import "CKFileManager.h"
#import "CKBookLibraryViewController.h"
#import "CKBookDescViewController.h"
#import "CKRootViewController.h"
#import "CKSettingsViewController.h"
#import "CKAppSettings.h"

@interface CKMainViewController ()

@property (nonatomic, retain) UITableView *bookShelfTable;
@property (nonatomic, retain) UIView *slidingContainer;
@property (nonatomic, retain) CKBookLibraryViewController *bookLibraryViewController;
@property (nonatomic, retain) CKSettingsViewController *settingsViewController;
@property (nonatomic, retain) UIImageView *newTaskPoint;

@end

@implementation CKMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewPoint) name:@"NOTIFICATION_ADD_NEW_DOWNLOAD" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFICATION_ADD_NEW_DOWNLOAD" object:nil];
    
    [_slidingTabBarVC release];
    [_bookShelfTable release];
    [_slidingContainer release];
    [_bookLibraryViewController release];
    [_settingsViewController release];
    [_newTaskPoint release];
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    _slidingContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0f, APPLICATION_FRAME_WIDTH * 3, APPLICATION_FRAME_HEIGHT)];
    _slidingContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    [self.view addSubview:_slidingContainer];
    
    CKSlidingTabBarViewController *tmpSlidingTabBarVC = [[CKSlidingTabBarViewController alloc] init];
    self.slidingTabBarVC = tmpSlidingTabBarVC;
    tmpSlidingTabBarVC.delegate = self;
    [self.view addSubview:tmpSlidingTabBarVC.view];
    NSMutableArray *dataArray = [NSMutableArray array];
    NSDictionary *bookShelfDict = [NSDictionary dictionaryWithObjectsAndKeys:@"书架", TABBAR_ITEM_KEY_TITLE, @"tabbar_book_shelf.png", TABBAR_ITEM_KEY_ICON_NORNAL, @"tabbar_book_shelf_hl.png", TABBAR_ITEM_KEY_ICON_HIGHLIGHTED, nil];
    NSDictionary *bookLibraryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"书城", TABBAR_ITEM_KEY_TITLE, @"tabbar_book_library.png", TABBAR_ITEM_KEY_ICON_NORNAL, @"tabbar_book_library_hl.png", TABBAR_ITEM_KEY_ICON_HIGHLIGHTED, nil];
    NSDictionary *moreDict = [NSDictionary dictionaryWithObjectsAndKeys:@"更多", TABBAR_ITEM_KEY_TITLE, @"tabbar_pandora_box.png", TABBAR_ITEM_KEY_ICON_NORNAL, @"tabbar_pandora_box_hl.png", TABBAR_ITEM_KEY_ICON_HIGHLIGHTED, nil];
    [dataArray addObject:bookShelfDict];
    [dataArray addObject:bookLibraryDict];
    [dataArray addObject:moreDict];
    [tmpSlidingTabBarVC drawViewWithDataArray:dataArray];
    [tmpSlidingTabBarVC release];
    _slidingTabBarVC.view.frame = CGRectMake(0.0f, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT, APPLICATION_FRAME_WIDTH, TABBAR_HEIGHT);
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _slidingTabBarVC.view.frame = CGRectMake(0.0f, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, TABBAR_HEIGHT + NAVIGATIONBAR_HEIGHT);
    }
    _slidingTabBarVC.view.clipsToBounds = YES;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGFloat tableHeight = CONTAINER_HEIGHT;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        tableHeight -= NAVIGATIONBAR_HEIGHT;
    }
    _bookShelfTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, tableHeight)];
    _bookShelfTable.dataSource = self;
    _bookShelfTable.delegate = self;
    _bookShelfTable.allowsMultipleSelection = NO;
    _bookShelfTable.allowsSelectionDuringEditing = NO;
    _bookShelfTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _bookShelfTable.backgroundColor = [UIColor clearColor];
    [_slidingContainer addSubview:_bookShelfTable];
    
    
    _bookLibraryViewController = [[CKBookLibraryViewController alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _bookLibraryViewController.view.frame = CGRectMake(APPLICATION_FRAME_WIDTH, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT );
    }
    else
    {
        _bookLibraryViewController.view.frame = CGRectMake(APPLICATION_FRAME_WIDTH, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT);
    }
    _bookLibraryViewController.view.clipsToBounds = YES;
    [_slidingContainer addSubview:_bookLibraryViewController.view];
    
    
    _settingsViewController = [[CKSettingsViewController alloc] init];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _settingsViewController.view.frame = CGRectMake(2*APPLICATION_FRAME_WIDTH, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT );
    }
    else
    {
        _settingsViewController.view.frame = CGRectMake(2*APPLICATION_FRAME_WIDTH, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT);
    }
    _settingsViewController.view.clipsToBounds = YES;
    [_slidingContainer addSubview:_settingsViewController.view];
    
    self.navigationItem.title = @"名著";
    
    _newTaskPoint = [[UIImageView alloc] initWithFrame:CGRectMake(280.0f, 5.0f, 18.0f, 18.0f)];
    _newTaskPoint.image = [UIImage imageNamed:@"common_list_new.png"];
    [_slidingTabBarVC.view addSubview:_newTaskPoint];
    _newTaskPoint.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNewPoint
{
    _newTaskPoint.hidden = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier111";
    CKBookShelfCell *cell=(CKBookShelfCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:@"CKBookShelfCell" owner:self options:nil];
        cell = (CKBookShelfCell*)[nibsArray objectAtIndex:0];
    }
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    NSDictionary *book = [[[CKZBooksManager sharedInstance] books] objectAtIndex:indexPath.row];
    NSString *coverName = [book objectForKey:@"cover"];
    cell.bookCover.image = [UIImage imageWithContentsOfFile:[[CKFileManager sharedInstance] bookCoverPath:coverName]];
    NSString *bookName = [book objectForKey:@"bookname"];
    cell.bookName.text = bookName;
    NSString *bookAuthor = [book objectForKey:@"author"];
    cell.bookAuthor.text = bookAuthor;
    NSString *bookDesc = [book objectForKey:@"desc"];
    cell.bookDesc.text = bookDesc;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKBookDescViewController *bookDescViewController = [[CKBookDescViewController alloc] initWithNibName:@"CKBookDesc" bundle:nil];
    NSDictionary *book = [[[CKZBooksManager sharedInstance] books] objectAtIndex:indexPath.row];
    [CKAppSettings sharedInstance].lastReadIndex = indexPath.row;
    bookDescViewController.bookData = book;
    [[CKRootViewController sharedInstance].rootNaviViewController pushViewController:bookDescViewController animated:YES];
    [bookDescViewController autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [CKZBooksManager sharedInstance].books.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.0f;
}

- (void)tabBarChangeFrom:(NSUInteger) fromIndex to:(NSUInteger)toIndex
{
    [UIView animateWithDuration:0.5 animations:^{
        _slidingContainer.frame = CGRectMake(-APPLICATION_FRAME_WIDTH *toIndex, 0.0f, APPLICATION_FRAME_WIDTH * 3, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT);
    } completion:^(BOOL finished) {
        if (toIndex == 0)
        {
            self.navigationItem.title = @"名著";
        }
        else if (toIndex == 1)
        {
            self.navigationItem.title = @"在线书城";
            [_bookLibraryViewController updateBookLibrarySwitch:[[CKAppSettings sharedInstance] onlineBookLibraryAvaiable]];
            [_bookLibraryViewController refresh];
        }
        else if (toIndex == 2)
        {
            self.navigationItem.title = @"更多设置";
        }
        
        if (toIndex == 1)
        {
            [[CKRootViewController sharedInstance].rootNaviViewController setNavigationBarHidden:YES animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
                {
                    _bookLibraryViewController.webView.frame = CGRectMake(0.0f, STATUS_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - STATUS_HEIGHT);
                }
                else
                {
                    _bookLibraryViewController.webView.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT);
                    _slidingTabBarVC.view.frame = CGRectMake(0.0f, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT, APPLICATION_FRAME_WIDTH, TABBAR_HEIGHT + NAVIGATIONBAR_HEIGHT);
                }
            } completion:^(BOOL finished) {
                ;
            }];
        }
        else
        {
            [[CKRootViewController sharedInstance].rootNaviViewController setNavigationBarHidden:NO animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
                {
                    _bookLibraryViewController.webView.frame = CGRectMake(0.0f, STATUS_HEIGHT + NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - STATUS_HEIGHT - NAVIGATIONBAR_HEIGHT);
                }
                else
                {
                    _bookLibraryViewController.webView.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT  - NAVIGATIONBAR_HEIGHT);
                    _slidingTabBarVC.view.frame = CGRectMake(0.0f, APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, TABBAR_HEIGHT + NAVIGATIONBAR_HEIGHT);
                }
            } completion:^(BOOL finished) {
                ;
            }];
        }
        
    }];
    
    if (toIndex == 2)
    {
        _newTaskPoint.hidden = YES;
        [_settingsViewController.settingsTable reloadData];
    }
    
    if (toIndex == 0)
    {
        [MobClick event:@"tabBookShelf"];
    }
    else if (toIndex == 1)
    {
        [MobClick event:@"tabBookLibrary"];
    }
    else if (toIndex == 2)
    {
        [MobClick event:@"tabSettings"];
    }
}

@end
