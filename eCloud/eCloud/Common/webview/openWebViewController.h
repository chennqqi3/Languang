//
//  openWebViewController.h
//  eCloud
//
//  Created by  lyong on 13-7-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//  加载url的通用类

#import <UIKit/UIKit.h>
#import "eCloudDefine.h"
#import "ConvRecord.h"

#import "IMYWebView.h"
@interface openWebViewController : UIViewController<IMYWebViewDelegate>
{
    NSString *urlstr;
    int fromtype;
    UILabel *tipLabel;  // 加载url时的过渡提示label
    IMYWebView *webview;
}
/** 进行加载的url */
@property(nonatomic,retain)  NSString *urlstr;
/** 是否需要用户信息 */
@property (assign) BOOL needUserInfo;
/** 记录加载的url的来源，比如是否来源于用户点击的网页的链接 */
@property(assign) int navigationType;
/** 自定义标题，显示在导航栏上 */
@property (retain) NSString *customTitle;
/** 转发的内容，用户点击转发时使用 */
@property (retain) NSString *forwardStr;
/** 转发的会话实体 */
@property (nonatomic,retain) ConvRecord *forwardRecord;

/** (已废弃)url来源类型 */
@property (assign) int fromtype;
/** (已废弃)正在加载的url */
@property(retain) NSString *curUrlStr;

/**
 回退操作

 @param curViewController 当前操作的控制器对象
 */
+ (void)popViewController:(UIViewController *)curViewController;


/**
 正在加载时，提示用户使用到的UILabel

 @return UILabel
 */
+ (UILabel *)getTipsLabel;

@end
