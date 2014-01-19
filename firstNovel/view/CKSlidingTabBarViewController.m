//
//  CKSlidingTabBarViewController.m
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKSlidingTabBarViewController.h"
#import "CKCommonUtility.h"

@interface CKSlidingTabBarViewController ()

@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSMutableArray *barItems;
@property (nonatomic, retain) UIImageView *selectCover;
@property (nonatomic, assign) int currentIndex;

@end

@implementation CKSlidingTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _barItems = [[NSMutableArray array] retain];
        _currentIndex = -1;
    }
    return self;
}

- (void)dealloc
{
    [_dataArray release];
    [_barItems release];
    [_selectCover release];
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(0.0f, 0.0f, APPLICATION_FRAME_WIDTH, 55.0f);
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image = [[UIImage imageNamed:@"tabbar_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 5.0f, 5.0f, 5.0f)];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    self.navigationController.navigationBar.hidden = YES;
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

- (void)drawViewWithDataArray:(NSArray *)dataArray
{
    if (dataArray.count < 1) return;
    self.dataArray = dataArray;
    CGFloat itemWidth = APPLICATION_FRAME_WIDTH / dataArray.count;
    int index = 0;
    
    if (_selectCover == nil)
    {
        _selectCover = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, itemWidth, 57.0f)];
        _selectCover.image = [[UIImage imageNamed:@"tabbar_baritem_hl_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(50.0f, 15.0f, 3.0f, 15.0f)];
        _selectCover.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_selectCover];
    }
    
    for (NSDictionary *data in dataArray)
    {
        NSString *iconNormal = [data objectForKey:TABBAR_ITEM_KEY_ICON_NORNAL];
        NSString *title = [data objectForKey:TABBAR_ITEM_KEY_TITLE];
        UIButton *buttonItem = [[UIButton alloc] initWithFrame:CGRectMake(index * itemWidth, 3.0f, itemWidth, 55.0f)];
        [buttonItem addTarget:self action:@selector(barItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonItem setImage:[UIImage imageNamed:iconNormal] forState:UIControlStateNormal];
        [buttonItem setTitle:title forState:UIControlStateNormal];
        buttonItem.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        buttonItem.titleEdgeInsets = UIEdgeInsetsMake(34.0f, 0.0f, 0.0f, 30.0f);
        buttonItem.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 28.0f, 20.0f, 0.0f);
        [buttonItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.view addSubview:buttonItem];
        [_barItems addObject:buttonItem];
        [buttonItem release];
        index++;
    }
    [self setBarItemHighlighted:0];
}

- (void)setBarItemHighlighted:(NSUInteger)index
{
    if (_currentIndex < 0)
    {
        _currentIndex = index;
        return;
    }
    
    CGFloat itemWidth = APPLICATION_FRAME_WIDTH / _dataArray.count;
    int i = 0;
    for (NSDictionary *data in _dataArray)
    {
        UIButton *buttonItem = [_barItems objectAtIndex:i];
        if (buttonItem == nil) return;
        NSString *iconNormal = [data objectForKey:TABBAR_ITEM_KEY_ICON_NORNAL];
        NSString *iconHighlighted = [data objectForKey:TABBAR_ITEM_KEY_ICON_HIGHLIGHTED];
        if (i == index)
        {
            [buttonItem setImage:[UIImage imageNamed:iconHighlighted] forState:UIControlStateNormal];
            [buttonItem setTitleColor:[UIColor colorWithRed:(240.0f/255.0f) green:(99.0f/255.0f) blue:(46.0f/255.0f) alpha:1.0f] forState:UIControlStateNormal];
        }
        else
        {
            [buttonItem setImage:[UIImage imageNamed:iconNormal] forState:UIControlStateNormal];
            [buttonItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        i++;
    }
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = _selectCover.frame;
        _selectCover.frame = CGRectMake(itemWidth *index, frame.origin.y, frame.size.width, frame.size.height);
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarChangeFrom:to:)])
    {
        [_delegate tabBarChangeFrom:_currentIndex to:index];
    }
    _currentIndex = index;
}

- (void)barItemClicked:(id)sender
{
    NSUInteger index = [_barItems indexOfObject:sender];
    [self setBarItemHighlighted:index];
}

@end
