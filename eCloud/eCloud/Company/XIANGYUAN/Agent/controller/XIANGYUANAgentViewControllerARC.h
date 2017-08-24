//
//  XIANGYUANAgentViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@protocol HomeDelegate

- (void)returnString:(NSString *)string;

@end

@interface XIANGYUANAgentViewControllerARC : UIViewController<IMYWebViewDelegate>
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
@property(nonatomic,assign)  BOOL isDAIBAN;
@property(nonatomic,assign)  BOOL isWorkDAIBAN;
@property(nonatomic,strong)NSString *framWhere;

@property (nonatomic, strong) id <HomeDelegate> delegate;

@end
