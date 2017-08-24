//
//  modifyTelephoneViewController.m
//  eCloud
//
//  Created by  lyong on 12-11-3.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "modifyTelephoneViewController.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "eCloudNotification.h"

@interface modifyTelephoneViewController ()

@end

@implementation modifyTelephoneViewController
{
	eCloudDAO *_ecloud;
}

@synthesize emp_id = _emp_id;
@synthesize oldMobile = _oldMobile;
@synthesize modifyType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 	_ecloud = [eCloudDAO getDatabase];
//	self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
//	self.title=@"修改手机号码";
    
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"save"] andTarget:self andSelector:@selector(addButtonPressed:)];
    
    inputField=[[UITextField alloc]initWithFrame:CGRectMake(20, 63-44,SCREEN_WIDTH-40, 40)];
    inputField.borderStyle=UITextBorderStyleRoundedRect;
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputField.delegate=self;
    inputField.keyboardType=UIKeyboardTypeNumberPad;
    [inputField becomeFirstResponder];
    [self.view addSubview:inputField];
    inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger strLength = textField.text.length - range.length + string.length;
    if (self.modifyType==0||self.modifyType==3) { //修改手机号码
    return (strLength <= 11);
    }
    return (strLength <20);
    
}
#pragma mark 修改备注或群组名
-(void) addButtonPressed:(id) sender{
    if (![UIAdapterUtil isTAIHEApp]) {
        
        if ([inputField.text length]==0) {
            
            UIAlertView *tempAlert=[[UIAlertView alloc]initWithTitle:@"不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [tempAlert show];
            [tempAlert release];
            
            return;
        }
    }
    if (self.modifyType==0) { //修改手机号码
        if ([inputField.text length]>11) {
            
            UIAlertView *tempAlert=[[UIAlertView alloc]initWithTitle:@"长度超出范围" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [tempAlert show];
            [tempAlert release];
            
            return;
        }
        
        if([inputField.text compare:self.oldMobile] == NSOrderedSame)
        {
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            
            if(![[conn getConn]modifyUserInfo:5 andNewValue:inputField.text]) 
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
        }
 
    }
    else if (self.modifyType==1){ //修改办公电话
        if([inputField.text compare:self.oldMobile] == NSOrderedSame)
        {
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            
            if(![[conn getConn]modifyUserInfo:4 andNewValue:inputField.text]) 
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
        }

    
    }
    else if (self.modifyType==2){ //修改住宅电话
        if([inputField.text compare:self.oldMobile] == NSOrderedSame)
        {
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            
            if(![[conn getConn]modifyUserInfo:10 andNewValue:inputField.text])
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
        }
        
        
    }
    else if (self.modifyType==3){ //修改紧急电话
        if([inputField.text compare:self.oldMobile] == NSOrderedSame)
        {
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
        }
        else
        {
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            
            if(![[conn getConn]modifyUserInfo:11 andNewValue:inputField.text])
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                
            }
        }
        
        
    }
   }

-(void)viewWillAppear:(BOOL)animated
{
	
    if (self.modifyType==0) {
        self.title=[StringUtil getLocalizableString:@"modifyMobile_title"];
    }else if(self.modifyType==1)
    {
       self.title=[StringUtil getLocalizableString:@"modifyTelephone_title"];
    }else if(self.modifyType==2)
    {
       self.title=[StringUtil getLocalizableString:@"modifyHome_title"];
    }else if(self.modifyType==3)
    {
        self.title=[StringUtil getLocalizableString:@"modifyEmc_title"];
    }
	inputField.text = self.oldMobile;
    [inputField becomeFirstResponder];
    //监听输入框消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];

}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    
}
#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
            
        case modify_userinfo_success:
        {
            /*		NSDictionary *dic = cmd.info;
             NSString *msgId = [dic objectForKey:@"msg_id"];*/
            

            conn* _conn = [conn getConn];
            NSString* userid=_conn.userId;
            if (self.modifyType==0){ //修改手机号码
                [_ecloud updateUserMobile:inputField.text :[userid intValue]];
             }
            else if (self.modifyType==1)
            { //修改电话号码
                [_ecloud updateUserTelephone:inputField.text :[userid intValue]];
            
            }else if (self.modifyType==2)
            { //修改宅电
                [_ecloud updateUserHomeTel:inputField.text :[userid intValue]];                
            }
            else if (self.modifyType==3)
            { //修改紧急
                [_ecloud updateUserEmergencyTel:inputField.text :[userid intValue]];                
            }

			[self.navigationController popViewControllerAnimated:YES];
			
//            [self dismissModalViewControllerAnimated:YES];
            
        }break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"通讯超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;            
		default:
			break;
	}
	
}


@end
