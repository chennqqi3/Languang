//
//  Conversation.h
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Emp;
@class ConvRecord;

@class ServiceModel;
@class APPListModel;

@interface Conversation : NSObject
{
    /** 会话ID */
	NSString * _conv_id;
    
    /** 会话类型 */
	int _conv_type;
    
    /** 会话标题 */
	NSString *_conv_title;
    
    /** 备注 */
	NSString *_conv_remark;
    
    /** 新消息提醒标志 */
	int _recv_flag;
    
    /** 会话创建者的用户ID */
	int _create_emp_id;
    
    /** 会话创建时间 */
	NSString *_create_time;
    
	/** 最后一个消息 */
	ConvRecord *_last_record;
    
    /** 用户模型 */
    Emp *_emp;
    
    /** 是否已读 */
	int _unread;
    
    /** 消息时间 */
    NSString *msg_time;
    
    /** 最后一个消息的消息ID */
    int last_msg_id;
    
    /** 输入框中的内容（草稿） */
    NSString *lastInput_msg;
    
    /** 是否有未读的@消息 */
    BOOL is_tip_me;
}
/** 是否有未读的@消息 */
@property(assign)  BOOL is_tip_me;

/** 最后一条消息的ID */
@property(assign) int last_msg_id;

/** 消息时间 */
@property (retain) NSString * msg_time;

/** 会话ID */
@property (retain) NSString * conv_id;

/** 会话类型 */
@property(assign) int conv_type;

/** 会话标题 */
@property(retain) NSString *conv_title;

/** 备注 */
@property(retain) NSString *conv_remark;

/** 输入框中的内容（草稿）*/
@property(retain) NSString *lastInput_msg;

/** 新消息提醒标志 */
@property(assign) int recv_flag;

/** 会话创建者的用户ID */
@property(assign) int create_emp_id;

/** 会话创建时间 */
@property(retain) NSString * create_time;

/** 最后一个消息  */
@property(retain) ConvRecord *last_record;

/** 用户模型 */
@property(retain)  Emp *emp;

/** 是否已读 */
@property(assign) int unread;

/** 增加一个会话类型,是日历，还是服务号，还是机组群？ */
@property(nonatomic,assign)int recordType;

/** 如果是服务号会话类型，则保存如下对象，方便显示服务号头像 */
@property(retain)ServiceModel *serviceModel;

/** 轻应用模型 */
@property(retain)APPListModel *appModel;

/** 是否显示时间 */
@property(nonatomic,assign)BOOL displayTime;

/** 是否显示消息屏蔽图片 */
@property(nonatomic,assign)BOOL displayRcvMsgFlag;

/** 特殊字符的颜色 */
@property (nonatomic,retain) UIColor *specialColor;

/** 特殊字符 */
@property (nonatomic,retain) NSString *specialStr;

/** 群组总人数 */
@property (nonatomic,assign) int totalEmpCount;

/** 是否置顶 */
@property (nonatomic,assign) BOOL isSetTop;

/** 置顶时间 */
@property (nonatomic,assign) int setTopTime;

/** 群组类型 */
@property (nonatomic,assign) int groupType;

/** 如果是群组类型的会话，那么头像需要显示群组成员的小头像，所以要记录这个属性 */
@property (nonatomic,retain) NSMutableArray *groupLogoEmpArray;

/** 是否显示合成头像 */
@property (nonatomic,assign) BOOL displayMergeLogo;

/** 群组成员 */
@property (nonatomic,strong) NSArray *convEmps;

/**
 功能描述
 通过另外一个会话创建一个新的会话，查询会话记录时用到 add by shisp

 参数 _conv Conversation 会话实体
 返回值 Conversation 会话实体
 */
- (Conversation *)initWithConversation:(Conversation *)_conv;

/**
 功能描述
 根据会话类型不同，返回会话标题，单聊和群聊有区别
 
 返回值 convTitle 会话标题
 */
- (NSString *)getConvTitle;

/**
 功能描述
 根据会话类型不同，返回会话成员，单聊和群聊不同
 
 返回值 emp 成员数组
 */
- (NSArray *)getConvEmps;

/**
 功能描述
 万达需求，增加一个获取显示在群组头像的成员列表，按照empSort排序,最多四个
 
 返回值 empArray 成员数组
 */
- (void)getGroupLogoEmpArray;

/**
 功能描述
 增加根据最近一条的消息时间来排序，考虑顶置
 
 参数 anotherElement 会话实体
 返回值 枚举排序
 */
- (NSComparisonResult)compareByLastMsgTime:(Conversation *) anotherElement;

/**
 功能描述
 几张图片合成一张图片，用来生成群组头像
 
 参数 Conversation 会话实体
 返回值 无
 */
+ (void)mergedImageOfConv:(Conversation *)conv;

/**
 功能描述
 只需要根据最近一条的消息时间来排序 不考虑是否置顶
 
 参数 anotherElement 会话实体
 返回值 枚举排序
 */
- (NSComparisonResult)compareByLastMsgTimeOnly:(Conversation *) anotherElement;

@end
