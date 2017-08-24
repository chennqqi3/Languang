//
//  APPBackButtonUtil.m
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPBackButtonUtil.h"
#import "eCloudDAO.h"
#import "MessageView.h"

@implementation APPBackButtonUtil

#pragma mark 获取并显示未读记录数
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton
{
    //    默认显示返回(未读消息条数)
    [self showNoReadNum:db andButton:backButton andBtnTitle:nil];
}

#pragma mark 初始化左边按钮
+(UIButton*)initBackButton
{
    //    默认显示返回
    return [self initBackButton:nil];
}

+(UIButton*)initBackButton:(NSString *)btnTitle
{
    //    默认是返回
    if (btnTitle == nil || btnTitle.length == 0) {
        btnTitle =  [StringUtil getLocalizableString:@"back"];
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
    //  backButton.frame = CGRectMake(5, 7.5, 50, 44);
    backButton.frame = CGRectMake(5, 7.5, 50, 30);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 25, 0, 25);
	UIImage *normalImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"Return_botton.png"]];
	UIImage *clickImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"Return_Click_botton.png"]];
    
	[backButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	[backButton setBackgroundImage:clickImage forState:UIControlStateHighlighted];
	[backButton setBackgroundImage:clickImage forState:UIControlStateSelected];
	
	backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
	backButton.titleLabel.textAlignment = NSTextAlignmentRight;
	
	[backButton setTitle:btnTitle forState:UIControlStateNormal];
	return backButton;
}

+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton andBtnTitle:(NSString *)btnTitle
{
	int count=[[eCloudDAO getDatabase] getAllNumNotReadedMessge];
	
    NSString *origin= [StringUtil getLocalizableString:@"back"];
    if (btnTitle && btnTitle.length > 0) {
        origin = btnTitle;
    }
	NSString *now =[NSString stringWithFormat:@"%@(%d)",origin,count];
	
    if (count==0)
	{
		CGRect _frame = backButton.frame;
		_frame.size.width = 50;
		backButton.frame = _frame;
        [backButton setTitle:origin forState:UIControlStateNormal];
    }
	else
    {
		[backButton setTitle:now forState:UIControlStateNormal];
		
		CGSize originSize = [origin sizeWithFont:[UIFont boldSystemFontOfSize:14]];
		CGSize nowSize = [now sizeWithFont:[UIFont boldSystemFontOfSize:14]];
		CGRect _frame = backButton.frame;
		_frame.size.width = 50 + (nowSize.width - originSize.width);
		backButton.frame = _frame;
    }
}

@end
