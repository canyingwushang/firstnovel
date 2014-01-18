//
//  CKBookChaptersViewController.m
//  firstNovel
//
//  Created by 张超 on 1/18/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import "CKBookChaptersViewController.h"
#import "CKZBooksManager.h"

@interface CKBookChaptersViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(GCD_GLOBAL_QUEUQ, ^{
        [[CKZBooksManager sharedInstance] unZipBookChapters:@"0000"];
    });
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
