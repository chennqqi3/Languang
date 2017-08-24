//
//  MyFrame.m
//  OMESPACE
//
//  Created by lidianchao on 15/6/10.
//  Copyright (c) 2015年 lidianchao. All rights reserved.
//

#import "GYFrame.h"

@implementation GYFrame
+ (CGRect)myRect:(CGRect)rect
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

#pragma -mark RectWithFixedValue
+ (CGRect)myRectWithFixedXValue:(CGRect)rect fixedValue:(CGFloat)value
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGRectMake(value, rect.origin.y*myY, rect.size.width*myX, rect.size.height*myY);
}
+ (CGRect)myRectWithFixedYValue:(CGRect)rect fixedValue:(CGFloat)value
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGRectMake(rect.origin.x*myX, value, rect.size.width*myX, rect.size.height*myY);
}
+ (CGRect)myRectWithFixedWidthValue:(CGRect)rect fixedValue:(CGFloat)value
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGRectMake(rect.origin.x*myX, rect.origin.y*myY, value, rect.size.height*myY);
}
+ (CGRect)myRectWithFixedHeightValue:(CGRect)rect fixedValue:(CGFloat)value
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGRectMake(rect.origin.x*myX, rect.origin.y*myY, rect.size.width*myX, value);
}
+ (CGSize)mySize:(CGSize)size
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGSizeMake(size.width*myX, size.height*myY);
}
+ (CGPoint)myPoint:(CGPoint)point
{
    CGFloat myX = (kScreenWidth * 1.0)/kIPHONE5sWIDTH;
    CGFloat myY = (kScreenHeight * 1.0)/kIPHONE5sHEIGHT;
    return CGPointMake(point.x*myX, point.y*myY);
}
+ (NSString *)iphoneType {
        
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
