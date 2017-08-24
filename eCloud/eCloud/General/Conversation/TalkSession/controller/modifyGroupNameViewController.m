//
//  modifyGroupNameViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "modifyGroupNameViewController.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "chatMessageViewController.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "UserDefaults.h"


@interface modifyGroupNameViewController ()


@end

@implementation modifyGroupNameViewController
{
	eCloudDAO *_ecloud;
    
    UITextField *inputField;
    UILabel *tipLabel;
}
@synthesize delegete;
@synthesize last_msg_id;
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

    self.view.backgroundColor=[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
//    self.title=[StringUtil getLocalizableString:@"modifyGroupName_modify_groupName"];
    self.title=[StringUtil getLocalizableString:@"修改群组名称"];
    
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    UIButton *rightButton = [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"save"] andTarget:self andSelector:@selector(addButtonPressed:)];

    inputField=[[[UITextField alloc]initWithFrame:CGRectMake(0, 63-44,SCREEN_WIDTH-12, 40)]autorelease];
    inputField.borderStyle = UITextBorderStyleNone;
    inputField.layer.borderColor= [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1].CGColor;
    inputField.backgroundColor = [UIColor whiteColor];
    inputField.layer.borderWidth= 1.0f;
    inputField.delegate=self;
    inputField.placeholder=[StringUtil getLocalizableString:@"modifyGroupName_max_GropuName_words"];
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [inputField setValue:[NSNumber numberWithInt:12] forKey:@"paddingLeft"];
    [inputField becomeFirstResponder];
    [self.view addSubview:inputField];

    inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addTextDidChangeObserver];
    
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 70, self.view.frame.size.width-160, 20)];
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:tipLabel];
    [tipLabel release];
#ifdef _LANGUANG_FLAG_
    inputField.frame = CGRectMake(0, 12, SCREEN_WIDTH, 51);
    tipLabel.hidden = YES;
    [rightButton setTitleColor:[UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0]
                      forState:UIControlStateNormal];
#endif
}

- (void)addTextDidChangeObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)removeTextDidChangeObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification
{
//    int maxLen = (GROUPNAME_MAXLEN / 3);
//    if (inputField.text.length > maxLen)
//    {
//        [self removeTextDidChangeObserver];
//        [self showAlertIfGroupNameTooLong];
//    }
    [self groupNameLenTip:inputField.text];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    NSInteger strLength = textField.text.length - range.length + string.length;
//    
//    return (strLength <= 16);
//    
//}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    int MAX_CHARS = GROUPNAME_MAXLEN / 3;
//    
//    NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
//    
//    [newtxt replaceCharactersInRange:range withString:string];
//    
//    return ([newtxt length] <= MAX_CHARS);
//}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSLog(@"%@ ,%d,%@,%@",textField.text,textField.text.length, NSStringFromRange(range),string);
//    return YES;

    NSString *textString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"input%@",textString);
    
    if ([string isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        if ([StringUtil lenghtWithString:textString] > (GROUPNAME_MAXLEN -2))
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

-(void)groupNameLenTip:(NSString *)groupName
{
    int GroupNameLenNum = [StringUtil lenghtWithString:groupName];
    NSString *GroupNameLen = [StringUtil getStringValue:GroupNameLenNum];
    if (GroupNameLenNum>48) {
        GroupNameLen = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"modifyGroupName_GroupName_Length_too_long"],GroupNameLen];
    }
    tipLabel.text = [NSString stringWithFormat:@"%@/%d",GroupNameLen,(GROUPNAME_MAXLEN-2)];
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
//    [inputField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}

#pragma mark 修改备注或群组名
-(void) addButtonPressed:(id) sender{
    
    if ([inputField.text length]==0) {
        
        UIAlertView *tempAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"modifyGroupName_can't_be_empty"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
        [tempAlert show];
        [tempAlert release];
        
        return;
    }
    
    if ([StringUtil lenghtWithString:inputField.text] > GROUPNAME_MAXLEN -2) {
        
        [self showAlertIfGroupNameTooLong];
        return;
    }
    
	if([self.oldGroupName compare:inputField.text] == NSOrderedSame)
	{
//        [inputField resignFirstResponder];
		[self.navigationController popViewControllerAnimated:YES];
//		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
//		[inputField resignFirstResponder];
        if(self.last_msg_id==-1)
        {
             NSLog(@"--------------------------修改群组名称");
            [_ecloud updateConvInfo:self.convId andType:0 andNewValue:inputField.text];
            [UserDefaults saveModifyGroupNameFlag:self.convId];
            
#pragma mark 你修改了群组名称
 			NSString *newGrpName = inputField.text;
			NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_change_group_name_to_x"],newGrpName];
			conn *_conn = [conn getConn];

			NSString *operTime = [_conn getSCurrentTime];
			
			[_conn saveGroupNotifyMsg:self.convId andMsg:msgBody andMsgTime:operTime];

            ( (chatMessageViewController *) self.delegete).titleStr=inputField.text;
            
            [self.navigationController popViewControllerAnimated:YES];

            return;
        }
        [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"modifyGroupName_modifying"]];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];

        conn *_conn = [conn getConn];
        if(![_conn modifyGroupInfo:self.convId andValue:inputField.text andValueType:0])
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"modifyGroupName_modify_groupName_failed"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }

