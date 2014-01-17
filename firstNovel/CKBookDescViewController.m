//
//  CKBookDescViewController.m
//  firstNovel
//
//  Created by canyingwushang on 1/17/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookDescViewController.h"
#import "CKFileManager.h"
#import "CKCommonUtility.h"

@interface CKBookDescViewController ()

@end

@implementation CKBookDescViewController

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
    [_bookData release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"详情";
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bg.png"]];
    _backView.backgroundColor = [UIColor clearColor];
    _bookDesc.backgroundColor = [UIColor clearColor];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(IOS_7_0))
    {
        _backView.frame = CGRectMake(0.0f, STATUS_HEIGHT + NAVIGATIONBAR_HEIGHT, APPLICATION_FRAME_WIDTH, APPLICATION_FRAME_HEIGHT);
    }
    
    if ([CKCommonUtility isiPhone5])
    {
        _bookDesc.frame = CGRectMake(20.0f, 174.0f, 280.0f, 300.0f);
    }
    else
    {
        _bookDesc.frame = CGRectMake(20.0f, 174.0f, 280.0f, 210.0f);
    }
    
    NSString *coverName = [_bookData objectForKey:@"cover"];
    _bookCover.image = [UIImage imageWithContentsOfFile:[[CKFileManager sharedInstance] bookCoverPath:coverName]];
    NSString *bookName = [_bookData objectForKey:@"bookname"];
    _bookName.text = bookName;
    NSString *bookAuthor = [_bookData objectForKey:@"author"];
    _bookAuthor.text = [NSString stringWithFormat:@"作者：%@", bookAuthor];
    NSString *bookDesc = [_bookData objectForKey:@"desc"];
    _bookDesc.text = bookDesc;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
