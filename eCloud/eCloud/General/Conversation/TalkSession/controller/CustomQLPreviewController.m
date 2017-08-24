//
//  CustomQLPreviewController.m
//  eCloud
//
//  Created by shisuping on 16/1/7.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CustomQLPreviewController.h"
#import "eCloudConfig.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "AppDelegate.h"
#import "mainViewController.h"

@interface CustomQLPreviewController ()
{
    BOOL _shouldReturn;
}

@property(nonatomic,retain)UIToolbar *qlToolBar;
@property(nonatomic,retain)NSTimer *timer;
@end
@implementation CustomQLPreviewController

- (void)dealloc
{
    NSLog(@"%s",__func__);
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
//    [self.navigationController removeObserver:self forKeyPath:@"hidden"];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //if ([[eCloudConfig getConfig]supportGuidePages]) {
//        龙湖要求收到的文件 在预览时 不能在其它应用只打开 目前只有龙湖有广告页，所以加此判断，隐藏在其它文件中打开的按钮
        //self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(hideRightButton) userInfo:nil repeats:YES];
    //}
    [self customLeftButton];
    //方法1:在本视图中设置
//    UIImage *backButtonImage = [[StringUtil getImageByResName:@"LG_left_button_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 0)
//                                                                                           resizingMode:UIImageResizingModeTile];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage
//                                                      forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
//    //参考自定义文字部分
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin)
//                                                         forBarMetrics:UIBarMetricsDefault];

//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    
//    UIColor *_color = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
//    [self.navigationItem.rightBarButtonItem setTintColor:_color];
//    self.navigationItem.backBarButtonItem = backItem;
    
    //创建一个UIButton
//    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
//    //设置UIButton的图像
//    [backButton setImage:[StringUtil getImageByResName:@"LG_left_button_bg.png"] forState:UIControlStateNormal];
//    //给UIButton绑定一个方法，在这个方法中进行popViewControllerAnimated
//    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
//    //然后通过系统给的自定义BarButtonItem的方法创建BarButtonItem
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
//    //覆盖返回按键
//    self.navigationItem.leftBarButtonItem = backItem;
    
    
}

//- (UIToolbar *)getToolBarFromView:(UIView *)view {
//    // Find the QL ToolBar
//    for (UIView *v in view.subviews) {
//        if ([v isKindOfClass:[UIToolbar class]]) {
//            return (UIToolbar *)v;
//        } else {
//            UIToolbar *toolBar = [self getToolBarFromView:v];
//            if (toolBar) {
//                return toolBar;
//            }
//        }
//    }
//    return nil;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    
//    self.qlToolBar = [self getToolBarFromView:self.view];
//    
//    self.qlToolBar.hidden = true;
//    if (self.qlToolBar) {
//        [self.qlToolBar addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionPrior context:nil];
//    }
    
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *naviVc = delegate.window.rootViewController;
//    mainViewController *vc = [naviVc.viewControllers firstObject];
//    if ([vc isKindOfClass:[mainViewController class]])
//    {
//        [vc hideWaterMark];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *naviVc = delegate.window.rootViewController;
//    mainViewController *vc = [naviVc.viewControllers firstObject];
//    if ([vc isKindOfClass:[mainViewController class]])
//    {
//        [vc showWaterMark];
//    }
    
    
    
//    if (!self.navigationController.toolbar.hidden) {
//        self.navigationController.toolbar.hidden = YES;
//    }
//    if (self.navigationController.navigationBarHidden) {
//        self.navigationController.navigationBarHidden = NO;
//    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    
//    BOOL isToolBarHidden = self.qlToolBar.hidden;
//    // If the ToolBar is not hidden
//    if (!isToolBarHidden) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.qlToolBar.hidden = true;
//        });
//    }
//}

- (void)hideRightButton{
    [[self navigationItem] setRightBarButtonItem:nil animated:NO];
    
    self.navigationItem.hidesBackButton = YES;
    if (IOS8_OR_LATER) {
        
        int buttonCount = 0;
        for (UIView *_subview in self.navigationController.toolbar.subviews) {
            if ([[_subview description] rangeOfString:@"UIToolbarButton" options:NSCaseInsensitiveSearch].length > 0) {
                buttonCount++;
                if (buttonCount == 1) {
                    _subview.hidden = YES;
                }
            }
        }
        if (buttonCount == 1) {
            [self.navigationController setToolbarHidden:YES];
            if (IOS10_OR_LATER) {
                CGRect _frame = self.navigationController.toolbar.frame;
                _frame.origin.y = SCREEN_HEIGHT;
                self.navigationController.toolbar.frame = _frame;
            }
        }else{
            if (self.navigationController.navigationBarHidden == NO) {
                self.navigationController.toolbar.hidden = NO;
                CGRect _frame = self.navigationController.toolbar.frame;
                _frame.origin.y = SCREEN_HEIGHT - _frame.size.height;
                self.navigationController.toolbar.frame = _frame;
            }
        }
    }
}

- (void)customLeftButton
{
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}

//返回 按钮
-(void)backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
