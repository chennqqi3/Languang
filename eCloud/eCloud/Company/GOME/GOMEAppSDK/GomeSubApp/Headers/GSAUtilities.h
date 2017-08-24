//
//  GSAUtilities.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/28.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import "GSAViewHeader.h"

@interface GSAUtilities : NSObject

+ (UILabel *)labelGrayThreeWithFont:(CGFloat)font;//配色中大量出现@“#333333”
+ (UILabel *)labelGraySixWithFont:(CGFloat)font;//配色中大量出现@“#666666”
+ (UILabel *)labelGrayNineWithFont:(CGFloat)font;//配色中大量出现@“#999999”
+ (UILabel *)labelWithFont:(CGFloat)font TextColor:(NSString *)color;
+ (UILabel *)labelWithText:(NSString *)text Font:(CGFloat)font TextColor:(NSString *)color;

+ (UIView *)viewWithBgColor:(NSString *)color;
+ (UIView *)viewWithBgColor:(NSString *)color Corner:(CGFloat)corner;
+ (UIView *)viewWithBgColor:(NSString *)color Corner:(CGFloat)corner borderColor:(NSString *)borderColor;

+ (UIButton *)buttonWithTitle:(NSString *)title
                    TitleFont:(CGFloat)font
                   TitleColor:(NSString *)colorStr
                   TitleSelectColor:(NSString *)selectColorStr
                          Tag:(NSUInteger)tag
                       Target:(id)target Selector:(SEL)selector;
+ (UIButton *)backButtonTarget:(id)target Selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image Target:(id)target Selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image Select:(UIImage *)selectImage Target:(id)target Selector:(SEL)selector;

+ (UIButton *)buttonWithBlueBorderWithText:(NSString *)text Target:(id)target Selector:(SEL)selector;

+ (UITableView *)tableViewWithAgent:(id)agent;
+ (UIScrollView *)scrollwViewWithAgent:(id)agent;

@end
