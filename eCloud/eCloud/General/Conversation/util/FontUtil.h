//
//  FontUtil.h
//  eCloud
//
//  Created by shisuping on 15-7-31.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontUtil : NSObject

//会话列表 会话标题 字体

+ (UIFont *)getTitleFontOfConvList;

//会话列表 时间 字体

+ (UIFont *)getLastMsgTimeFontOfConvList;

//会话列表 最后一条消息 字体
+ (UIFont *)getLastMsgFontOfConvList;

@end
