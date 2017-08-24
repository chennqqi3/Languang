//
//  BGYWebViewController.h
//  eCloud
//
//  Created by Alex-L on 2017/7/14.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BGY_HIDE_HEADVIEW_NOTIFICATION @"BGY_HIDE_HEADVIEW_NOTIFICATION"
#define BGY_SHOW_HEADVIEW_NOTIFICATION @"BGY_SHOW_HEADVIEW_NOTIFICATION"

@interface BGYWebViewControllerARC : UIViewController

@property (nonatomic, copy) NSString *urlstr;

@property (nonatomic, assign) BOOL isHideHeaderWhenScroll;
@property (nonatomic, assign) CGFloat viewHeight;

@property (nonatomic, assign) BOOL isAutoLogin;
@property (nonatomic, assign) BOOL isHideTabar;

@end
