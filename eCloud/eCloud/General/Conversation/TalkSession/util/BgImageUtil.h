
//返回显示消息用到的可以拉伸的背景图片，比如时间，比如群组通知，比如发送，接收消息气泡

#import <Foundation/Foundation.h>

@interface BgImageUtil : NSObject

/**
 返回消息时间、群组通知消息用到的背景
 */
+ (UIImage *)getDateBgImage;

/**
 返回发送消息气泡图片
 */
+ (UIImage *)getSndBubbleImage;

/**
 返回高亮的发送消息气泡图片
 */
+ (UIImage *)getSndHighlightBubbleImage;


/**
 返回接收消息的气泡图片
 */
+ (UIImage *)getRcvBubbleImage;

/**
 返回高亮的接收消息的图片
 */
+ (UIImage *)getRcvHighlightBubbleImage;
@end
