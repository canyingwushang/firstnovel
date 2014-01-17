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

#define CONTAINER_HEIGHT (APPLICATION_FRAME_HEIGHT - TABBAR_HEIGHT)

@interface CKMainViewController ()

@property (nonatomic, retain) UITableView *bookShelfTable;
@property (nonatomic, retain) UIView *slidingContainer;
@property (nonatomic, retain) CKBookLibraryViewController *bookLibraryViewController;

@end

@implementation CKMainViewController

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
    [_slidingTabBarVC release];
    [_bookShelfTable release];
    [_slidingContainer release];
    [_bookLibraryViewController release];
    
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
    
    self.navigationItem.title = @"名著";
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
        
    }];
}

@end
