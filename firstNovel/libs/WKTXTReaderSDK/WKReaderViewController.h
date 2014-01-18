//
//  WKReaderViewController.h
//  WKReader
//
//  Created by zhonghaoqing on 13-9-18.
//  Copyright (c) 2013年 zhonghaoqing. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SEARCH_STATUS_SUCCESS @"search_success"
#define SEARCH_STATUS_FAIL @"search_fail"

#if NS_BLOCKS_AVAILABLE
typedef void (^SearchBlock)(NSString *status, NSArray *resultArray);
#endif

@class WKReaderViewController;

@protocol WKReaderViewControllerDelegate <NSObject>

/// 阅读器中按下返回按钮时的回调
/// percentage:阅读进度(0.0~1.0)
- (void)wkReaderViewController:(WKReaderViewController *)readerViewController backAtPercentage:(CGFloat)percentage;

@end

@class WKReaderMBook, WKReaderRenderView, WKReaderProvider, WKReaderMBookMark, WKReaderToolBar, WKReaderProgressBar, WKReaderExpandPanel, WKReaderSettingPanelWKReaderBookPosition, WKReaderBookPosition, WKReaderWaitingView, WKReaderStatus;

@interface WKReaderViewController : UIViewController{
    WKReaderMBook *book;
    UIView *containView;
    WKReaderProvider *provider;
    
    BOOL _innerStatusBarHidden;
}

@property(nonatomic, assign) id<WKReaderViewControllerDelegate> readerViewControllerDelegate;

/*UI属性*/
@property(nonatomic, retain) WKReaderToolBar *readerToolBar;     //tool bar
@property(nonatomic, retain) WKReaderProgressBar *readerProgressBar;  // progress bar
@property(nonatomic, retain) WKReaderExpandPanel *readerExpandPanel; // book mark panel
@property(nonatomic, retain) WKReaderRenderView *renderView;
@property(nonatomic, retain) UIView *brightLevelView;
@property(nonatomic, retain) WKReaderWaitingView *bookOpenWaitingView;

/*provider*/
@property(nonatomic, retain) WKReaderProvider *provider;

@property(nonatomic, assign) BOOL needPush;


#pragma mark - 接口函数

/*初始化函数：提供两个接口*/
- (id)initWithFile:(NSString *)fileURL;  //输入书籍的URL，本地URL
- (id)initWithMBook:(WKReaderMBook *)aBook; //输入mbook

/*设置接口：设置字体、背景、主题等*/
- (void)setFont:(UIFont *)font;    //设置字体
- (void)setBackground:(UIImageView *)bgImg;    //设置背景
- (void)setDayNightMode:(BOOL)nightMode;         //设置昼夜模式
- (void)setThemeWithConfigFile:(NSString *)themeConfigFileURL;       //设置主题，输入主题包配置文件的URL
- (void)setThemeWithDefault;   //设置回默认主题

//UI接口
- (void)showBars:(BOOL)show animated:(BOOL)animated;   //是否显示bars
- (void)gotoPosition:(WKReaderBookPosition *)bookPosition;
- (void)gotoPercentage:(CGFloat)percentage;
- (void)updateProgressShow:(CGFloat)percentage;

///用于外部控制状态的恢复
- (void)popStatus;
@end
