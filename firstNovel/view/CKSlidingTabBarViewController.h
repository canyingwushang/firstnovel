//
//  CKSlidingTabBarViewController.h
//  firstNovel
//
//  Created by 张超 on 1/12/14.
//  Copyright (c) 2014 张超. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 DataArray<Dict> 描述了绘图所需元素
 Dict包含标题，图标（正常态和高亮态）
 */

#define TABBAR_ITEM_KEY_TITLE                   @"title"
#define TABBAR_ITEM_KEY_ICON_NORNAL             @"icon_normal"
#define TABBAR_ITEM_KEY_ICON_HIGHLIGHTED        @"icon_highlighted"

@protocol CKSlidingTabBarChanging <NSObject>

- (void)tabBarChangeFrom:(NSUInteger) fromIndex to:(NSUInteger)toIndex;

@end

@interface CKSlidingTabBarViewController : UIViewController

@property (nonatomic, assign) id<CKSlidingTabBarChanging> delegate;

- (void)drawViewWithDataArray:(NSArray *)dataArray;

@end
