//
//  WXRefreshHeader.m
//  realtyshow
//
//  Created by Alex L on 16/1/17.
//  Copyright © 2016年 深圳市网信科技有限公司. All rights reserved.
//

#import "WXRefreshHeader.h"

@interface WXRefreshHeader ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UIImageView *logo;
@property (weak, nonatomic) UIActivityIndicatorView *loading;
@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation WXRefreshHeader

- (void)prepare
{
    [super prepare];
    
    
    // 设置控件的高度
    self.mj_h = 50;
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
    
    // logo
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow@2x.png"]];
    CGRect rect = logo.frame;
    rect.size = CGSizeMake(15, 27);
    logo.frame = rect;
    [self addSubview:logo];
    self.logo = logo;
    
    // loading
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loading];
    self.loading = loading;
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationbar_back@2x.png"]];
//    [self addSubview:imageView];
//    self.imageView = imageView;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.label.frame = CGRectMake(self.bounds.origin.x, 50, self.bounds.size.width, self.bounds.size.height);
    [self.label setTextColor:[UIColor colorWithWhite:.1f alpha:1]];
    [self.label setFont:[UIFont systemFontOfSize:15]];
    
    self.logo.center = CGPointMake(self.mj_w * 0.35, self.mj_h * 0.5 + 50);
    
    self.loading.center = CGPointMake( self.mj_w * 0.35, self.mj_h * 0.5 + 50);
    
//    self.imageView.center = CGPointMake(self.mj_w * 0.5, - self.logo.mj_h + 20);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
        {
            [self.loading stopAnimating];
            self.label.text = @"";
            self.logo.alpha = 1;
            self.logo.transform = CGAffineTransformMakeRotation(0);
        }
            break;
        case MJRefreshStatePulling:
        {
            [self.loading stopAnimating];
            [UIView animateWithDuration:0.4 animations:^{
                self.logo.transform = CGAffineTransformMakeRotation(-M_PI);
            }];
            self.label.text = @"松开刷新";
        }
            break;
        case MJRefreshStateRefreshing:
        {
            self.label.text = @"     加载数据中...";
            self.logo.alpha = 0;
            [self.loading startAnimating];
        }
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    //    NSLog(@"%f",pullingPercent);
}

@end
