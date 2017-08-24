//
//  SystemMsgModelArc.h
//  eCloud
//
//  Created by Alex-L on 2017/6/23.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_SYSTEM_TYPE @"MsgType"
#define KEY_SYSTEM_CONTENT @"MSContent"
#define KEY_SYSTEM_TITLE @"title"
#define KEY_SYSTEM_DESCRIPTION @"description"
#define KEY_SYSTEM_PIC @"picurl"
#define KEY_SYSTEM_URL @"url"

#define TYPE_TEXT  @"text"
#define TYPE_PIC   @"image"
#define TYPE_NEWS  @"news"
#define TYPE_VIDEO @"video"
#define TYPE_VOICE @"voice"

@interface SystemMsgModelArc : NSObject

/** 消息类型 */
@property (nonatomic, copy) NSString *msgType;
/** 消息内容（type_text）图片下载地址（type_image） */
@property (nonatomic, copy) NSString *msgBody;
/** 标题（type_url） */
@property (nonatomic, copy) NSString *title;
/** 摘要（type_url） */
@property (nonatomic, copy) NSString *descriptionStr;
/** 点击跳转的网址（type_url） */
@property (nonatomic, copy) NSString *urlStr;

@end
