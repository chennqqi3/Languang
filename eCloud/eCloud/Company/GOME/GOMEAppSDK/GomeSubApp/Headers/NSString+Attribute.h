//
//  NSString+Attribute.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/12.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Attribute)

/**
 改变字串中一些特定字的颜色
 
 @param colorStr 颜色Str
 @param range 指定字的Range
 @return 按要求改变后的Str
 */
- (NSMutableAttributedString *)setColorWithStr:(NSString *)colorStr Range:(NSRange)range;
- (NSMutableAttributedString *)setColorWithStr:(NSString *)colorStr Font:(CGFloat)font Bold:(BOOL)bold Range:(NSRange)range;
@end
