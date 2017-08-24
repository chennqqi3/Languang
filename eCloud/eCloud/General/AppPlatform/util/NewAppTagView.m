//
//  NewAppTagView.m
//  eCloud
//
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NewAppTagView.h"
#import "MessageView.h"

@implementation NewAppTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIEdgeInsets capInsets = UIEdgeInsetsMake(4.0,9.0,4.0,9.0);
        MessageView *messageView = [MessageView getMessageView];
        UIImage *newMsgImage;
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        /*
        if (IOS7_OR_LATER)
        {
            newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        }
        else{
            newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"News_notes" andType:@"png"]];
        }
        */
        
        newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
        
        UIImageView *newMsgBg = [[UIImageView alloc]initWithImage:newMsgImage];
        
        UILabel *newMsgLabel=[[UILabel alloc]initWithFrame:CGRectZero];
        newMsgLabel.font=[UIFont boldSystemFontOfSize:12];
        newMsgLabel.backgroundColor=[UIColor clearColor];
        newMsgLabel.text = @"New";
        newMsgLabel.textAlignment=UITextAlignmentCenter;
        newMsgLabel.textColor=[UIColor whiteColor];
        [newMsgBg addSubview:newMsgLabel];
        [newMsgLabel release];
        
        [self addSubview:newMsgBg];
        [newMsgBg release];
        
        //高度和y值不变
        float newMsgBgHeight = 20;
        //宽度和x值可变
        float newMsgBgMinWidth = 20;
        float singleNumberWidth = [@"9" sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
        float newNumberWidth = [newMsgLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12]].width;
        float addWidth = newNumberWidth - singleNumberWidth;
        
        float newWidth = newMsgBgMinWidth + addWidth;
        
        CGRect _frame = CGRectMake(2.0, frame.size.height/2-newMsgBgMinWidth/2, newWidth, newMsgBgHeight);
        newMsgBg.frame = _frame;
        _frame = CGRectMake(0, 0, newWidth, newMsgBgHeight);
        newMsgLabel.frame = _frame;
    }
    
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    
//    
//}

@end
