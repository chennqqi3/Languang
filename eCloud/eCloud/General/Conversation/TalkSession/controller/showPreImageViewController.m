//
//  showPreImageViewController.m
//  eCloud
//
//  Created by  lyong on 12-11-13.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "showPreImageViewController.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "talkSessionViewController.h"

@interface showPreImageViewController ()

@end

@implementation showPreImageViewController
@synthesize  imageData;
@synthesize imageView;
@synthesize  delegete;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
	[super dealloc];
	NSLog(@"%s",__FUNCTION__);

//	self.imageData = nil;
//	self.imageView = nil;
//	self.delegete = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	int imageViewH = 460;
	if(iPhone5)
		imageViewH = imageViewH + i5_h_diff;
	
    imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, imageViewH)];
    [self.view addSubview:imageView];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.backgroundColor=[UIColor blackColor];
    imageView.image=self.imageData;
    imageView.userInteractionEnabled=YES;
	// Do any additional setup after loading the view.
    [imageView release];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 30);
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
     
    self.title=[StringUtil getLocalizableString:@"chats_talksession_message_photo_preview"];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake((320-100)/2.0, 460-44+5, 100, 35);
    //    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"login_botton_ico1.png"] forState:UIControlStateNormal];
    //    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"login_botton_click_ico1.png"] forState:UIControlStateHighlighted];
    //    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"login_botton_click_ico1.png"] forState:UIControlStateSelected];
    
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[StringUtil getImageByResName:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    UILabel *backgroudlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 460-44, 320, 44)];
    backgroudlabel.backgroundColor=[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    backgroudlabel.alpha=0.6;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0&&imageViewH==460) {
        sendButton.frame = CGRectMake((320-100)/2.0, 460-90+5, 100, 35);
        backgroudlabel.frame=CGRectMake(0, 460-90, 320, 44);
    }

    //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:backgroudlabel];
    [imageView addSubview:sendButton];
    [backgroudlabel release];
}
-(void)backButtonPressed:(id)sender
{
    [self.imageData release];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonPressed:(id)sender
{

 [self performSelector:@selector(delaySend) withObject:nil afterDelay:0.5];
   
}

-(void)delaySend
{    
    NSData * data =UIImageJPEGRepresentation(self.imageData, 0.5);
    [self.imageData release];
    NSLog(@"-----------------picdata--: %d",data.length);
    [((talkSessionViewController *)self.delegete) displayAndUploadPic:data];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [imageData release];
    [imageView release];
    [delegete release];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
