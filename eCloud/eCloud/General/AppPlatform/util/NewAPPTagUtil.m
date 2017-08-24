//
//  NewAPPTagUtil.m
//  eCloud
//
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NewAPPTagUtil.h"
#import "StringUtil.h"
#import "MessageView.h"

#define new_msg_number_bg_tag (100)
#define new_msg_number_label_tag (101)

@implementation NewAPPTagUtil

+(void)addAppTagView:(UIView*)iconView
{
    UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
    if (!newMsgBg) {
        //	 新消息数量	在iconView的右上角显示，字体使用白色，背景可以拉伸，
        UIEdgeInsets capInsets = UIEdgeInsetsMake(8.0,8.0,8.0,8.0);
        MessageView *messageView = [MessageView getMessageView];
        UIImage *newMsgImage;
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
//        if (IOS7_OR_LATER){
//            newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
//        }
//        else{
//            newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"News_notes" andType:@"png"]];
//        }
        
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
}

//传入一个数字，确定如何显示未读消息数
+(void)displayaddAppTagView:(UIView*)iconView withText:(NSString *)newText
{
	UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
	UILabel *newMsgLabel=(UILabel *)[newMsgBg viewWithTag:new_msg_number_label_tag];
	if([newText isEqualToString:@"new"])
	{
        //有新应用
		newMsgBg.hidden = NO;
		newMsgLabel.hidden = NO;
        
        newMsgLabel.text=[NSString stringWithFormat:@"%@",newText];
		//高度和y值不变
		float newMsgBgY = -5.0;
		float newMsgBgHeight = 18.0;
		//宽度和x值可变
		float newMsgBgMinWidth = 18.0;
		float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth)+5.0;
		float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:10.0]].width;
        float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0]].width;
        float addWidth = newNumberWidth - singleNumberWidth;
        
        float newWidth = newMsgBgMinWidth + addWidth;
        float newX = newMsgBgMinX - (addWidth / 2);
        
        CGRect _frame = CGRectMake(newX, newMsgBgY, newWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
        _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
        newMsgLabel.frame = _frame;
	}
    else if([newText length] > 0){
        //有推送信息
        newMsgBg.hidden = NO;
		newMsgLabel.hidden = NO;
        
		//高度和y值不变
		float newMsgBgY = - 5;
		float newMsgBgHeight = 12.0;
		//宽度和x值可变
		float newMsgBgMinWidth = 12.0;
		float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth) + 5;
		CGRect _frame = CGRectMake(newMsgBgMinX, newMsgBgY, newMsgBgMinWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
        _frame = CGRectMake(0, 0, newMsgBgMinWidth, newMsgBgHeight);
        newMsgLabel.frame = _frame;
        
        UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        [newMsgBg setImage:newMsgImage];
    }
    else{
        newMsgBg.hidden = YES;
		newMsgLabel.hidden = YES;
    }
}

