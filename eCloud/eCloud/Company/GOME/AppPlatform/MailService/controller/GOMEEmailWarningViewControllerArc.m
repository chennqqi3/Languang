//
//  GOMEEmailWarningViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/4/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "GOMEEmailWarningViewControllerArc.h"
#import "GOMERegisterMailViewControllerArc.h"

#import "UIAdapterUtil.h"
#import "StringUtil.h"

#import "AppDelegate.h"

@interface GOMEEmailWarningViewControllerArc ()

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *warningLabel1;
@property (retain, nonatomic) IBOutlet UILabel *warningLabel2;

@property (retain, nonatomic) IBOutlet UIButton *updateBtn;
@property (retain, nonatomic) IBOutlet UIButton *ignoreBtn;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *warningLabel1TopConstraints;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *ignoreBtnBottomConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *updateBtnBottomConstraint;


- (IBAction)updateClick;
- (IBAction)ignoreClick;

@end

@implementation GOMEEmailWarningViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
}

- (void)setupUI
{
    [self setupText];
    
    [self.cancelBtn setImage:[StringUtil getImageByResName:@"email_close"] forState:UIControlStateNormal];
    
    if (IPHONE_5S_OR_LESS)
    {
        [self.warningLabel1 setFont:[UIFont systemFontOfSize:15]];
        [self.warningLabel2 setFont:[UIFont systemFontOfSize:15]];
        
        self.warningLabel1TopConstraints.constant = 10;
        self.ignoreBtnBottomConstraint.constant = 5;
        self.updateBtnBottomConstraint.constant = 10;
    }
}

- (void)setupText
{
    self.titleLabel.text = [StringUtil getLocalizableString:@"mail_warning"];
    self.warningLabel1.text = [StringUtil getLocalizableString:@"have_checked_your_mail_or_password_is_error"];
    self.warningLabel2.text = [StringUtil getLocalizableString:@"please_update_your_mail_and_password_as_soon_as_possiple"];
    
    self.updateBtn.titleLabel.text = [StringUtil getLocalizableString:@"update_immediately"];
    self.ignoreBtn.titleLabel.text = [StringUtil getLocalizableString:@"remind_me_later"];
}

- (IBAction)updateClick
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

- (IBAction)ignoreClick
{
    // 移除注册界面
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
