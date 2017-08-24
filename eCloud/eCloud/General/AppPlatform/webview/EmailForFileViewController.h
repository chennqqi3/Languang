//
//  EmailForFileViewController.h
//  eCloud
//
//  Created by yanlei on 15/9/1.
//  Copyright (c) 2015年  lyong. All rights reserved.
//  邮件、第三方网页中的附件的查看控制器类

#import <UIKit/UIKit.h>

@interface EmailForFileViewController : UIViewController
/** 需要加载的url */
@property(nonatomic,retain) NSString *urlstr;
/** 当前正在加载的url */
@property(nonatomic,retain)	NSString *curUrlStr;
/** 加载的url的来源，如UIWebViewNavigationTypeLinkClicked：点击了网页中的链接等 */
@property(nonatomic,assign) int navigationType;

@end
