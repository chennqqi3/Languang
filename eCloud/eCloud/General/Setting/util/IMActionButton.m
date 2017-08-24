//
//  ActionButton.m
//  eCloud
//
//  Created by shinehey on 15/2/4.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "IMActionButton.h"
#import "StringUtil.h"

@implementation IMActionButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled)
    {
        if (self.tag == first_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_first.png"] forState:UIControlStateNormal];
        }else if (self.tag == pre_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_pre.png"] forState:UIControlStateNormal];
        }else if (self.tag == next_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_next.png"] forState:UIControlStateNormal];
        }else if (self.tag == last_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_last.png"] forState:UIControlStateNormal];
        }
        
    }else
    {
        if (self.tag == first_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_first_disable.png"] forState:UIControlStateNormal];
        }else if (self.tag == pre_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_pre_disable.png"] forState:UIControlStateNormal];
        }else if (self.tag == next_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_next_disable.png"] forState:UIControlStateNormal];
        }else if (self.tag == last_btn_tag) {
            [self setImage:[StringUtil getImageByResName:@"history_last_disable.png"] forState:UIControlStateNormal];
        }
    }
}

@end
