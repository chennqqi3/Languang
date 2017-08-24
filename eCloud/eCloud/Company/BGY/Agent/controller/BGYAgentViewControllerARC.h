//
//  BGYAgentViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/6/6.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@interface BGYAgentViewControllerARC : UIViewController<IMYWebViewDelegate>
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

@property (retain) NSString *customTitle;

@end
