//
//  AgentDetailViewController.m
//  eCloud
//
//  Created by yanlei on 15/8/19.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "AgentDetailViewController.h"
#import "StringUtil.h"
#import "eCloudDefine.h"

@interface AgentDetailViewController ()

@end

@implementation AgentDetailViewController
{
    BOOL isFirstLoad;
    UILabel *tipLabel;
    UIWebView *webview;
}
@synthesize urlstr;
@synthesize curUrlStr;
@synthesize navigationType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)dealloc
{
    webview.delegate = nil;
    [webview release];
    webview = nil;
    
    self.urlstr = nil;
    self.curUrlStr = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [StringUtil getLocalizableString:@"agent_detail"];
    isFirstLoad = YES;
    
    [UIAdapterUtil processController:self];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    int tableH = SCREEN_HEIGHT-20;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
    webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH+7)];
    webview.scalesPageToFit = YES;
    [self.view addSubview:webview];
    
    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    webview.delegate=self;
    [webview loadRequest:requestObj];
    
    // 在页面未加载完全时，显示的加载控件
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel release];
}
-(void) webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if(isFirstLoad)
    {
        webview.hidden = YES;
        tipLabel.hidden=NO;
        tipLabel.text = [StringUtil getLocalizableString:@"loading"];
    }
    else
    {
        if(self.navigationType == UIWebViewNavigationTypeLinkClicked)
        {
            webview.hidden = YES;
            tipLabel.hidden=NO;
            tipLabel.text = [StringUtil getLocalizableString:@"linking"];
        }
        else
        {
            tipLabel.hidden = YES;
            webview.hidden = NO;
        }
    }
}

-(void)displayWebView
{
    NSString *curWebViewUrl = webview.request.URL.absoluteString;
    
    if([curWebViewUrl isEqualToString:self.curUrlStr])
    {
        //		如果webview当前的url和正在加载的url相同，则不显示提示
        if(webview.hidden)
        {
            webview.hidden = NO;
        }
        tipLabel.hidden = YES;
    }
    else
    {
        if(!webview.hidden)
        {
            webview.hidden = YES;
        }
        [self performSelector:@selector(displayWebView) withObject:nil afterDelay:0.5];
    }
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isFirstLoad = NO;
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    tipLabel.hidden=YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    if (webview.isLoading)
    {
        [webview stopLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
