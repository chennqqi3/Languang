//
//  MessageView.h
//  eCloud
//
//  Created by robert on 12-10-31.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eCloudDefine.h"
#import "talkSessionViewController.h"
#import "TextMessageView.h"
//头像的尺寸
#define KFacialSizeWidth  24
#define KFacialSizeHeight 24
//add by shisp 一行文本消息的高度
#define single_line_height 24

#define spinnerTag 110//等待View
#define failTag 111 //失败按钮
#define timeAndStatusTag 112 //发送时间和发送状态View
#define msgStatusTag 113//发送状态View
#define bubbleTag 114 //气泡View
#define headImageTag 115 //头像view
#define empIdTag 116 //保存empId的label，点击头像查看用户资料时使用
#define isReadedTag 117 
#define statusViewTag 118
#define tipMsgIDTag 119


//	左边距和右边距
#define LEFT_OFFSET 0
#define RIGHT_OFFSET 0
//上边距和下边距
#define TOP_OFFSET 0
#define BOTTOM_OFFSET 0

#ifdef _LANGUANG_FLAG_
//	最大宽度
#define MAX_WIDTH (SCREEN_WIDTH - 144)
//最小宽度
#define MIN_WIDTH 31

#else
//	最大宽度
#define MAX_WIDTH (SCREEN_WIDTH - 111)
//最小宽度
#define MIN_WIDTH 70

#endif
//	每一行的高度
#define PER_HEIGHT 30

//表情格式定义
#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

//图片的最小高度和最小宽度
#define MIN_PIC_WIDTH 55 //MIN_WIDTH - 25
#define MIN_PIC_HEIGHT 40

#import "ConvRecord.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
@interface MessageView : NSObject
{
//	0表示只取一部分，用于联系人页面的最后一条会话消息
	int viewFlag;
//	聊天信息，最大宽度是280，显示最后一条消息时，最大宽度是240
	int max_width;
	
//	醒目显示的字符串
	NSString *_searchStr;
}

/** 是不是最后一条会话记录 */
@property(assign) int viewFlag;

/** 最大的宽度 */
@property(assign) int max_width;

/** 搜索的关键字 */
@property(retain) NSString* searchStr;

/** 获取最后一条会话信息 */
+(MessageView*)getLastMessageView;

/** 生成最后一条会话记录 */
+(MessageView*)getMessageView;


/**
 生成会话最后一条消息对应的view，message为最后一条消息，是图文混合

 @param text 文字内容
 @param fromSelf 没用到
 @return 消息对应的view
 */
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf;

/** 把图文混合的消息分成文本和图片的数组 */
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array;

/** 画出图文混合的会话记录 */
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself;


/**
 获取关键字的范围

 @param origin 所有文字
 @return 关键字的范围
 */
-(NSArray *)getColorArray:(NSString*)origin;

/** 把聊天内容中的表情使用"[表情]"来替换 */
-(NSString*)replaceFaceStrWithText:(NSString*)message;

/** 生成一条格式化的图文混合的会话记录 */
- (UIView *)bubbleViewRecord:(NSString *)text from:(ConvRecord *)recordObject;

/** 拉伸图片 */
- (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)_capInsets andImage:(UIImage *)image;

/** 获取圆角的用户头像 */
-(UIImage *)getEmpLogo:(ConvRecord*)recordObject;

/** 聊天界面显示日期 */
-(UIView *)getDateView:(NSString*)dateStr;

/** 群组变化通知View */
-(UIView *)getGroupInfoView:(NSString*)msgBody;

/** 获取聊天展示界面 其中returnView，可以是文字和表情组成的UIView，也可以是一个图片View，也可以是一个录音View */
-(UIView*)getChatView:(ConvRecord*)recordObject andBody:(UIView *)returnView;

/** 取得图片在聊天界面中显示的尺寸 */
+(CGSize)getImageDisplaySize:(UIImage *)img;

/** 计算文本消息的size */
-(CGSize)getTextMessageViewSize:(NSArray*)data andMaxWidth:(float)maxWidth;

@end
