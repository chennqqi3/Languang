//
//  talkSessionUtil.h
//  eCloud
//
//  Created by Richard on 13-10-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOSSystemDefine.h"
#import "UserInterfaceUtil.h"
#import "TalkSessionDefine.h"

@class ConvRecord;

@interface talkSessionUtil : NSObject

@property (nonatomic,assign) int custom_font_size;

/** deprecated */
+ (UITableViewCell *)tableViewCellWithReuseIdentifier:(NSString *)identifier;

#pragma mark --计算消息的size--

/**
 根据消息类型不同，计算消息所占的高度

 @param _convRecord 消息模型
 @return 消息将要占的高度
 */
+(float)getMsgBodyHeight:(ConvRecord*)_convRecord;

/**
 根据消息类型不同，按照不同的样式显示消息

 @param cell 消息所在的cell
 @param _convRecord 消息模型
 */
+ (void)configureCell:(UITableViewCell *)cell andConvRecord:(ConvRecord*)_convRecord;


/**
 消息预处理，对于文本消息，要看下是普通的文本，还是带表情的，还是带超链接的，因为要使用不同类型的cell来显示，对于图片，要查看图片缩略图、图片原图是否存在，因为显示时，如果缩略图不存在，那么要自动下载缩略图......

 @param _convRecord 消息模型
 */
+(void)setPropertyOfConvRecord:(ConvRecord*)_convRecord;

#pragma mark

/**
 检查图片是否需要裁减，如果需要则返回裁减后的尺寸

 @param image 下载或者上传的图片
 @return 返回裁剪的尺寸
 */
+(CGSize)getImageSizeAfterCrop:(UIImage*)image;

/**
 获取上传图片裁剪尺寸

 @param image 图片
 @return 上传图片时对图片裁剪的尺寸
 */
+(CGSize)getImageSizeAfterCropForUpload:(UIImage*)image;

/** 木棉童飞图片裁剪尺寸 */
+(CGSize)getImageSizeAfterCropForKapod:(UIImage*)image;

/** 隐藏进度条  */
+(void)hideProgressView:(UIProgressView*)progressView;

/** 显示进度条 */
+(void)displayProgressView:(UIProgressView*)progressView;

/** 获取文件类型消息对应的文件名字 */
+(NSString*)getFileName:(ConvRecord*)_convRecord;

#pragma mark 下载完文件后，如果是txt文件那么需要进行转码
/** 下载完文件后，如果是txt文件那么需要进行转码 */
+(void)transferFile:(ConvRecord*)_convRecord;

#pragma mark 发送已读通知，如果是回执消息，如果还没有发出已读通知，那么就发出已读通知
/** 发送已读通知，如果是回执消息，如果还没有发出已读通知，那么就发出已读通知 */
+(void)sendReadNotice:(ConvRecord*)convRecord;

#pragma mark --文本消息的size--
/** 计算文本消息的size */
+(void)getTextMsgSize:(ConvRecord*)_convRecord;

#pragma mark --显示文本消息--
+(void)configureTextMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

#pragma mark --图文的size--
+(void)getImgtxtMsgSize:(ConvRecord*)_convRecord;

#pragma mark --显示图文消息--
+(void)configureImgtxtMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

#pragma mark --百科的size--
+(void)getWikiMsgSize:(ConvRecord*)_convRecord;

#pragma mark --显示百科消息--
+(void)configureWikiMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;


#pragma mark --群组通知消息--
+(void)configureGroupInfo:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

#pragma mark --groupinfo的size--
+(void)getGroupInfoSize:(ConvRecord*)_convRecord;


#pragma mark --显示消息时间--
+(void)configureTime:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;


#pragma mark --图片消息的size--
+(void)getPicMsgSize:(ConvRecord*)_convRecord;

#pragma mark --录音消息的size--
+(void)getAudioMsgSize:(ConvRecord*)_convRecord;

#pragma mark --长消息的size--
+(void)getLongMsgSize:(ConvRecord*)_convRecord;

#pragma mark --显示录音消息--
+(void)configureAudioMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

#pragma mark --显示长消息消息--
+(void)configureLongMsg:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

/** 获取音频路径 */
+(NSString*)getAudioPath:(ConvRecord*)_convRecord;

/** 获取图片消息大图的路径 */
+(NSString*)getBigPicPath:(ConvRecord*)_convRecord;

/** 获取长消息对应文本文件的路径 */
+(NSString*)getLongMsgPath:(ConvRecord*)_convRecord;

/** 根据内容计算textview的高度 */
+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;

#pragma mark - 设置下载提示
/** 显示下载或者上传的进度和提示 */
+(void)configureFileDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

/**
 计算textMsg的显示size
 如果文本消息里有很多空格，使用现有的方式计算文本消息的size不正确，要使用新的方式 不过新的方式也没有用处

 @param textMsg 文本消息
 @param textFont 显示字体
 @param textMaxWidth 最大宽度
 @return textMsg的显示size
 */
+ (CGSize)getSizeOfTextMsg:(NSString *)textMsg withFont:(UIFont*)textFont withMaxWidth:(float)textMaxWidth;

/** 手动发送回执消息已读 */
+(void)sendReadNoticeByHand:(ConvRecord*)convRecord;

/** 修改群组名称的按钮背景颜色 */
+ (UIColor *)getBgColorOfModifyGroupNameButton;

/** 回执模式的背景颜色 */
+ (UIColor *)getBgColorOfReceiptModelColor;

/** 回执模式的高亮背景颜色 */
+ (UIColor *)getHLBgColorOfReceiptModelColor;

/** 回执模式的字体颜色 未发送已读时的颜色 */
+ (UIColor *)getReceiptTipsColorOfActive;

/** 回执模式的字体颜色 已发送已读时的颜色 */
+ (UIColor *)getReceiptTipsColorOfInActive;

/** 获取视频缩略图 */
+ (UIImage *)getVideoPreViewImage:(NSURL *)videoPath;

/** 获取视频时长 */
+ (CGFloat) getVideoDuration:(NSURL*) URL;

/** 删除视频转码后的mp4文件 */
+ (void)delFileFromPath:(NSString *)filePath;

/** 视频长度的显示格式 */
+ (NSString *)lessSecondToDay:(NSInteger)seconds;

/** 预处理 文本消息类型（目前处理针对位置和云文件） */
+ (void)preProcessTextMsg:(ConvRecord *)_convRecord;

/** 预处理 第三方推送消息 目前泰禾使用了此方法*/
+ (void)preProcessTextAppMsg:(ConvRecord *)_convRecord;

/** 预处理文本消息，查看是否小万消息 ，如果是先解析一下 */
+ (void)preProcessRobotMsg:(ConvRecord *)_convRecord;

/** 预处理 红包消息*/
+ (void)preProcessredPacketMsg:(ConvRecord *)_convRecord;

/** 预处理蓝光会议 */
+ (void)preProcessMettingAppMsg:(ConvRecord *)_convRecord;

/** 获取推送消息的视频文件名称 */
+(NSString*)getNewsVideoName:(ConvRecord*)_convRecord;


//设置文本消息字体的颜色
+ (void)setTextMsgColor:(UILabel *)textLabel andConvRecord:(ConvRecord *)_convRecord;

#pragma mark --消息时间所占height--
+(float)getTimeHeight:(ConvRecord*)_convRecord;

@end
