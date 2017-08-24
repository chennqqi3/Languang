//
//  NewMsgNumberUtil.m
//  eCloud
//
//  Created by Richard on 14-1-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NewMsgNumberUtil.h"
#import "StringUtil.h"
#import "MessageView.h"
#import "QueryResultCell.h"

@implementation NewMsgNumberUtil

//在UIImageView的基础上，增加一个UIImageView，用来显示消息

+(void)addNewMsgNumberView:(UIView*)iconView
{
	//	 新消息数量	在iconView的右上角显示，字体使用白色，背景可以拉伸，
	UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
	MessageView *messageView = [MessageView getMessageView];
//	UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"News_notes" andType:@"png"]];
    UIImage *newMsgImage;
    newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
    /*
    if (IOS7_OR_LATER){
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
    }
    else{
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"News_notes" andType:@"png"]];
    }
    */
    
	newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
	
	UIImageView *newMsgBg = [[UIImageView alloc]initWithImage:newMsgImage];
	newMsgBg.tag = new_msg_number_bg_tag;
	newMsgBg.hidden = YES;

	UILabel *newMsgLabel=[[UILabel alloc]initWithFrame:CGRectZero];
	newMsgLabel.tag=new_msg_number_label_tag;
	newMsgLabel.hidden=YES;
	newMsgLabel.font=[UIFont boldSystemFontOfSize:11];
	newMsgLabel.backgroundColor=[UIColor clearColor];
	newMsgLabel.textAlignment=UITextAlignmentCenter;
	newMsgLabel.textColor=[UIColor whiteColor];
	[newMsgBg addSubview:newMsgLabel];
	[newMsgLabel release];
	
	[iconView addSubview:newMsgBg];
	[newMsgBg release];

}

//传入一个数字，确定如何显示未读消息数
//以前南航版本 新消息条数 是 显示在iconView上的 万达版本是显示在time下面的 所以不用加在iconView上了
+(void)displayNewMsgNumber:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber
{
    [self displayNewMsgNumber:iconView andNewMsgNumber:newMsgNumber andNewMsgBgHeight:20.0 andNewMsgFontSize:12.0];
}

