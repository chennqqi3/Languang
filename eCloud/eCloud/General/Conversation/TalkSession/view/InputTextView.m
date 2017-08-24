//
//  InputTextView.m
//  eCloud
//
//  Created by  lyong on 13-8-3.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "InputTextView.h"
#import "talkSessionViewController.h"

@implementation InputTextView
@synthesize copypic;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
//显示菜单
- (void)showMenu:(id)cell{
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
//    update by shisp 如果是粘贴，那么判断如果是图片，那么先把图片写到本地
//    不写到本地，否则体验不好
    if (action == @selector(paste:)) {
        UIPasteboard *_board = [UIPasteboard generalPasteboard];
        UIImage *_image = _board.image;
        if (_image) {
            return YES;
        }
     }
    
    return [super canPerformAction:action withSender:sender];
}

-(void)paste:(id)sender
{
//    粘贴时，如果粘贴的是图片，那么要预览图片先
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.image) {
        [((talkSessionViewController*)self.delegate) alertSendCopyPic:pasteboard.image];
    }
    else
    {
        [super paste:sender];
    }
    
}
-(void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.text];
    self.copypic=false;
}

@end
