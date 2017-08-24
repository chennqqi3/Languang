/*
 * @brief 对OHAttributedLabel的使用进行了一层封装.
 *
 * 支持:点击Link;显示Emoji.
 *
 * @note 1.请修改或重载正则表达式和表情资源名的类函数.(不用委托回调的原因:需要计算高度的类函数 - -)
 *       2.需要支持库：libicucore.dylib、CoreText.framework、QuartzCore.framework
 *
 * @author xiaou.
 * @date 2013.
 * @version 1.0.3
 * @par 修改记录：
 *  -1.0.3:考虑重载的方便,把相关头文件移到OHAttributedLabelEx.h里了.
 */

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"


@protocol OHAttributedLabelExDelegate;

@interface OHAttributedLabelEx : NSObject
{
    id<OHAttributedLabelExDelegate> delegate_;
    
    NSString * text_;
    CGFloat maxWidth_;
    CGPoint frameOrigin_;
}
@property(nonatomic, assign) id<OHAttributedLabelExDelegate> delegate;
@property(nonatomic, copy) NSString * text;
@property(nonatomic) CGFloat maxWidth;/**< 必须设置. */
@property(nonatomic) CGPoint frameOrigin;/**< 起点.size是算出来的～ */

+ (CGSize)heightWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

- (void)setTextColor:(UIColor *)col;
- (void)setLinkColor:(UIColor *)col;
- (void)setFont:(UIFont *)font;
- (UIFont *)font;

- (void)updateUI;/**< @brief 属性都设置好后,将属性作用于UI并刷新. */

- (UIView *)view;
+ (NSArray *)componentsMatchedLinkWithString:(NSString *)text;
+ (NSArray *)componentsMatchedEmojiWithString:(NSString *)text;
@end


@protocol OHAttributedLabelExDelegate <NSObject>

@optional

/** 点击了link. */
-(void)attributedLabelEx:(OHAttributedLabelEx *)label
     didClickLinkWithURL:(NSURL *)linkURL;


@end
