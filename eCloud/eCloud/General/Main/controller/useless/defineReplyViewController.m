//
//  defineReplyViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "defineReplyViewController.h"
#import "eCloudUser.h"
#import "conn.h"
#import "eCloudDefine.h"
@interface defineReplyViewController ()

@end

@implementation defineReplyViewController

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
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
	// Do any additional setup after loading the view.
    UINavigationBar *navibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    navibar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
    
    [self.view addSubview:navibar];
    
    UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(110, 15, 100, 20)];
    titlelabel.backgroundColor=[UIColor clearColor];
    titlelabel.textAlignment=UITextAlignmentCenter;
    titlelabel.textColor=[UIColor whiteColor];
    titlelabel.text=@"自定义回复";
    [navibar addSubview:titlelabel];
    [titlelabel release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backButton.frame = CGRectMake(5, 10, 50, 30);
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
    addButton.frame = CGRectMake(260, 10, 50, 30);
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [addButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [addButton setTitle:@"确定" forState:UIControlStateNormal];
    addButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
 //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navibar addSubview:addButton];
    
    UILabel *tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 65, 280, 30)];
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.text=@"最多输入20个字";
    [self.view addSubview:tiplabel];
    [tiplabel release];
    inputField=[[UITextField alloc]initWithFrame:CGRectMake(20, 105,280, 40)];
    inputField.borderStyle=UITextBorderStyleRoundedRect;
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [inputField becomeFirstResponder];
    [self.view addSubview:inputField];
    inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    
    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}

-(void) addButtonPressed:(id) sender{
    if ([inputField.text length]>0) {

        conn* _conn = [conn getConn];
        NSString* userid=_conn.userId;
         [[eCloudUser getDatabase] updateAutoMsg:inputField.text :[userid intValue]];////更新自动回复
        
         [self dismissModalViewControllerAnimated:YES];
        
    }else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
    
    }
 
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
