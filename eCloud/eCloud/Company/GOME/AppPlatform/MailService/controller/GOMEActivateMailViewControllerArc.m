//
//  GOMEActivateMailViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/4/14.
//  Copyright © 2017年 WangXin. All rights reserved.
//

#import "GOMEActivateMailViewControllerArc.h"
#import "GOMERegisterMailViewControllerArc.h"

#import "AppDelegate.h"

#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "ImageUtil.h"

#import "eCloudDefine.h"

@interface GOMEActivateMailViewControllerArc ()

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UIButton *activateBtn;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;


@property (retain, nonatomic) IBOutlet UIView *activateView;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)clickActivate;

- (IBAction)clickCancle;

@end

@implementation GOMEActivateMailViewControllerArc

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    // 适配中英文
    [self setupText];
    
    [self.cancelBtn setImage:[StringUtil getImageByResName:@"email_close"] forState:UIControlStateNormal];
    self.imageView.image = [StringUtil getImageByResName:@"mail_service"];
}

- (void)setupText
{
    self.titleLabel.text = [StringUtil getLocalizableString:@"mail_collect_server"];
    [self.activateBtn setTitle:[StringUtil getLocalizableString:@"activate_rightnow"] forState:UIControlStateNormal];
}

- (IBAction)clickActivate
{
    GOMERegisterMailViewControllerArc *registerMailVc = [[GOMERegisterMailViewControllerArc alloc] initWithNibName:@"GOMERegisterMailViewControllerArc" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:registerMailVc];
    
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:registerMailVc andSelector:@selector(cancel) andDisplayLeftButtonImage:NO];
    
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    
    [window.rootViewController presentViewController:navi animated:YES completion:nil];
    
    
    // 移除注册界面
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)clickCancle
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
