//
//  ConvRecord.h
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class ASIHTTPRequest;
@class ASIFormDataRequest;
@class RobotResponseModel;
@class LocationModel;
@class CloudFileModel;
@class ReplyOneMsgModelArc;
@class SystemMsgModelArc;
#ifdef _LANGUANG_FLAG_
@class RedPacketModelArc;
@class LANGUANGAppMsgModelARC;
@class LGNewsMdelARC;
#endif
#ifdef _TAIHE_FLAG_
@class TAIHEAppMsgModel;
#endif

@interface ConvRecord : NSObject
{
    /** 消息ID*/
	int _id;
    
    /** 会话ID */
	NSString * _conv_id;
    
    /** 用户ID */
	int _emp_id;
    
    /** 消息类型 */
	int _msg_type;
    
     /** 消息体 */
	NSString *_msg_body;
    
    /** 消息时间 */
	NSString *_msg_time;
    
    /** 是否已读 */
	int _read_flag;
    
    /** 废弃 */
    int is_set_redstate;
    
    /** 用户名 */
    NSString *_emp_name;
    
	/** 废弃 */
	int _msg_flag;
    
    /** 废弃 */
	int _send_flag;
    
	/** 文件名 */
	NSString *_file_name;
    
    /** 文件大小 */
	NSString *_file_size;
    
	/** 用户头像路径 */
	NSString *_emp_logo;
    
	/** 会话类型 */
	int _conv_type;
    
    /** 用户性别 */
    int _emp_sex;
    
	/** 废弃 */
	NSString *emp_code;
    
	/** 原始消息ID */
	long long _origin_msg_id;
    
	/** 增加一个属性，在聊天窗口，当用户下拉获取历史记录时用到，如果这个属性为真，表明是取到的历史记录里的最后一条 */
	bool _isLastHistoryRecord;
    
}
/** 是否设置了红点 */
@property (assign) int is_set_redstate;

/** 消息ID */
@property (assign) int msgId;

/** 会话ID */
@property (retain) NSString * conv_id;

/** 用户ID */
@property (assign) int emp_id;

/** 用户性别 */
@property (assign) int emp_sex;

/** 消息类型 */
@property(assign) int msg_type;

/** 消息体 */
@property(retain) NSString *msg_body;

/** 消息时间 */
@property(retain) NSString *msg_time;

/** 是否已读 */
@property(assign) int read_flag;

/** 用户中文名 */
@property(retain) NSString *emp_name;

/** 用户英文名 */
@property(retain) NSString *emp_name_eng;

/** 废弃 */
@property(assign) int msg_flag;

/** 发送的状态 */
@property(assign) int send_flag;

/** 文件名 */
@property(retain) NSString *file_name;

/** 文件大小 */
@property(retain) NSString *file_size;

/** 用户头像路径 */
@property(retain) NSString *emp_logo;

/** 会话类型 */
@property(assign) int conv_type;

/** 用户的编码 */
@property(retain) NSString *emp_code;

 /** 原始消息ID */
@property(assign)long long origin_msg_id;

/** 已经不用这个属性了 */
@property(assign)bool isLastHistoryRecord;

/** 消息内容所占的size */
@property(assign) CGSize msgSize;

/** 如果是文本消息，看是否包含超链接 */
@property(assign) bool isLinkText;

/** 如果是文本消息，看是不是分享扩展的超链接 */
@property(assign) bool isHyperlink;

/** 如果是文本消息，看是否包含了表情 */
@property(assign) bool isTextPic;

/** 判断视频消息是否存在 */
@property (assign) bool isVideoExist;

/** 判断录音消息是否在本地存在 */
@property(assign) bool isAudioExist;

/** 判断图片缩略图是否存在 */
@property(assign) bool isSmallPicExist;

/** 表明已经在下载 */
@property(assign) bool isDownLoading;

/** 判断原图是否存在*/
@property(assign) bool isBigPicExist;

/** 判断长消息是否在本地存在*/
@property(assign) bool isLongMsgExist;

/** 本条消息是否显示时间*/
@property(assign) bool isTimeDisplay;

/** 图片信息对应的Image*/
@property(retain) UIImage *imageDisplay;

/** 视频信息对应的avplayer*/
@property(retain) AVPlayer *avplay;

/** 显示的时间*/
@property(retain) NSString *msgTimeDisplay;

/** 尝试次数，update by shisp 该属性增加一个含义，就是在会话界面输入查询条件查询聊天记录时，找到的匹配的聊天记录的条数，条数为1，直接显示，大于1，则显示n条，点击可以展开二级查询结果*/
@property(assign) int tryCount;

/** 记录类型 普通类型或服务号相关*/
@property(assign) int recordType;

/** 判断文件是否存在*/
@property(assign) BOOL isFileExists;

/** 文件类型消息显示的文件名称和文件大小*/
@property(retain) NSString *fileNameAndSize;

