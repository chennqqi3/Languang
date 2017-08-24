//
//  PSMsgUtil.h
//  eCloud
//  显示公众号消息的工具类 公众号和普通消息一样 显示在talksessionController这个类里面。公众号消息有新闻类型(单条或者多条)，文本类型、图片类型
//  Created by Richard on 13-11-1.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ps_picmsg_pic_prefix @"ps_pic_"

//	行高定义
//	第一行
#define ps_msg_row0_height (180)
//	其它行
#define ps_msg_row1_height (60)

//推送消息大图显示高度
#define ps_big_pic_height (160)

//时间高度
#define ps_msg_date_row_height (40)
//
#define ps_title_tag 100
#define ps_image_tag 101
#define ps_image_background_tag 111
#define ps_spinner_tag 102

#define ps_time_tag 103
#define ps_desc_tag 104

#define ps_line_tag 105
#define ps_read_tag 106

//时间
#define ps_msg_time_tag 200
#define ps_msg_time_text_tag 201

#define max_content_width (280)

@class ServiceMessageDetail;
@class ServiceMessage;
@class ConvRecord;

@interface PSMsgUtil : NSObject

//用于单图文显示
+ (UITableViewCell *)singlePsMsgTableViewCellWithReuseIdentifier:(NSString *)identifier;

//单图文消息的显示高度不是固定的，这里计算单图文消息的高度
+(float)getSinglePsMsgHeight:(ServiceMessage*)serviceMessage;

//配置单图文信息显示
+ (void)configureSinglePsMsgCell:(UITableViewCell *)cell andPSMsg:(ServiceMessage*)serviceMessage;


//多图文显示的cell
+ (UITableViewCell *)multiPsMsgTableViewCellWithReuseIdentifier:(NSString *)identifier;

//显示多图文消息
+ (void)configureMultiPsMsgCell:(UITableViewCell *)cell andPSMsgDtl:(ServiceMessageDetail*)detailMsg;

//section header view 
+ (UITableViewCell *)headerViewWithReuseIdentifier:(NSString *)identifier;

//配置 section header view
+ (void)configureHeaderView:(UITableViewCell *)cell andPSMsg:(ServiceMessage*)message;

//获取某个明细消息对应的图片
+(NSString *)getDtlImgName:(ServiceMessageDetail*)detail;

//获取某个明细消息的图片路径
+(NSString *)getDtlImgPath:(ServiceMessageDetail*)detail;

//增加一个方法 看收到的图片类型的公众号消息 是否存在 by shisp
//获取收到的公众号图片消息的名字
+ (NSString *)getPSPicMsgName:(ConvRecord *)convRecord;

//获取收到的公众号图片消息的保存路径
+ (NSString *)getPSPicMsgImagePath:(ConvRecord *)convRecord;

//获取图片的现实宽度
+ (float)getMaxContentWidth;

//获取单图文消息的高度
+ (float)getPSBigPicHeight;

//获取多图文消息 第一行消息的高度
+ (float)getPSMsgRow0Height;
@end
