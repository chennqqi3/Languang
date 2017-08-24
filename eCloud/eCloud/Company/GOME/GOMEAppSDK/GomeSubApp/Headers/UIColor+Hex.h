//
//  UIColor+Hex.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/13.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
/**
 根据色值设定颜色

 @param stringToConvert 色值字符串
 @return 色值对应的UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert AndAlpha:(CGFloat)alpha;

@end
