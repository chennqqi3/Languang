//add by shisp
//日志类

#import <Foundation/Foundation.h>

@interface LogUtil : NSObject
#pragma mark 记日志
+(void)debug:(NSString*)logStr;

//给功能按钮增加长按事件 发送当天日志
+ (void)addLongPressToButton1:(UIButton *)button;

//发送昨天日志
+ (void)addLongPressToButton2:(UIButton *)button;

//发送前天日志
+ (void)addLongPressToButton3:(UIButton *)button;

//发送eCloud.log
+ (void)addLongPressToButton4:(UIButton *)button;

//给功能按钮增加长按事件 发送异常日志
+ (void)addLongPressToButton5:(UIButton *)button;

@end
