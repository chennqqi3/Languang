//
//  RoundCornersLabel.m
//  eCloud
//
//  Created by Alex L on 16/7/11.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RoundCornersLabel.h"

@implementation RoundCornersLabel

- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    // 这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = (30 + height) * 0.05;
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius, 0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);
    // 填充半透明黑色
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1);
    CGContextDrawPath(context, kCGPathFill);
    
    [super drawRect:rect];
}

@end
