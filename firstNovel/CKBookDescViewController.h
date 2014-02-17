//
//  CKBookDescViewController.h
//  firstNovel
//
//  Created by canyingwushang on 1/17/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookDescViewController : UIViewController

@property (nonatomic, assign) IBOutlet UIImageView *bookCover;
@property (nonatomic, assign) IBOutlet UILabel *bookName;
@property (nonatomic, assign) IBOutlet UILabel *bookAuthor;
@property (nonatomic, assign) IBOutlet UIButton *bookRead;
@property (nonatomic, assign) IBOutlet UITextView *bookDesc;
@property (nonatomic, assign) IBOutlet UIView *backView;

@property (nonatomic, retain) NSDictionary *bookData;

@end
