//
//  TAIHEAgentLstViewController.h
//  eCloud
//
//  Created by Ji on 17/3/16.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eCloudDefine.h"
#import "ConvRecord.h"
#import "IMYWebView.h"

@interface TAIHEAgentLstViewController : UIViewController<IMYWebViewDelegate>
{
    NSString *urlstr;
    int fromtype;
    UILabel *tipLabel;
    UIActivityIndicatorView *indicator;
    IMYWebView *webview;
    NSTimer *timer;
    int timecount;
}
@property(nonatomic,retain)  NSString *urlstr;
@property (assign) int fromtype;
@property (assign) BOOL needUserInfo;
@property(retain)	NSString *curUrlStr;
@property(assign) int navigationType;

@property (retain) NSString *customTitle;

@property (retain) NSString *forwardStr;

@property (nonatomic,retain) ConvRecord *forwardRecord;

@property (retain) NSString *isWhere;

@property (retain) NSString *isGoHome;
// 是否需要隐藏左侧按钮
@property (nonatomic,assign) BOOL isNeetHideLeftBtn;


@end
