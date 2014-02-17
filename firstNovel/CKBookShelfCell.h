//
//  CKBookShelfCell.h
//  firstNovel
//
//  Created by followcard on 1/12/14.
//  Copyright (c) 2014 followcard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKBookShelfCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIImageView *backImage;
@property (nonatomic, assign) IBOutlet UIImageView *bookCover;
@property (nonatomic, assign) IBOutlet UILabel *bookName;
@property (nonatomic, assign) IBOutlet UILabel *bookAuthor;
@property (nonatomic, assign) IBOutlet UILabel *bookDesc;

@end