#pragma mark - tabr是否已显示
+(BOOL)isDidShowTagViewOnTabar:(UIView*)iconView{
    UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
    
    return newMsgBg.hidden;
}
#pragma mark - tabr显示提示
+(void)displayaddTagViewOnTabar:(UIView*)iconView withText:(NSString *)newText{
    UIImageView *newMsgBg=(UIImageView *)[iconView viewWithTag:new_msg_number_bg_tag];
	UILabel *newMsgLabel=(UILabel *)[newMsgBg viewWithTag:new_msg_number_label_tag];
	if([newText isEqualToString:@"new"])
	{
        //有新应用
		newMsgBg.hidden = NO;
		newMsgLabel.hidden = NO;
        
        newMsgLabel.text=[NSString stringWithFormat:@"%@",newText];
		//高度和y值不变
		float newMsgBgY = -1.0;
		float newMsgBgHeight = 18.0;
		//宽度和x值可变
		float newMsgBgMinWidth = 18.0;
        float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth)+3.0;
        if ([UIAdapterUtil isGOMEApp]) {
            newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth)-2.0;
        }
		float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:10.0]].width;
        float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:10.0]].width;
        float addWidth = newNumberWidth - singleNumberWidth;
        
        float newWidth = newMsgBgMinWidth + addWidth;
        float newX = newMsgBgMinX - (addWidth / 2);
        
        CGRect _frame = CGRectMake(newX-10.0, newMsgBgY+7.0, newWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
        _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
        newMsgLabel.frame = _frame;
	}
    else if([newText isEqualToString:@"Push"]){
        //有推送信息，显示红点
        newMsgBg.hidden = NO;
		newMsgLabel.hidden = NO;
        newMsgLabel.text = @"";
        
		//高度和y值不变
		float newMsgBgY = - 5;
		float newMsgBgHeight = 12.0;
		//宽度和x值可变
		float newMsgBgMinWidth = 12.0;
        
        if ([UIAdapterUtil isGOMEApp]) {
            newMsgBgHeight = 9;
            newMsgBgMinWidth = newMsgBgHeight;
        }
		float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth) + 5;
        
        if ([UIAdapterUtil isGOMEApp]) {
            newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth) + 2;
        }

		CGRect _frame = CGRectMake(newMsgBgMinX-26.0, newMsgBgY+10.0, newMsgBgMinWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
        _frame = CGRectMake(0, 0, newMsgBgMinWidth, newMsgBgHeight);
        newMsgLabel.frame = _frame;
        
        UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        [newMsgBg setImage:newMsgImage];
    }
    else if(newText == nil){
        newMsgBg.hidden = YES;
		newMsgLabel.hidden = YES;
    }
    else{
        //显示数字
        int newMsgNumber = [newText integerValue];
        if(newMsgNumber == 0)
        {
            newMsgBg.hidden = YES;
            newMsgLabel.hidden = YES;
        }
        else if(newMsgNumber > 0)
        {
            int maxNumber = 99;
            newMsgBg.hidden = NO;
            newMsgLabel.hidden = NO;
            
            newMsgLabel.text=[NSString stringWithFormat:@"%d",newMsgNumber];
            if (newMsgNumber>maxNumber) {
                newMsgLabel.text = [NSString stringWithFormat:@"%d+",maxNumber];
            }
            
            //高度和y值不变
            float newMsgBgY = - 5;
            float newMsgBgHeight = 20;
            //宽度和x值可变
            float newMsgBgMinWidth = 20;
            float newMsgBgMinX = (iconView.frame.size.width - newMsgBgMinWidth) + 5;
            if(newMsgNumber > 9)
            {
                float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
                float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
                float addWidth = newNumberWidth - singleNumberWidth;
                
                float newWidth = newMsgBgMinWidth + addWidth;
                float newX = newMsgBgMinX - (addWidth / 2);
                
                CGRect _frame = CGRectMake(newX-18.0, newMsgBgY+9.0, newWidth, newMsgBgHeight);
#ifdef _TAIHE_FLAG_
                // 因为泰禾tabbar是5个按钮，未读数位置要调整一下
                _frame = CGRectMake(newX-10.0, newMsgBgY+9.0, newWidth, newMsgBgHeight);
#endif
                newMsgBg.frame = _frame;
                _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
                newMsgLabel.frame = _frame;
                
                if(newMsgNumber>maxNumber){
                    CGRect _frame = CGRectMake(newX-18.0, newMsgBgY+9.0, newWidth-2.0, newMsgBgHeight);
#ifdef _TAIHE_FLAG_
                    // 因为泰禾tabbar是5个按钮，未读数位置要调整一下
                    _frame = CGRectMake(newX-6.0, newMsgBgY+9.0, newWidth-2.0, newMsgBgHeight);
#endif

                    newMsgBg.frame = _frame;
                    _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
                    newMsgLabel.frame = _frame;
                }
            }
            else
            {
                CGRect _frame = CGRectMake(newMsgBgMinX-20.0, newMsgBgY+9.0, newMsgBgMinWidth, newMsgBgHeight);
#ifdef _TAIHE_FLAG_
                // 因为泰禾tabbar是5个按钮，未读数位置要调整一下
                _frame = CGRectMake(newMsgBgMinX-12.0, newMsgBgY+9.0, newMsgBgMinWidth, newMsgBgHeight);
#endif
                newMsgBg.frame = _frame;
                _frame = CGRectMake(0, 0, newMsgBgMinWidth, newMsgBgHeight);
                newMsgLabel.frame = _frame;
            }
        }
    }
}


@end
