//
//  textInputViewController.m
//  eCloud
//
//  Created by  lyong on 13-11-5.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "textInputViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "addScheduleViewController.h"
#import "editScheduleViewController.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"

@interface textInputViewController ()
@property(nonatomic,retain) UILabel *tiplabel;
@end

@implementation textInputViewController
@synthesize detailField;
@synthesize predelegete;
@synthesize fromtype;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger strLength = textView.text.length - range.length + text.length;
   
    return (strLength <= 100);
}
- (void)textViewDidChange:(UITextView *)textView
{
    int count=100-textView.text.length;
    if (count<0) {
        count=0;
    }
  self.tiplabel.text=[NSString stringWithFormat:@"%d%@",count,[StringUtil getLocalizableString:@"schedule_words"]];
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}
#pragma mark keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
		NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
		NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
		CGRect keyboardBounds;
		[keyboardBoundsValue getValue:&keyboardBounds];
	
		self.tiplabel.frame=CGRectMake(310-80-5, self.view.frame.size.height-keyboardBounds.size.height-20, 80, 20);
        self.detailField.frame=CGRectMake(5, 5, 310, self.view.frame.size.height-keyboardBounds.size.height-5);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	}
#endif
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=[StringUtil getLocalizableString:@"schedule_eidt_details"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    UIButton*rightButton = [[UIButton  alloc]initWithFrame:CGRectMake(0,0,50,30)];
    [rightButton addTarget:self action:@selector(saveAction:)forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"√" forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [rightButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    rightButton.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    self.navigationController.navigationItem.rightBarButtonItem =rightItem;

    self.detailField=[[UITextView alloc]initWithFrame:CGRectMake(5, 5, 310, 190)];
    //self.detailField.placeholder=@"请输入...";
    self.detailField.delegate=self;
    self.detailField.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.detailField.layer.borderWidth= 0.5f;
    self.detailField.font=[UIFont systemFontOfSize:14];
    self.detailField.backgroundColor=[UIColor whiteColor];
    [self.detailField becomeFirstResponder];
    [self.view addSubview:self.detailField];
   
    self.tiplabel=[[UILabel alloc]initWithFrame:CGRectMake(310-80-5, 190-25, 80, 20)];
    self.tiplabel.backgroundColor=[UIColor clearColor];
    self.tiplabel.textColor=[UIColor lightGrayColor];
    self.tiplabel.text= [NSString stringWithFormat:@"100%@",[StringUtil getLocalizableString:@"schedule_words"]];
    self.tiplabel.font=[UIFont systemFontOfSize:12];
    self.tiplabel.textAlignment=NSTextAlignmentRight;
    [self.view addSubview:self.tiplabel];
   // [tiplabel release];
	// Do any additional setup after loading the view.
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveAction:(id)sender
{
    NSLog(@"---saveAction");
    if (self.detailField.text.length==0) {
        return;
    }
    if (self.fromtype!=1) {
        ((addScheduleViewController *)self.predelegete).detailField.text=self.detailField.text;
//        ((addScheduleViewController *)self.predelegete).detailField.frame=CGRectMake(0, 0, 320, 30);
//        ((addScheduleViewController *)self.predelegete).detailLineImage.frame=CGRectMake(5, 41, 313, 1);
//        ((addScheduleViewController *)self.predelegete).detailView.frame=CGRectMake(0, 0, 320, 45);
        
    }else
    {
        ((editScheduleViewController *)self.predelegete).detailField.text=self.detailField.text;
//        ((editScheduleViewController *)self.predelegete).detailField.frame=CGRectMake(0, 0, 320, 30);
//        ((editScheduleViewController *)self.predelegete).detailLineImage.frame=CGRectMake(5, 41, 313, 1);
//        ((editScheduleViewController *)self.predelegete).detailView.frame=CGRectMake(0, 0, 320, 45);
    }

    
     [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
