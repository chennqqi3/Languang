//
//  EmailForFileViewController.m
//  eCloud
//
//  Created by yanlei on 15/9/1.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "EmailForFileViewController.h"
#import "ASIHTTPRequest.h"
#import "StringUtil.h"
#import "ASIHTTPRequestDelegate.h"
#import "IMYWebView.h"
#import "eCloudDefine.h"
#import "AppDelegate.h"
@interface EmailForFileViewController ()<IMYWebViewDelegate,ASIHTTPRequestDelegate,UIScrollViewDelegate>

@property(nonatomic,retain)UIScrollView *scrollview;
@property(nonatomic)BOOL zoomOut_In;

@end
#define MaxSCale 2.5  //最大缩放比例
#define MinScale 0.5  //最小缩放比例
@implementation EmailForFileViewController
{
    BOOL isFirstLoad;
    UILabel *tipLabel;
    IMYWebView *webview;
    NSString *filePath; // 文件路径
    NSString *fileName; // 文件名称
    UIImageView *imageView;
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
    if (webview.isLoading)
    {
        [webview stopLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    webview.delegate = nil;
    [webview release];
    webview = nil;
    
    self.urlstr = nil;
    self.curUrlStr = nil;
    imageView = nil;
    _scrollview = nil;
    
#ifdef _LONGHU_FLAG_
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = 0;
#endif
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 获取上一个控制器的title
    NSArray *arr = self.navigationController.viewControllers;
    UIViewController *viewCtrl = arr[arr.count-2];
    self.title = viewCtrl.title;
    isFirstLoad = YES;
    
    [UIAdapterUtil processController:self];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    int tableH = SCREEN_HEIGHT-20;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
    webview=[[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    webview.scalesPageToFit = YES;
    [self.view addSubview:webview];
    
    // 在页面未加载完全时，显示的加载控件
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel release];

    NSURL *url = [ NSURL URLWithString:self.urlstr];
    if (!url) {
        self.urlstr = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        url = [NSURL URLWithString:self.urlstr];
    }
    // 对self.urlstr进行拆分，获取到文件名
    NSArray *urlTmpArray = [self.urlstr componentsSeparatedByString:@"&fileName="];
    urlTmpArray = [urlTmpArray[1] componentsSeparatedByString:@"&"];
    // 对获取到的文件名称进行解码
    fileName = [urlTmpArray[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 将邮件附件放到沙盒的tmp目录中
    filePath = NSTemporaryDirectory();
    filePath = [filePath stringByAppendingPathComponent : fileName];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request setDownloadDestinationPath:filePath];
    [request startSynchronous];
//    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
//        [self requestFinished:request];
//    }else{
//        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];//创建文件夹
//        [request startSynchronous];
//    }

#ifdef _LONGHU_FLAG_
    ((AppDelegate *)[UIApplication sharedApplication].delegate).allowRotation = 1;
#endif
    
   
}


-(void) webViewDidStartLoad:(IMYWebView *)webView
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
    NSString *curWebViewUrl = webview.currentRequest.URL.absoluteString;
    
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

- (void)webViewDidFinishLoad:(IMYWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isFirstLoad = NO;
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    tipLabel.hidden=YES;
    
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - asihttprequest代理
- (void)requestFinished:(ASIHTTPRequest *)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    // 下载完成后，读取下载到沙盒中的文件，显示到webView中
    // 获取文件后缀
    if (![[NSFileManager defaultManager]fileExistsAtPath:request.downloadDestinationPath]) {
        [self requestFailed:request];
        return;
    }
    
    if ([[[fileName pathExtension] lowercaseString] rangeOfString:@"txt"].length > 0 ) {
        // 对txt的文件进行乱码处理
        [self showTxtOption];
    }
    else if ([[[fileName pathExtension] lowercaseString] rangeOfString:@"jpg"].length > 0 || [[[fileName pathExtension] lowercaseString] rangeOfString:@"png"].length > 0 || [[[fileName pathExtension] lowercaseString] rangeOfString:@"bmp"].length > 0|| [[[fileName pathExtension] lowercaseString] rangeOfString:@"jpeg"].length > 0){
        [webview removeFromSuperview];
        [self initImageView];
    }
    else{
        // 除txt文件其他文件的加载
        webview.delegate = self;
        NSURL *urlFile = [NSURL fileURLWithPath:filePath];
        NSURLRequest *requestFile = [NSURLRequest requestWithURL:urlFile];
        [webview loadRequest:requestFile];
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

    NSError *_error = request.error;
    if (_error) {
        [LogUtil debug:[NSString stringWithFormat:@"%s errcode is %d errMsg is %@",__FUNCTION__,_error.code,_error.description]];
    }
    tipLabel.text = @"文件打开失败";
}

/**
 *  处理txt文件的乱码问题
 */
- (void)showTxtOption{
    ///解决 .txt 中文显示乱码问题
    NSStringEncoding *useEncodeing = nil;
    //带编码头的如utf-8等，这里会识别出来
    NSString *body = [NSString stringWithContentsOfFile:filePath usedEncoding:useEncodeing error:nil];
    //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
    if (!body) {
        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000632 error:nil];
    }
    //还是识别不到，按GB18030编码再解码一次.
//    if (!body) {
//        body = [NSString stringWithContentsOfFile:filePath encoding:0x80000631 error:nil];
//    }
    
    //展现
    if (body) {
        [webview loadHTMLString:body baseURL: nil];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initImageView{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _scrollview = [[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT)]autorelease];
    _scrollview.backgroundColor = [UIColor blackColor];
    _scrollview.delegate = self;
    [self.view addSubview:_scrollview];
    _scrollview.maximumZoomScale=MaxSCale;//图片的放大倍数
    _scrollview.minimumZoomScale=MinScale;//图片的最小倍率
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _zoomOut_In = YES;//控制点击图片放大或缩小
    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    imageView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)]autorelease];
    imageView.image = image;
    imageView.center = CGPointMake(SCREEN_WIDTH/2,(SCREEN_HEIGHT - 64)/2);

    //自适应图片宽高比例
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [_scrollview addSubview:imageView];
    imageView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
    [doubleTapGesture release];
    
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    if (_zoomOut_In) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        _scrollview.zoomScale=2.5;//双击放大到两倍
        _zoomOut_In = NO;
        [UIView commitAnimations];
        
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        _scrollview.zoomScale=1.0;
        _zoomOut_In = YES;
        imageView.center = CGPointMake(SCREEN_WIDTH/2,(SCREEN_HEIGHT - 64)/2);
        [UIView commitAnimations];
    }
    
    

}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            scrollView.contentSize.height * 0.5 + offsetY - 44);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;//要放大的视图
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = webview.frame;

    if (_frame.size.width == SCREEN_WIDTH) {
        if (_scrollview) {
            
            _scrollview.frame = _frame;
            imageView.frame = _frame;
        }
        return;
    }
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT;
    if (_scrollview) {
        
        _scrollview.frame = _frame;
        imageView.frame = _frame;
        
    }else{
        
        webview.frame = _frame;
    }
}
@end

