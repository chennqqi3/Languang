//
//  audioTypeChooseViewController.m
//  FPPopoverDemo
//
//  Created by  lyong on 13-12-25.
//  Copyright (c) 2013年 Fifty Pixels Ltd. All rights reserved.
//

#import "audioTypeChooseViewController.h"
#import "StringUtil.h"
#import "eCloudDefine.h"
@interface audioTypeChooseViewController ()

@end

@implementation audioTypeChooseViewController

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
    UIImageView *short_image_view=[[UIImageView alloc]initWithFrame:CGRectMake(2, 0, 19, 38)];
    short_image_view.image=[StringUtil getImageByResName:@"short_audio_icon.png"];
    [self.view addSubview:short_image_view];
    [short_image_view release];
    UIImageView *long_image_view=[[UIImageView alloc]initWithFrame:CGRectMake(0, 40, 19, 38)];
    long_image_view.image=[StringUtil getImageByResName:@"long_audio_icon.png"];
    [self.view addSubview:long_image_view];
    [long_image_view release];
    
    UIImageView *lineview=[[UIImageView alloc]initWithFrame:CGRectMake(15, 45, 60, 1)];
    lineview.image=[StringUtil getImageByResName:@"long_audio_line.png"];
    [self.view addSubview:lineview];
    [lineview release];
	// Do any additional setup after loading the view.
    UIButton *shortbutton=[[UIButton alloc]initWithFrame:CGRectMake(20,10, 60, 30)];
    [shortbutton setTitle:@"语音片" forState:UIControlStateNormal];
    [shortbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shortbutton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [shortbutton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
   // [shortbutton setBackgroundImage:[StringUtil getImageByResName:@"speak_Layer_bj.png"] forState:UIControlStateNormal];
//    [shortbutton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateHighlighted];
//    [shortbutton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateSelected];
    
    UIButton *longbutton=[[UIButton alloc]initWithFrame:CGRectMake(20, 50, 60, 30)];
    [longbutton setTitle:@"长语音" forState:UIControlStateNormal];
    [longbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [longbutton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [longbutton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
  //  [longbutton setBackgroundImage:[StringUtil getImageByResName:@"speak_Layer_bj.png"] forState:UIControlStateNormal];
//    [longbutton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateHighlighted];
//    [longbutton setBackgroundImage:[StringUtil getImageByResName:@"speaking_Button_click.png"] forState:UIControlStateSelected];
    
    
    [self.view addSubview:shortbutton];
    [self.view addSubview:longbutton];
    
    [shortbutton addTarget:self action:@selector(shortAction:) forControlEvents:UIControlEventTouchUpInside];
    [longbutton addTarget:self action:@selector(longAction:) forControlEvents:UIControlEventTouchUpInside];
    [shortbutton release];
    [longbutton release];
}
-(void)shortAction:(id)sender
{
    [[NSNotificationCenter defaultCenter ]postNotificationName:SHORT_AUDIO_NOTIFICATION object:nil userInfo:nil];
}

-(void)longAction:(id)sender
{
     [[NSNotificationCenter defaultCenter ]postNotificationName:LONG_AUDIO_NOTIFICATION object:nil userInfo:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
