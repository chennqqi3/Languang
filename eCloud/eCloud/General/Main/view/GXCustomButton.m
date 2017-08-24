//
//  GXCustomButton.m
//  test11
//
//  Created by Pain on 14-7-23.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "GXCustomButton.h"

@implementation GXCustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/**
 重写按钮上图片的位置

 @param contentRect 原来图片的frame

 @return 图片新的frame
 */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
 {
     CGFloat imageW = contentRect.size.width;
     CGFloat imageH = contentRect.size.height * 0.6;
     return CGRectMake(0,5.5, imageW, imageH);
 }

/**
 重写按钮上标题的位置
 
 @param contentRect 原来标题的frame
 
 @return 标题新的frame
 */
- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY = contentRect.size.height *0.6;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    
    return CGRectMake(0, titleY+1.0, titleW, titleH);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
