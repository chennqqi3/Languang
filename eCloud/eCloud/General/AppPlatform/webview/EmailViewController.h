//
//  EmailViewController.h
//  eCloud
//
//  Created by yanlei on 15/8/26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//  邮件页面加载的控制器

#import <UIKit/UIKit.h>
@interface EmailViewController : UIViewController
/** 需要加载的url */
@property(nonatomic,retain) NSString *urlstr;
/** 当前正在加载的url */
@property(nonatomic,retain)	NSString *curUrlStr;
/** 加载的url的来源，如UIWebViewNavigationTypeLinkClicked：点击了网页中的链接等 */
@property(nonatomic,assign) int navigationType;

@end
