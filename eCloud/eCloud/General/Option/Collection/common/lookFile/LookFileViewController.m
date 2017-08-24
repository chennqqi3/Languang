//
//  LookFileViewController.m
//  OpenCtx
//
//  Created by lyan on 15-5-29.
//  Copyright (c) 2015年 mimsg. All rights reserved.
//

#import "LookFileViewController.h"
#import "StringUtil.h"
#import "LogUtil.h"
#import "UIAdapterUtil.h"

@interface LookFileViewController ()<UIWebViewDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic,retain) UIDocumentInteractionController *interactionController;
@end

@implementation LookFileViewController
@synthesize interactionController;

- (void)dealloc
{
    self.interactionController = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置nav导航栏标题
    [self setNavTitle];
    [self loadFileWebView];
}
- (void)setNavTitle{
    self.title = [self.fileRecord previewItemTitle];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    // 增加导航栏右侧按钮
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 按钮的点击事件
- (void)shareAction{
    NSURL *url = [self.fileRecord previewItemURL];

    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.interactionController.delegate = self;
    CGRect navRect = self.navigationController.navigationBar.frame;
    navRect.size = CGSizeMake(1500.0f, 40.0f);
    [self.interactionController presentOptionsMenuFromRect:navRect inView:self.view  animated:YES];

}
#pragma mark - UIDocumentInteractionControllerDelegate代理方法
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}
#pragma mark - 加载UIWebView进行加载文件,进行展示
- (void)loadFileWebView{
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webView.delegate = self;
    webView.autoresizesSubviews = YES;
    webView.multipleTouchEnabled = YES;
    webView.scalesPageToFit = YES;
    webView.tag = 100;
    webView.hidden = YES;
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
#ifdef _LANGUANG_FLAG_
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:_filePath]];
    webView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
#else
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[self.fileRecord previewItemURL]];
    
#endif
    
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    //    [request release];
    [webView release];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [webView removeFromSuperview];
    UILabel *fileOpenFailLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height/4, self.view.frame.size.width - 40, self.view.frame.size.height/2)];
    fileOpenFailLabel.numberOfLines = 0;
    
    int fileSize = [[NSString stringWithFormat:@"%@",self.fileRecord.convRecord.file_size] intValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    fileOpenFailLabel.text = [NSString stringWithFormat:@"%@\nsize: %@",[self.fileRecord previewItemTitle],fileSizeStr];
    ;
    fileOpenFailLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:fileOpenFailLabel];
    [fileOpenFailLabel release];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    webView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
