//
//  TextMessageView.h
//  eCloud
//
//  Created by Richard on 13-6-28.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageView.h"
@class MessageView;

@interface TextMessageView : UIView
{
	NSArray *message;
	int rowNum;
}
//显示的最大宽度修改为可以设置
@property (assign) float maxWidth;
@property (nonatomic,retain) UIColor *textColor;

-(void)setMessage:(NSArray *)_message;
@end
