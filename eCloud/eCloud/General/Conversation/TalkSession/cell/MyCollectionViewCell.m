//
//  MyCollectionViewCell.m
//  eCloud
//
//  Created by yanlei on 15/11/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

#define OVERLAY_VIEW_SIZE (35.0)

#pragma mark - 懒加载 图片

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
        NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(_imageView.frame));
    }

    return _imageView;
}

- (UIButton *)overlayView
{
    if (!_overlayView) {
        
        _overlayView = [[UIButton alloc]initWithFrame:CGRectMake((self.bounds.size.width - OVERLAY_VIEW_SIZE), 0, OVERLAY_VIEW_SIZE, OVERLAY_VIEW_SIZE)];
        
        [self addSubview:_overlayView];
        
//        [_overlayView setBackgroundColor:[UIColor blueColor]];
        
        [_overlayView addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _overlayView;
}

#pragma mark - 懒加载 标题
- (UILabel *)title{
    if (!_title) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, 80, 20)];
        
        [_title setTextColor:[UIColor orangeColor]];
        [self addSubview:_title];
    }
    return _title;
}

- (void)clickButton:(id)sender
{
    if ([_delegate respondsToSelector:@selector(clickButton:)] && _delegate) {
        [self.delegate clickButton:sender];        
    }
}

@end
