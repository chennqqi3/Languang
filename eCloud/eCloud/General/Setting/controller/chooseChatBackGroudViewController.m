//
//  chooseChatBackGroudViewController.m
//  eCloud
//
//  Created by  lyong on 14-6-25.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "chooseChatBackGroudViewController.h"
#import "ChatBackgroundUtil.h"

#import <QuartzCore/QuartzCore.h>
#import "StringUtil.h"
#import "talkSessionViewController.h"
#import "UIAdapterUtil.h"
#import "UserDefaults.h"
#import "settingViewController.h"

#import "eCloudDefine.h"

@interface chooseChatBackGroudViewController ()
{
    NSInteger selctedtag;
}

@end

@implementation chooseChatBackGroudViewController
@synthesize one_chat_imagename;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 210)];
    memberScroll.scrollEnabled=NO;
    [self.view addSubview:memberScroll];
    [self showOldMemberScrollow];
    [memberScroll release];
    
    }
- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    selectedView=[[UIImageView alloc]initWithFrame:CGRectMake(100-30, 100-30, 25, 25)];
    selectedView.image = [StringUtil getImageByResName:@"photo_Selection_ok.png"];
}
-(void)removeSubviewFromScrollowView
{
    for (UIView *eachView in [memberScroll subviews])
    {
        [eachView removeFromSuperview];
    }
    
}
-(void)showOldMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
    
    int showiconNum=3;
    
    // 默认为4
    int sumnum = 4;
    if ([eCloudConfig getConfig].backgroundPicNum) {
        
        sumnum=[[eCloudConfig getConfig].backgroundPicNum intValue];
    }
    
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
	memberScroll.pagingEnabled = NO;
    memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width , memberScroll.frame.size.height* pagenum);
    memberScroll.showsHorizontalScrollIndicator = YES;
    memberScroll.showsVerticalScrollIndicator = YES;
    memberScroll.scrollsToTop = NO;
    
	UIButton *pageview;
	
	int nowindex=0;
    UIView *itemview;
	UIButton *iconbutton;
    
	int x;
	int y;
	int cx;
	int cy;
    
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, memberScroll.frame.size.width, memberScroll.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
  //  [pageview addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
    
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[talkSessionViewController class]])
        {
            // 来自会话界面
            NSString *convid = [(talkSessionViewController *)controller getConvid];
            
            if ([UserDefaults getConvBackgroundSelected:convid] >= 0)
            {
                selctedtag = [UserDefaults getConvBackgroundSelected:convid];
                break;
            }else{
                // 来自会话界面, 但用的是通用的背景设置
                selctedtag = [UserDefaults getBackgroundSelected];
                break;
            }
        }else if([controller isKindOfClass:[settingViewController class]]){
            // 不是来自会话界面, 来自通用设置
            selctedtag = [UserDefaults getBackgroundSelected];
            break;
        }
    }
    
	x=0;
	y=0;
	cx=5;
	cy=0;
	
    int row=0;
	for (int j=0; j<sumnum; j++) {
        
        nowindex=j;
        CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
        CGFloat  padding = (screenW - 3*100) * 0.25f;
		if (j/3==row) {
            
            // changed by toxicanty 0803
            //cx=cx+106;
            
            cx = cx + 100 + padding;
			if (j==0) {
                cx=padding;
            }
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx,y+cy+5+9+5,100,100)];
            
			
		}else if (j/3!=row) {
        	
            cx=padding;
            cy=cy+100+padding;
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx,y+cy+5+9+5,100,100)];
            
		}
        
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,100,100)];
        [iconbutton addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        
        itemview.layer.cornerRadius = 3;//设置那个圆角的有多圆
//        itemview.layer.borderWidth = 1;//设置边框的宽度，当然可以不要
//        itemview.layer.borderColor = [[UIColor whiteColor] CGColor];//设置边框的颜色
        itemview.layer.masksToBounds = YES;//设为NO去试试
        
        [itemview addSubview:iconbutton];
        [iconbutton release];
        
		row=j/3;
		UIImage *image = nil;
  
        image = [StringUtil getImageByResName:[NSString stringWithFormat:@"ChatBackground_%d.png",nowindex]];
        
		[iconbutton setBackgroundImage:image forState:UIControlStateNormal];
		iconbutton.tag=nowindex;

        if (selctedtag == nowindex) {
            
            [iconbutton addSubview:selectedView]; // 0915
        }

		iconbutton.backgroundColor=[UIColor clearColor];
		
		[pageview addSubview:itemview];
        [itemview release];
	}
	pageview.frame=CGRectMake(0, 0,memberScroll.frame.size.width,y+cy+115);
	//pageview.backgroundColor=[UIColor clearColor];
	[memberScroll addSubview:pageview];
	memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width, y+cy+115);
    
	[pageview release];
    
    memberScroll.frame=CGRectMake(0, 10, self.view.frame.size.width, y+cy+200);
    
}
-(void)clickAction:(id)sender
{
    selectedView.hidden=NO;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    UIButton *button=(UIButton *)sender;
    [button addSubview:selectedView];
    
	UIImage *image = button.currentBackgroundImage;
    NSData* data =UIImageJPEGRepresentation(image, 1);
    
    //存入本地
    NSString *picpath = [ChatBackgroundUtil getCommonBackgroundPath];
    if (self.one_chat_imagename.length>0) {
        picpath = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:self.one_chat_imagename];
    }
    NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
    
    if (data!=nil) {
        BOOL success= [data writeToFile:picpath atomically:YES];
        if (!success) {
            [pool release];
            return;
        }
        [pool release];
        
        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        [accountDefaults setBool:YES forKey:@"is_chat_backgroud_change"];
    }
    for(UIViewController *controller in self.navigationController.viewControllers)
    {
        if([controller isKindOfClass:[settingViewController class]])
        {
            // 保存设置通用背景图片 0915
            [UserDefaults setBackgroundSelected:button.tag];
            break;
        }else if([controller isKindOfClass:[talkSessionViewController class]]){
            // 保存会话中的背景图片
            [UserDefaults setConvBackgroundSelected:[[talkSessionViewController getTalkSession] getConvid] andSelectTag:button.tag];
            break;
        }
    }
    
    if (self.one_chat_imagename.length>0){
        
        for(UIViewController *controller in self.navigationController.viewControllers)
        {
            if([controller isKindOfClass:[talkSessionViewController class]])
            {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
