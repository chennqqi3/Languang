//
//  ReceiptCollectionFooterView.m
//  eCloud
//
//  Created by Alex L on 15/11/6.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ReceiptCollectionFooterView.h"

#define EXPAND_BUTTON_Y 5
#define EXPAND_BUTTON_WIRTH 55
#define EXPAND_BUTTON_HEIGHT 35

#define expandOrPutAwary_FONT 13

@implementation ReceiptCollectionFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.expandOrPutAwary = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - EXPAND_BUTTON_WIRTH - 10, EXPAND_BUTTON_Y, EXPAND_BUTTON_WIRTH, EXPAND_BUTTON_HEIGHT)];
        [self.expandOrPutAwary setFont:[UIFont systemFontOfSize:expandOrPutAwary_FONT]];
        [self.expandOrPutAwary setTitleColor:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/252.0 alpha:1] forState:UIControlStateNormal];
        
        [self.expandOrPutAwary addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.expandOrPutAwary];
    }
    return self;
}

- (void)clickBtn:(UIButton *)sender
{
    if (_reloadDelegate && [_reloadDelegate respondsToSelector:@selector(reload:)])
    {
        [_reloadDelegate reload:sender.tag];
    }
}

@end
