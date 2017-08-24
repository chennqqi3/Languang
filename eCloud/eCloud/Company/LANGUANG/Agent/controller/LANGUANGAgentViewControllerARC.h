//
//  LANGUANGAgentViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@interface LANGUANGAgentViewControllerARC : UIViewController<IMYWebViewDelegate>
{
    NSString *urlstr;
    UILabel *tipLabel;
    IMYWebView *webview;
    NSTimer *timer;
    int timecount;
}


@property(nonatomic,retain)  NSString *urlstr;

@property(retain)	NSString *curUrlStr;
@property(assign) int navigationType;
@property(nonatomic,assign)BOOL isNews;
@property (retain) NSString *customTitle;

// 是否能回退
/**
 webview是否可以回退

 @return YES 能回退   NO 不能回退
 */
- (BOOL)isCanBack;
@end
