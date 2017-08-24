//
//  MsgBodyView.m
//  OpenCtx
//
//  Created by shisuping on 16/10/28.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import "MsgBodyView.h"
#import "LogUtil.h"
#import "talkSessionUtil.h"

#define conf_msg_reply_Button_tag 100201
#define conf_msg_details_Button_tag 192917

@implementation MsgBodyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
    UIButton *replyButton = [self viewWithTag:conf_msg_reply_Button_tag];
    UIButton *detailButton = [self viewWithTag:conf_msg_details_Button_tag];

    if (replyButton && CGRectContainsPoint(replyButton.frame, point)) {
        return replyButton;
    }
    
    if (detailButton && CGRectContainsPoint(detailButton.frame, point)) {
        return detailButton;
    }
    
    return [super hitTest:point withEvent:event];
}
@end
