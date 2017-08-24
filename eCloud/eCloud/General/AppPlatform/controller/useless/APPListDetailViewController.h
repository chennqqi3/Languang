//
//  APPListDetailViewController.h
//  eCloud
//
//  Created by Pain on 14-6-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASIHTTPRequest;
@class specialChooseMemberViewController;
@class eCloudDefine;
@class UIWebView;

@interface APPListDetailViewController : UIViewController<UIWebViewDelegate>
{
    NSString *urlstr;
    NSString *appid;
    int fromtype;
    UILabel *tipLabel;
    UIActivityIndicatorView *indicator;
    UIWebView *webview;
    NSTimer *timer;
    int timecount;
    ASIHTTPRequest *request;
    NSMutableArray *dataArray;
}
- (id)initWithAppID:(NSString *)appid;

@property(nonatomic,retain)  NSString *urlstr;
@property (assign) int fromtype;
@property (assign) BOOL needUserInfo;
@property(retain)	NSString *curUrlStr;
@property(assign) int navigationType;

@property (retain) NSString *customTitle;

@property(nonatomic,retain) NSMutableArray *dataArray;

@end


