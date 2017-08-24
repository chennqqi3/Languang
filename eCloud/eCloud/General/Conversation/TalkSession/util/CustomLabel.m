//
//  CustomLabel.m
//  eCloud
//
//  Created by yanlei on 2017/8/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end