/** 对应的下载请求*/
@property(retain) ASIHTTPRequest *downloadRequest;

/** 文件上传请求*/
@property(retain) ASIFormDataRequest *uploadRequest;

/** 一呼百应消息的显示内容*/
@property(retain) NSString *receiptTips;

/** 是否一呼百应消息*/
@property(assign,readonly) BOOL isReceiptMsg;

/** 是否是独立的回执消息*/
@property (assign,readonly) BOOL isHuizhiMsg;

/** 是否图片消息*/
@property(assign,readonly) BOOL isPicMsg;

/** 是否视频消息*/
@property(assign,readonly) BOOL isVideoMsg;

/** 是否文本消息*/
@property(assign,readonly) BOOL isTextMsg;

/** 是否录音消息*/
@property(assign,readonly) BOOL isRecordMsg;

/** 是否文件消息*/
@property(assign,readonly) BOOL isFileMsg;

/** 是否长消息*/
@property(assign,readonly) BOOL isLongMsg;

/** 是否图文消息*/
@property(assign,readonly) BOOL isImgtxtMsg;

/** 是否百科消息*/
@property(assign,readonly) BOOL isWikiMsg;

/** 消息状态*/
@property(assign)int receiptMsgFlag;

/** 是否发出了已读通知*/
@property(assign)int readNoticeFlag;

/** 一呼万应总人数，回复人数显示*/
@property(assign) int mass_total_emp_count;

/** 废弃*/
@property(assign) int mass_reply_emp_count;

/** 用户的状态*/
@property(assign) int empStatus;

/** 用户的登录类型*/
@property(assign) int empLoginType;

/** 文件下载标识*/
@property(assign) int download_flag;

/** 文件助手编辑状态下 文件是否被选中状态*/
@property(assign) BOOL isChosen;

/** 会话标题*/
@property(retain) NSString *conv_title;

/** 小万model*/
@property (nonatomic,retain) RobotResponseModel *robotModel;

/** 图片所在的indexpath*/
@property (nonatomic,retain) NSIndexPath *imageIndexPath;

/** 本地保存的真正的源消息id*/
@property (nonatomic,retain) NSString *localSrcMsgId;

/** 真正的消息类型 小万的消息 解析后的类型 */
@property (nonatomic,assign) int realMsgType;

/** 位置模型*/
@property (nonatomic,retain) LocationModel *locationModel;

#ifdef _TAIHE_FLAG_
/** 泰禾第三方推送模型*/
@property (nonatomic,retain) TAIHEAppMsgModel *appMsgModel;
#endif

/** 云文件模型*/
@property (nonatomic,retain) CloudFileModel *cloudFileModel;

#ifdef _LANGUANG_FLAG_
/** 红包模型*/
@property (nonatomic,retain) RedPacketModelArc *redPacketModel;

/** 第三方推送模型*/
@property (nonatomic,retain) LANGUANGAppMsgModelARC *meetingMsgModel;

/** 分享新闻模型*/
@property (nonatomic,retain) LGNewsMdelARC *newsModel;

#endif
/** 是否在编辑状态*/
@property (nonatomic,assign) BOOL isEdit;

/** 是否被选中*/
@property (nonatomic,assign) BOOL isSelect;

/** 分析文本消息，把文字和表情分开保存在一个数组里*/
@property (nonatomic,retain) NSArray *textMsgArray;

/** 是不是机器人的回复的图文消息*/
@property (nonatomic,assign) BOOL isRobotImgTxtMsg;

/** 是否机器人回复的文件类型的消息，一段视频，一段音频，一个附件*/
@property (nonatomic,assign) BOOL isRobotFileMsg;

/** 是否机器人图片消息*/
@property (nonatomic,assign) BOOL isRobotPicMsg;

/** 定向回复的消息模型 */

@property (nonatomic,assign) ReplyOneMsgModelArc *replyOneMsgModel;

#ifdef _XINHUA_FLAG_
/** 系统推送消息 */
@property (nonatomic,assign) SystemMsgModelArc *systemMsgModel;
#endif

/** 当前消息是否密聊消息 */
@property (nonatomic,assign) BOOL isMiLiaoMsg;

/** 如果是密聊消息，那么还能存在的时间 */
@property (nonatomic,assign) int miLiaoMsgLeftTime;

/** 回执消息是否已读 */
@property (nonatomic,assign) BOOL isHuiZhiMsgRead;

/** 密聊消息是否已经展开 */
@property (nonatomic,assign) BOOL isMiLiaoMsgOpen;

/** 视频消息的长度 */
@property (nonatomic,assign) int videoSeconds;

/**
 功能描述
 没发现有啥用
 
 参数 toString 字符串
 返回值 str 拼接了消息ID，会话ID，原始ID，消息实体，文件名，文件大小。
 */
-(NSString*)toString;


@end