+ (void)displayNewMsgNumber:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber andNewMsgBgHeight:(float)newMsgBgH andNewMsgFontSize:(float)newMsgFontSize
{
//    测试数据
    //    newMsgNumber = 999;
    
    UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
    UILabel *newMsgLabel=(UILabel *)[newMsgBg viewWithTag:new_msg_number_label_tag];
    
    if(newMsgNumber == 0)
    {
        newMsgBg.hidden = YES;
        newMsgLabel.hidden = YES;
    }
    else if(newMsgNumber > 0)
    {
        //        不在这里设置位置，只计算宽度
        //        QueryResultCell *queryCell = [[[QueryResultCell alloc] init]autorelease];
        //        UILabel *timeLable = (UILabel *)[queryCell viewWithTag:time_tag];
        //        CGPoint timeCenter = timeLable.center;
        
        newMsgBg.hidden = NO;
        newMsgLabel.hidden = NO;
        
        newMsgLabel.text=[NSString stringWithFormat:@"%d",newMsgNumber];
        if (newMsgNumber>99) {
            newMsgNumber = 99;
            newMsgLabel.text=[NSString stringWithFormat:@"99+"];
        }
        
        //高度和y值不变
        float newMsgBgY = 0;//- 5;
        float newMsgBgHeight = newMsgBgH;
        //宽度和x值可变
        float newMsgBgMinWidth = newMsgBgHeight;
        float newMsgBgMinX = 0;//(iconView.frame.size.width - newMsgBgMinWidth) + 5;
        if(newMsgNumber > 9)
        {
            float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:newMsgFontSize]].width;
            float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:newMsgFontSize]].width;
            float addWidth = newNumberWidth - singleNumberWidth;
            
            float newWidth = newMsgBgMinWidth + addWidth;
            float newX = newMsgBgMinX - (addWidth / 2);
            
            CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newWidth, newMsgBgHeight);
            newMsgBg.frame = _frame;
            //            newMsgBg.center = CGPointMake(timeCenter.x-15, timeCenter.y+16);
            _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
            newMsgLabel.frame = _frame;
        }
        else
        {
            CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newMsgBgMinWidth, newMsgBgHeight);
            newMsgBg.frame = _frame;
            //            newMsgBg.center = CGPointMake(timeCenter.x-15, timeCenter.y+16);
            _frame = CGRectMake(0, 0, newMsgBgMinWidth, newMsgBgHeight);
            newMsgLabel.frame = _frame;
        }
        
    }
    else if(newMsgNumber < 0)
    {
        //        以前 如果 屏蔽了 群组 消息，那么只显示一个红点，但是万达版本已经不再使用了
        newMsgBg.hidden = NO;
        newMsgLabel.hidden = YES;
        
        newMsgBg.frame = CGRectMake(0, 0, 12,12);
        //		//高度和y值不变
        //		float newMsgBgY = - 5;
        //		float newMsgBgHeight = 15;
        //		//宽度和x值可变
        //		float newMsgBgMinWidth = 15;
        //		float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth);
        //        CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newMsgBgMinWidth, newMsgBgHeight);
        //        newMsgBg.frame = _frame;
        //        newMsgBg.center = CGPointMake(timeCenter.x-17, timeCenter.y+20);
    }
    
}
//传入一个数字，确定如何显示未读消息数(在NewMyViewController中使用)
+(void)displayNewMsgNumberForMyViewCtrl:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber
{
    UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
    UILabel *newMsgLabel=(UILabel *)[newMsgBg viewWithTag:new_msg_number_label_tag];
    if(newMsgNumber == 0)
    {
        newMsgBg.hidden = YES;
        newMsgLabel.hidden = YES;
    }
    else if(newMsgNumber > 0)
    {
        newMsgBg.hidden = NO;
        newMsgLabel.hidden = NO;
        
        newMsgLabel.text=[NSString stringWithFormat:@"%d",newMsgNumber];
        //高度和y值不变
        float newMsgBgY = - 5;
        float newMsgBgHeight = 20;
        //宽度和x值可变
        float newMsgBgMinWidth = 20;
        float newMsgBgMinX = 0;//(iconView.frame.size.width - newMsgBgMinWidth) + 5;
        if(newMsgNumber > 9)
        {
            float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
            float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
            float addWidth = newNumberWidth - singleNumberWidth;
            
            float newWidth = newMsgBgMinWidth + addWidth;
            float newX = newMsgBgMinX - (addWidth / 2);
            
            CGRect _frame = CGRectMake(newX, newMsgBgY, newWidth, newMsgBgHeight);
            newMsgBg.frame = _frame;
            _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
            newMsgLabel.frame = _frame;
        }
        else
        {
            CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newMsgBgMinWidth, newMsgBgHeight);
            newMsgBg.frame = _frame;
            _frame = CGRectMake(0, 0, newMsgBgMinWidth, newMsgBgHeight);
            newMsgLabel.frame = _frame;
        }
    }
    else if(newMsgNumber < 0)
    {
        newMsgBg.hidden = NO;
        newMsgLabel.hidden = YES;
        
        //高度和y值不变
        float newMsgBgY = - 5;
        float newMsgBgHeight = 15;
        //宽度和x值可变
        float newMsgBgMinWidth = 15;
        float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth) + 5;
        
        CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newMsgBgMinWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
    }
}

+ (void)setUnreadViewFrame:(UIView *)iconview{
    UIImageView *newMsgBg = (UIImageView *) [iconview viewWithTag:new_msg_number_bg_tag];
    
    CGRect _frame = newMsgBg.frame;
    
    _frame.origin.x = iconview.frame.size.width - _frame.size.width * 0.5;
#if defined(_LANGUANG_FLAG_) || defined(_XIANGYUAN_FLAG_)
    
    _frame.origin.y = 0;
    
#else
    
    _frame.origin.y = -_frame.size.height * 0.5;
    
#endif
    
    
//    泰和版本是把新消息数加到一个UIButton上的，并且在ipad上UIButton比bgImage尺寸要大，所以未读数显示不正确，现在重新计算
    if ([iconview isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)iconview;
        UIImage *bgImage = btn.currentImage;
        if (bgImage) {
            if (btn.frame.size.width > bgImage.size.width && btn.frame.size.height > bgImage.size.height) {
                _frame.origin.x = (btn.frame.size.width - bgImage.size.width) * 0.5 + bgImage.size.width - _frame.size.width * 0.5;
                _frame.origin.y = (btn.frame.size.height - bgImage.size.height) * 0.5 - _frame.size.height * 0.5;
            }
        }
    }
    
    newMsgBg.frame = _frame;
}


@end
