//
//  PSBackButtonUtil.m
//  eCloud
//
//  Created by Richard on 13-11-7.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSBackButtonUtil.h"
#import "eCloudDAO.h"
#import "PublicServiceDAO.h"
#import "MessageView.h"

@implementation PSBackButtonUtil

#pragma mark 获取并显示未读记录数
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton
{
//    默认显示返回(未读消息条数)
    [self showNoReadNum:db andButton:backButton andBtnTitle:nil];
}

/*
 生成默认的返回按钮
 */
+(UIButton*)initBackButton
{
    return [self initBackButton:nil];
}

/*
 功能描述
 获取导航栏 左边按钮 的 宽度
 
 参数：按钮的标题
 */
+ (float)getLeftButtonWidth:(NSString *)btnTitle
{
    NSString *defaultTitle = [StringUtil getLocalizableString:@"back"];
    
    if ([defaultTitle isEqualToString:btnTitle]) {
        return default_left_button_width;
    }
    
    float defaultWidth = 0.0;
    float curWidth = 0.0;

    if (IOS7_OR_LATER) {
        defaultWidth = [defaultTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:default_button_font_size] forKey:NSFontAttributeName]].width;
        curWidth = [btnTitle sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:default_button_font_size] forKey:NSFontAttributeName]].width;
    }else{
        defaultWidth = [defaultTitle sizeWithFont:[UIFont systemFontOfSize:default_button_font_size]].width;
        curWidth = [btnTitle sizeWithFont:[UIFont systemFontOfSize:default_button_font_size]].width;
    }
    
    if (curWidth > defaultWidth) {
        return default_left_button_width + (curWidth - defaultWidth);
    }
    return default_left_button_width;
 }

/*
 创建返回按钮，标题可以定制
 */
+(UIButton*)initBackButton:(NSString *)btnTitle
{
//    默认是返回
    if (btnTitle == nil || btnTitle.length == 0) {
        btnTitle = [StringUtil getLocalizableString:@"back"];
    }
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, [self getLeftButtonWidth:btnTitle], 40.0);
    
    // old left的值 25
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 25, 0,6);

#ifdef _LANGUANG_FLAG_
    
    UIImage *normalImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"LG_left_button_bg.png"]];
    UIImage *hlNormalImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"LG_left_button_pressed.png"]];
    
#else
    
    UIImage *normalImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"left_button_bg.png"]];
    
#endif
	
	[backButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	[backButton setBackgroundImage:hlNormalImage forState:UIControlStateHighlighted];
    
	backButton.titleLabel.font=[UIFont systemFontOfSize:default_button_font_size];
	backButton.titleLabel.textAlignment = NSTextAlignmentRight;
	[backButton setTitle:btnTitle forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:180/255.0 green:212/255.0 blue:254/255.0 alpha:1] forState:UIControlStateHighlighted];
    
#ifdef _LANGUANG_FLAG_
    // 箭头与文字增加5.5px的间隔
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5.5, 0, 0);
    
    UIColor *_color = [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0];
    [backButton setTitleColor:_color forState:UIControlStateNormal];
    
#endif
    
	return backButton;
}

/*
 返回按钮除了要显示标题外，还要显示未读消息的个数
 */
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton andBtnTitle:(NSString *)btnTitle
{
	int count=[[eCloudDAO getDatabase] getAllNumNotReadedMessge];
	
    NSString *origin= [StringUtil getLocalizableString:@"back"];
    if (btnTitle && btnTitle.length > 0) {
        origin = btnTitle;
    }
	NSString *now =[NSString stringWithFormat:@"%@(%d)",origin,count];
	float defaultWidth = default_left_button_width;
    
    if (count==0)
	{
		CGRect _frame = backButton.frame;
		_frame.size.width = [self getLeftButtonWidth:origin];
		backButton.frame = _frame;
        [backButton setTitle:origin forState:UIControlStateNormal];
    }
	else
    {
		[backButton setTitle:now forState:UIControlStateNormal];
		
		CGRect _frame = backButton.frame;
		_frame.size.width = [self getLeftButtonWidth:now];
		backButton.frame = _frame;
    }
}

@end
