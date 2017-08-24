//
//  FunctionEntranceButton.m
//  eCloud
//
//  Created by shisuping on 15/11/17.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "FunctionEntranceButton.h"
#import "StringUtil.h"
#import "FunctionEntranceModel.h"

@implementation FunctionEntranceButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
//    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(contentRect));
    
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * 0.6;
    return CGRectMake(0,8, imageW, imageH);
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY = contentRect.size.height * 0.6 + 2;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    
    return CGRectMake(0, titleY+1.0, titleW, titleH);
}
@end
