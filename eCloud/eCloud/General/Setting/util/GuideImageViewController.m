//
//  GuideImageViewController.m
//  eCloud
//
//  Created by yanlei on 15/11/26.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "GuideImageViewController.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"
#import "UserDefaults.h"
#import "UIAdapterUtil.h"
#import "AgentListViewController.h"
#import "LogUtil.h"
#import "AppDelegate.h"
#import "JWGCircleCounter.h"
#import "TabbarUtil.h"

@interface GuideImageViewController ()<UIScrollViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,JWGCircleCounterDelegate>{
    
    UILabel *_label;
    NSInteger pages;
    
}

@property (retain, nonatomic) JWGCircleCounter *circleCounter;
//@property (retain, nonatomic) IBOutlet UIImageView *guideImageView;
@property (retain, nonatomic)  UIPageControl *page;
@property (retain, nonatomic)  NSArray *imageArr;

@end

@implementation GuideImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self loadGuideView:self.imageArr];

//    if (self.imageArr.count > 1) {
        //小点
        self.page=[[[UIPageControl alloc]initWithFrame:CGRectMake(self.imageScrollView.frame.size.width/2-40, self.imageScrollView.frame.size.height- 50,80,20)]autorelease];
        //共有几个点
        self.page.numberOfPages=self.imageArr.count;
        //在第几个点上
        self.page.currentPage=0;
        [self.page addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
        self.page.currentPageIndicatorTintColor = [UIColor whiteColor];
        self.page.pageIndicatorTintColor = [UIColor grayColor];
    if (self.imageArr.count > 1) {
        [self.view addSubview:self.page];
    }
    
        //        self.imageScrollView.bounces=YES;
    //}else{
        //        self.imageScrollView.bounces=NO;
        self.circleCounter = [[[JWGCircleCounter alloc]initWithFrame:CGRectMake(self.imageScrollView.frame.size.width-45, 30, 35, 35)]autorelease];
        self.circleCounter.delegate = self;
        [self.view addSubview:self.circleCounter];
        if (![self.circleCounter didStart] || [self.circleCounter didFinish]) {
            NSDictionary *dict = [UserDefaults getGuideImageName];
            int intervalTime = [dict[@"intervalTime"] intValue];
            [self.circleCounter startWithSeconds:intervalTime];
            
        }
        self.circleCounter.circleColor = [UIColor redColor];
        self.circleCounter.circleBackgroundColor = [UIColor clearColor];
        self.circleCounter.circleFillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.circleCounter.circleTimerWidth = 2.f;
        self.circleCounter.userInteractionEnabled = YES;
        
        _label = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 35, 35)]autorelease];
        _label.text = @"跳过";
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:14];
        [self.circleCounter addSubview:_label];
        _label.userInteractionEnabled = YES;
        _label.textAlignment = UITextAlignmentCenter;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTap:)];
        [_label addGestureRecognizer:tap];
        
    //}
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        [TabbarUtil refreshFoundInterface];
        
    }
    
}
- (void)loadGuideView:(NSArray *)imageArr{
 
    self.imageScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]autorelease];
    self.imageScrollView.pagingEnabled=YES;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    self.imageScrollView.userInteractionEnabled = YES;
    self.imageScrollView.bounces = NO;
    self.imageScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.imageScrollView];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.imageArr = [user objectForKey:@"imageNameArray"];
    NSMutableArray *newImageArr = [[NSMutableArray alloc]init];
    if (IS_IPAD) {
        for (int i = 0; i < self.imageArr.count; i++) {
            if (SCREEN_WIDTH > SCREEN_HEIGHT) {
                NSString *imageName = self.imageArr[i];
                if ([imageName rangeOfString:@"_ipad."].length >0) {
                    [newImageArr addObject:self.imageArr[i]];
                }
            }else{
                NSString *imageName = self.imageArr[i];
                if ([imageName rangeOfString:@"_ipad_portrait."].length >0) {
                    [newImageArr addObject:self.imageArr[i]];
                }
            }
            
        }
        if (newImageArr.count >0) {
            self.imageArr = newImageArr;
        }
        
    }
    [self.imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH*self.imageArr.count,SCREEN_HEIGHT)];
    
    
    
    NSString *guideImageSuffix = [UserDefaults getGuideImageSuffix];
    for (int i = 0 ; i < self.imageArr.count; i++) {
        
        NSString *guideImagePath = [[StringUtil getGuideImagePath]stringByAppendingPathComponent:self.imageArr[i]];
        UIImage *_image = [UIImage imageWithContentsOfFile:guideImagePath];
        if ([guideImageSuffix isEqualToString:@"gif"]) {
            
            self.webView = [[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]autorelease];
            self.guideImageView.hidden = YES;
            [self.webView setScalesPageToFit:YES];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:guideImagePath]]];
            self.webView.dataDetectorTypes = UIDataDetectorTypeLink;
            //取消右侧，下侧滚动条，去处上下滚动边界的黑色背景
            self.webView.backgroundColor=[UIColor clearColor];
            self.webView.scrollView.bounces=NO;
            self.webView.userInteractionEnabled = YES;
            self.webView.delegate = self;
            [self.imageScrollView addSubview:self.webView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWebView:)];
            tap.delegate = self;
            [self.webView addGestureRecognizer:tap];
            
        }else{
            
            self.guideImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(i * self.imageScrollView.frame.size.width,self.imageScrollView.frame.origin.y , self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height)]autorelease];
            self.guideImageView.image = _image;
            self.guideImageView.userInteractionEnabled = YES;
            self.guideImageView.tag = i;
            [self.imageScrollView addSubview:self.guideImageView];
            self.guideImageView.backgroundColor = [UIColor clearColor];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OpenImageLinks:)];
            //打开人机交互开关
            [self.guideImageView addGestureRecognizer:tap];
            
        }
    }
    
}
//倒计时结束的回调
- (void)circleCounterTimeDidExpire:(JWGCircleCounter *)circleCounter {
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate gotoRootViewCtrl];
}