/*--------关闭下面代码，有必要的时候打开--------*/
//		conn *_conn = [conn getConn];
//		
//		int create_emp_id=[_ecloud getConvCreateEmpIdByConvId:self.convId];
//		
//		if (create_emp_id==[_conn.userId intValue]) { //修改者是创建人
//			[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
//			[[LCLLoadingView currentIndicator]showSpinner];
//			[[LCLLoadingView currentIndicator]show];
//			NSLog(@"--------------------------修改者是创建人");
//			if(![_conn modifyGroupInfo:self.convId andValue:inputField.text andValueType:0])
//			{
//				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
//				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"企云" message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//				[alert show];
//				[alert release];
//			}
//		}else //只能修改备注
//		{
//			NSLog(@"--------------------------只能修改备注");
//			[_ecloud updateConvInfo:self.convId andType:0 andNewValue:inputField.text];
//			//        UIAlertView *tempAlert=[[UIAlertView alloc]initWithTitle:@"修改成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//			//        [tempAlert show];
//			//        [tempAlert release];
//			
//			( (chatMessageViewController *) self.delegete).titleStr=inputField.text;
//			
//			[self.navigationController popViewControllerAnimated:YES];
////			[self dismissModalViewControllerAnimated:YES];
//			
//		}
	}
}
-(void)viewWillAppear:(BOOL)animated
{
    inputField.text = self.oldGroupName;
    
    [self groupNameLenTip:self.oldGroupName];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(handleCmd:)
												name:MODIFYGROUPNAME_NOTIFICATION
											  object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];

    
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYGROUPNAME_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [inputField resignFirstResponder];

}
#pragma mark 处理信息
- (void)handleCmd:(NSNotification *)notification
{
     [[LCLLoadingView currentIndicator]hiddenForcibly:true];
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
        case modify_groupname_success:
        {
            NSLog(@"--------------------------修改群组名称");
            [UserDefaults removeModifyGroupNameFlag:self.convId];
            [_ecloud updateConvInfo:self.convId andType:0 andNewValue:inputField.text];
            ( (chatMessageViewController *) self.delegete).titleStr=inputField.text;
            
            [self.navigationController popViewControllerAnimated:YES];

            
        }break;
        case modify_groupname_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"modifyGroupName_modify_groupName_failed"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
			break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"modifyGroupName_modify_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;
		default:
			break;
	}
	
}



-(void)dealloc
{
    
    [self removeTextDidChangeObserver];
    
     self.delegete = nil;
    self.convId = nil;
    self.oldGroupName;

    [super dealloc];
}

- (void)showAlertIfGroupNameTooLong
{
    UIAlertView *tempAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"group_name_too_long"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
    tempAlert.tag = 100;
    [tempAlert show];
    [tempAlert release];
}
/*
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        int maxLen = GROUPNAME_MAXLEN / 3;
        NSString *textStr = inputField.text;
        if (textStr.length > maxLen) {
            textStr = [textStr substringToIndex:maxLen];
            inputField.text = textStr;
        }
        [self addTextDidChangeObserver];
    }
}
*/

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = inputField.frame;
    if (_frame.size.width == SCREEN_WIDTH - 0.5) {
        return;
    }
    _frame.size.width = SCREEN_WIDTH - 0.5;
    inputField.frame = _frame;
    
    _frame = tipLabel.frame;
    _frame.origin.x = SCREEN_WIDTH - _frame.size.width - 10;
    tipLabel.frame = _frame;
}

@end
