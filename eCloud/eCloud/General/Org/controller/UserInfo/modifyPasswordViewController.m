//
//  modifyPasswordViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "modifyPasswordViewController.h"
#import "eCloudDefine.h"
#import "eCloudNotification.h"
#import "conn.h"
#import "eCloudUser.h"
#import "LCLLoadingView.h"
@interface modifyPasswordViewController ()

@end

@implementation modifyPasswordViewController
@synthesize oldPasswordRecord;
@synthesize userEmail;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = YES;
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
            oldPasswordField.text=@"";
            newPasswordField.text=@"";
            newPasswordAgainField.text=@"";
            
            conn* _conn = [conn getConn];
            NSString* userid=_conn.userId;
            [[eCloudUser getDatabase] updateUserPasswd:newPasswordAgain :[userid intValue]];
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
            
        }break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
			break;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
	// Do any additional setup after loading the view.
    UINavigationBar *navibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    navibar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
    
    [self.view addSubview:navibar];
    
    UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(85, 12.5, 150, 20)];
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textAlignment=UITextAlignmentCenter;
    titlelabel.textColor=[UIColor whiteColor];
	titlelabel.font = [UIFont boldSystemFontOfSize:19];
    titlelabel.text=@"修改密码";
    [navibar addSubview:titlelabel];
    [titlelabel release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 7.5, 50, 30);
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navibar addSubview:backButton];
    // [backButton release];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(260, 7.5, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
   //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navibar addSubview:addButton];
    
   /* UILabel *tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 55, 60, 30)];
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.text=@"邮箱:";
    [self.view addSubview:tiplabel];
    [tiplabel release];
    
    UILabel *emaillabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 55, 220, 30)];
    emaillabel.backgroundColor=[UIColor clearColor];
    emaillabel.text=self.userEmail;
    [self.view addSubview:emaillabel];
    [emaillabel release];*/

   passwordTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 480-195) style:UITableViewStyleGrouped];
    [passwordTable setDelegate:self];
    [passwordTable setDataSource:self];
    passwordTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:passwordTable];
    
    oldPassword=@"";
    newPassword=@"";
    newPasswordAgain=@"";
    
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}

-(void) addButtonPressed:(id) sender{
    

        oldPassword= oldPasswordField.text;
       

        newPassword=newPasswordField.text;
       
    
       NSString * newPasswordAgainStr=newPasswordAgainField.text;
      newPasswordAgain=[newPasswordAgainStr copy];
       
   

    
    
    if ([self.oldPasswordRecord isEqualToString:oldPassword]) {
        
        if ([newPasswordAgain isEqualToString:newPassword]&&newPasswordAgain.length>0) {//正确
         
            [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
            [[LCLLoadingView currentIndicator]showSpinner];
            [[LCLLoadingView currentIndicator]show];
            if(![[conn getConn]modifyUserInfo:6 andNewValue:newPasswordAgain])
			{
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
        }else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"新密码不能为空或输入不一致" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        
    }else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"旧密码错误" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    
    }
    
}

//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 18;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 18;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
 
    int row=[indexPath row];
    if (row==0) {
        oldPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(5, 3,280, 40)];
        oldPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        oldPasswordField.secureTextEntry=YES;
        oldPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cell.contentView addSubview:oldPasswordField];
        oldPasswordField.placeholder=@"当前密码";
        [oldPasswordField becomeFirstResponder];
    }else if(row==1) {
        
        newPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(5, 3,280, 40)];
        newPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
         newPasswordField.secureTextEntry=YES;
        newPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cell.contentView addSubview:newPasswordField];
        newPasswordField.placeholder=@"新密码";
     
       
    }else if(row==2) {
        newPasswordAgainField=[[UITextField alloc]initWithFrame:CGRectMake(5, 3,280, 40)];
        newPasswordAgainField.clearButtonMode = UITextFieldViewModeWhileEditing;
         newPasswordAgainField.secureTextEntry=YES;
        newPasswordAgainField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [cell.contentView addSubview:newPasswordAgainField];
        newPasswordAgainField.placeholder=@"请重复输入新密码";
        
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}


@end
