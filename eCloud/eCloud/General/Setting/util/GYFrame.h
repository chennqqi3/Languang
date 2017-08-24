//
//  MyFrame.h
//  OMESPACE
//
//  Created by lidianchao on 15/6/10.
//  Copyright (c) 2015年 lidianchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screen.h"
#import <sys/utsname.h>

@interface GYFrame : UIView
/*
 *默认以iPhone5s机型大小为基础做适配，只适用于宽：高为9：16比例的机型
 */
+ (CGRect)myRect:(CGRect)rect;
+ (CGRect)myRectWithFixedXValue:(CGRect)rect fixedValue:(CGFloat)value;
+ (CGRect)myRectWithFixedYValue:(CGRect)rect fixedValue:(CGFloat)value;
+ (CGRect)myRectWithFixedWidthValue:(CGRect)rect fixedValue:(CGFloat)value;
+ (CGRect)myRectWithFixedHeightValue:(CGRect)rect fixedValue:(CGFloat)value;
+ (CGSize)mySize:(CGSize)size;
+ (CGPoint)myPoint:(CGPoint)point;
+ (NSString *)iphoneType;
@end