// 允许多个手势并发
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)tapWebView:(UIGestureRecognizer *)tap{
    
    NSDictionary *dict = [UserDefaults getGuideImageName];
    NSString *downloadFrom = nil;
    if (dict) {
        NSArray *arr = dict[@"linkUrl"];
        for (NSDictionary *dic in arr) {
            
            downloadFrom = dic[@"downloadFrom"];
            if ([[downloadFrom stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]!=0) {
                
                [self.circleCounter stop];
                [self openAgent:dic[@"downloadFrom"]];
            }
        }
       
    }
    
}

-(void)myTap:(UIGestureRecognizer *)tap{
    
    [self.circleCounter stop];
    [(AppDelegate *)[UIApplication sharedApplication].delegate gotoRootViewCtrl];
    
}

- (void)OpenImageLinks:(UIGestureRecognizer *)tap
{
    UIView *views = (UIView*) tap.view;
    int tag = (int)views.tag;
    NSDictionary *dict = [UserDefaults getGuideImageName];
   
    if (dict) {
        
        NSArray *arr = dict[@"linkUrl"];
        for (NSDictionary *dic in arr) {
            
            NSString *nameImage = self.imageArr[tag];
            if([nameImage rangeOfString:@"@"].location !=NSNotFound) {
                NSRange range = [nameImage rangeOfString:@"@"]; //现获取要截取的字符串位置
                nameImage = [nameImage substringToIndex:range.location];
                nameImage = [nameImage stringByReplacingOccurrencesOfString:@"ios" withString:@""];
            }
            if ([dic[@"imageUrl"] rangeOfString:nameImage].location != NSNotFound) {

                if ([[dic[@"downloadFrom"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]!=0) {
                    
                    [self.circleCounter stop];
                    [self openAgent:dic[@"downloadFrom"]];
                    return;
                }
                
            }
            
        }
    }
    

    
}

- (void)openAgent:(NSString *)agentUrl
{
    [UIAdapterUtil hideTabBar:self];
    
    if ([agentUrl rangeOfString:@"?"].length > 0) {
        agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",agentUrl,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }else{
        agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",agentUrl,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,agentUrl]];
    AgentListViewController *agentListVC = [[AgentListViewController alloc]init];
    
    // 测试用的token：8633bfe9-792a-4eb1-b4a3-5a9d0261ab05
    // 外网域名：http://moapproval.longfor.com:8080/moapproval/list.html

    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:agentListVC];
    agentListVC.urlstr = agentUrl;
    agentListVC.isForm = @"广告页";
    //[self.navigationController pushViewController:agentListVC animated:YES];
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState=[UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[[UIApplication sharedApplication].delegate window] setRootViewController:navigation];
                        [UIView setAnimationsEnabled:oldState];
                        
                    }
                    completion:NULL];
    [navigation release];
}

-(void)pageTurn:(UIPageControl *)aPageControl{
    
    NSInteger whichPage = aPageControl.currentPage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width * whichPage, 0.0f) animated:YES];
    [UIView commitAnimations];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = self.imageScrollView.contentOffset.x / 290;//通过滚动的偏移量来判断目前页面所对应的小白点
    self.page.currentPage = page;   //pagecontroll响应值的变化
    pages = self.page.currentPage;
    if (self.imageArr.count > 1) {
        
        self.imageScrollView.bounces = (sender.contentOffset.x <= 0) ? NO : YES;
        
        float contentOffsetX = sender.contentOffset.x ;
        float screenX = self.imageScrollView.frame.size.width * (self.imageArr.count -1) + 50;

        if (contentOffsetX > screenX) {
            
            [(AppDelegate *)[UIApplication sharedApplication].delegate gotoRootViewCtrl];

        }
    }
    
    
}


- (void)dealloc {
//    [_guideImageView release];
    [super dealloc];
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    CGRect _frame = self.imageScrollView.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        
        return;
    }
    
    [self.guideImageView removeFromSuperview];
    [self.imageScrollView removeFromSuperview];
    [self loadGuideView:self.imageArr];
    [self.imageScrollView setContentOffset:CGPointMake(pages * SCREEN_WIDTH, 0)];
 
    if (self.imageArr.count > 1) {
        //小点
        CGRect _frame = self.imageScrollView.frame;
        _frame.origin.x = self.imageScrollView.frame.size.width/2-40;
        _frame.origin.y = self.imageScrollView.frame.size.height- 50;
        _frame.size.width = 80;
        _frame.size.height = 20;
        self.page.frame = _frame;
        [self.view addSubview:self.page];
        
    }else{
        CGRect _frame = self.imageScrollView.frame;
        _frame.origin.x = self.imageScrollView.frame.size.width-45;
        _frame.origin.y = 30;
        _frame.size.width = 35;
        _frame.size.height= 35;
        self.circleCounter.frame = _frame;
        [self.view addSubview:self.circleCounter];

    }
    

}




@end
