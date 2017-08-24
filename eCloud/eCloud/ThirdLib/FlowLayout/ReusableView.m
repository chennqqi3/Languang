//
//  ReusableView.m
//  PlainLayout
//
//  Created by hebe on 15/7/30.
//  Copyright (c) 2015年 ___ZhangXiaoLiang___. All rights reserved.
//

#import "ReusableView.h"
#import "UIAdapterUtil.h"

@implementation ReusableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
        [label setBackgroundColor:[UIColor clearColor]];
        //        [label setBackgroundColor:[UIColor colorWithRed:0x0 green:0x0 blue:0x0 alpha:0.5]];
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setTextColor:[UIAdapterUtil getCustomGrayFontColor]];
        [self addSubview:label];
    }
    return self;
}

-(void)setText:(NSString *)text
{
    _text = text;
    
    ((UILabel *)self.subviews[0]).text = text;
}

@end
