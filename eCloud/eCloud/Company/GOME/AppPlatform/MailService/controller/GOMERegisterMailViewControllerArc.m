//
//  GOMERegisterMailViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/4/14.
//  Copyright © 2017年 WangXin. All rights reserved.
//

#import "GOMERegisterMailViewControllerArc.h"

#import "StringUtil.h"
#import "GOMEEmailUtilArc.h"
#import "UserTipsUtil.h"
#import "JSONKit.h"
#import "LogUtil.h"
#import "eCloudDAO.h"
#import "GOMEUserDefaults.h"
#import "eCloudDefine.h"
#import "GOMEMailDefine.h"
#import "conn.h"

@interface GOMERegisterMailViewControllerArc ()<UIAlertViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *instructorLabel;
@property (retain, nonatomic) IBOutlet UILabel *mailAccount;
@property (retain, nonatomic) IBOutlet UILabel *accountWarning;
@property (retain, nonatomic) IBOutlet UILabel *mailPassword;
@property (retain, nonatomic) IBOutlet UILabel *passwordWarning;
@property (retain, nonatomic) IBOutlet UIButton *commitBtn;

@property (retain, nonatomic) IBOutlet UITextField *accountTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

@property (retain, nonatomic) IBOutlet UIImageView *accountLogo;
@property (retain, nonatomic) IBOutlet UIImageView *passwordLogo;

@property (retain, nonatomic) IBOutlet UIView *accountView;
@property (retain, nonatomic) IBOutlet UIView *passwordView;

- (IBAction)commitClick;

- (IBAction)cancelTap:(id)sender;

@end

@implementation GOMERegisterMailViewControllerArc

- (void)dealloc
{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

//    如果激活成功了，则开启定时器
    [[GOMEEmailUtilArc getEmailUtil]startEmailTimer];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    首先停止之前的定时器
    [[GOMEEmailUtilArc getEmailUtil]stopEmailTimer];

    [self setupUI];    
}

- (void)setupUI
{
    self.title = [StringUtil getLocalizableString:@"edit_mail_message"];
    
    
    self.accountView.layer.borderColor = [UIColor colorWithWhite:0.93 alpha:1].CGColor;
    self.accountView.layer.borderWidth = 1;
    self.passwordView.layer.borderColor = [UIColor colorWithWhite:0.93 alpha:1].CGColor;
    self.passwordView.layer.borderWidth = 1;
    
    self.accountLogo.image = [StringUtil getImageByResName:@"email_accoun"];
    self.passwordLogo.image = [StringUtil getImageByResName:@"email_password"];
    
    [self setupText];
}

- (void)setupText
{
//    如果邮箱已经激活，那么把之前保存的账号和密码回填到这里
    self.instructorLabel.text = [StringUtil getLocalizableString:@"please_enter_your_account_and_password_to_activate_the_mail_server"];
    self.mailAccount.text = [StringUtil getLocalizableString:@"mail_account"];
    self.accountWarning.text = [StringUtil getLocalizableString:@"please_enter_your_mail_account"];
    self.mailPassword.text = [StringUtil getLocalizableString:@"mail_password"];
    self.passwordWarning.text = [StringUtil getLocalizableString:@"account_or_password_error_please_enter_again"];
    self.commitBtn.titleLabel.text = [StringUtil getLocalizableString:@"commit"];
    
    self.accountTextField.returnKeyType  = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.accountWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
//    设置之前保存过的值
    self.accountTextField.text = [GOMEUserDefaults getGOMEEmailAddress];
    self.passwordTextField.text = [GOMEUserDefaults getGOMEEmailPassword];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.accountWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    if (text.length > 30)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.accountWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
    
    if ([textField isEqual:self.accountTextField])
    {
        [self.accountTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordTextField])
    {
        [self.passwordTextField resignFirstResponder];
//        [self commitClick];
    }
    
    return YES;
}

- (IBAction)commitClick
{
    
    self.accountWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    
//    username = bibo
//    password = Abcd123
    
    
    NSLog(@"account:%@   password:%@", self.accountTextField.text, self.passwordTextField.text);
    
    if (self.accountTextField.text.length == 0)
    {
        self.accountWarning.hidden = NO;
        self.accountWarning.text = @"请输入邮箱账号";
        return;
    }
    else if (self.passwordTextField.text.length == 0)
    {
        self.passwordWarning.hidden = NO;
        self.passwordWarning.text = @"请输入邮箱密码";
        return;
    }
    
//    用户输入了邮箱和密码，现在开始校验邮箱和密码是否正确
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];

    NSString *account  = self.accountTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSArray *tempArray = [account componentsSeparatedByString:@"@"];
    if (tempArray.count) {
        account = tempArray[0];
    }
    
    NSString *checkURLStr = [[GOMEEmailUtilArc getEmailUtil]getCheckEmailAndPasswordUrlWithEmail:account andPassword:password];
    
    NSURL *checkURL = [NSURL URLWithString:checkURLStr];
    
    dispatch_queue_t _queue = dispatch_queue_create("check mail account and password", NULL);
    dispatch_async(_queue, ^{
        NSString *resultStr = [NSString stringWithContentsOfURL:checkURL encoding:NSUTF8StringEncoding error:nil];
        
        NSDictionary *dic = [resultStr objectFromJSONString];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 检测账号和密码是否正确:%@",__FUNCTION__,dic]];


        dispatch_async(dispatch_get_main_queue(), ^{
            [UserTipsUtil hideLoadingView];
            if (resultStr.length) {
                if ([[GOMEEmailUtilArc getEmailUtil]isEmailAndPasswordCorrect:dic]) {
//                    更新为新的账号和邮箱
                    [GOMEUserDefaults saveGOMEEmailAccount:self.accountTextField.text password:password];
                    
//                    检查本地是否有邮件通知，如果没有则自动生成一条，这样就有邮件入口了
                    NSArray *_array = [[eCloudDAO getDatabase] getBroadcastList:appNotice_broadcast withAppID:[NSString stringWithFormat:@"%d",GOME_EMAIL_APP_ID]];
                    if (_array.count == 0) {
//                        自动增加一条
                        NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                        mDic[@"sender_id"] = [StringUtil getStringValue:GOME_EMAIL_APP_ID];
                        mDic[@"recver_id"] = [conn getConn].userId;
                        mDic[@"sendtime"] = [[conn getConn]getSCurrentTime];
                        //    设置一个常量 可能这个都没有使用到
                        mDic[@"msglen"] = @"100";
                        mDic[@"asz_titile"] = @"没有新邮件";
                        mDic[@"asz_message"] = @"";
                        mDic[@"broadcast_type"] = [NSNumber numberWithInt:appNotice_broadcast];
                        mDic[@"read_flag"] = [NSNumber numberWithInt:0];
                        
                        NSString *msgId = [[conn getConn]getSNewMsgId];
                        mDic[@"msg_id"] = msgId;
                        [[eCloudDAO getDatabase]saveBroadcast:[NSArray arrayWithObject:mDic]];
                    }
                    
//                    保存为邮箱已经激活
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"激活成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                }else{
                    self.passwordWarning.hidden = NO;
                    self.passwordWarning.text = @"邮箱账号与密码不符，请重新输入！";
                }
            }else{
                [UserTipsUtil showAlert:@"服务器没有返回数据"];
            }
        });
    });
}

- (IBAction)cancelTap:(id)sender
{
    // 返回
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 返回
    [self cancel];
}

@end
