//
//  CKBookShelfTableViewController.m
//  firstNovel
//
//  Created by canyingwushang on 6/30/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookShelfTableViewController.h"
#import "CKBookShelfCell.h"
#import "CKZBooksManager.h"
#import "CKAppSettings.h"
#import "CKFileManager.h"
#import "CKBookDescViewController.h"
#import "CKRootViewController.h"

@interface CKBookShelfTableViewController ()

@end

@implementation CKBookShelfTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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

@end
