//
//  FontUtil.m
//  eCloud
//
//  Created by shisuping on 15-7-31.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "FontUtil.h"
#import "IOSSystemDefine.h"

@implementation FontUtil
//会话列表 会话标题 字体

+ (UIFont *)getTitleFontOfConvList
{
#ifdef _LANGUANG_FLAG_
    return [UIFont systemFontOfSize:17];
#else
    return [UIFont systemFontOfSize:17];
#endif
    
    if (IOS7_OR_LATER)
    {
        return [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else
    {
        return [UIFont boldSystemFontOfSize:17];
    }
}

//会话列表 时间 字体

+ (UIFont *)getLastMsgTimeFontOfConvList
{
    
    return [UIFont systemFontOfSize:12];
    if (IOS7_OR_LATER) {
        return [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    else
    {
        return [UIFont systemFontOfSize:11];
    }
}

//会话列表 最后一条消息 字体
+ (UIFont *)getLastMsgFontOfConvList
{
#ifdef _LANGUANG_FLAG_
    return [UIFont systemFontOfSize:14];
#else
    return [UIFont systemFontOfSize:14.0f];
#endif
    
    if (IOS7_OR_LATER) {
        return [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    else
    {
        return [UIFont systemFontOfSize:14.0f];
    }
}
@end
