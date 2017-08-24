//
//  AudioToTextView.m
//  eCloud
//
//  Created by yanlei on 15/11/13.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "AudioToTextView.h"

@implementation AudioToTextView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self txtLoadingLabel];
        [self txtLoadingTxt];
        [self txtCancelBtn];
        [self txtLabel];
    }
    return self;
}

#pragma mark - 懒加载
// 初始化加载文本
- (UILabel *)txtLoadingLabel{
    if (!_txtLoadingLabel) {
        _txtLoadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/2-50.f, 100, 100, 30)];
        _txtLoadingLabel.hidden = YES;
        _txtLoadingLabel.text = @"正在转换...";
        _txtLoadingLabel.textAlignment = NSTextAlignmentLeft;
        _txtLoadingLabel.textColor = [UIColor grayColor];
        _txtLoadingLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_txtLoadingLabel];
        [_txtLoadingLabel release];
    }
    return _txtLoadingLabel;
}

// 初始化加载文本
- (UIActivityIndicatorView *)txtLoadingTxt{
    if (!_txtLoadingTxt) {
        CGRect rect = CGRectMake(self.bounds.size.width/2-80.f,100, 30.0f,30.0f);
        _txtLoadingTxt = [[UIActivityIndicatorView alloc]initWithFrame:rect];
        _txtLoadingTxt.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _txtLoadingTxt.hidden = YES;
        [self addSubview:_txtLoadingTxt];
        [_txtLoadingTxt release];
    }
    return _txtLoadingTxt;
}

// 初始化加载过程中的取消按钮
- (UIButton *)txtCancelBtn{
    if (!_txtCancelBtn) {
        _txtCancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width/2-30.f, self.bounds.size.height-80, 60, 60)];
        [_txtCancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
        _txtCancelBtn.hidden = YES;
        [_txtCancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self addSubview:_txtCancelBtn];
        [_txtCancelBtn release];
    }
    return _txtCancelBtn;
}

// 显示语音文本的控件
- (UILabel *)txtLabel{
    if (!_txtLabel) {
        _txtLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _txtLabel.tag = 5521;
        _txtLabel.hidden = YES;
        _txtLabel.numberOfLines = 0;
        _txtLabel.textColor = [UIColor blackColor];
        _txtLabel.backgroundColor = [UIColor clearColor];
        _txtLabel.textAlignment = NSTextAlignmentCenter;
        _txtLabel.userInteractionEnabled = YES;
        [self addSubview:_txtLabel];
        [_txtLabel release];
    }
    return _txtLabel;
}

@end
