//
//  MiLiaoUtilArc.h
//  eCloud
//
//  Created by Alex-L on 2017/5/16.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MILIAO_MSG_LIVE_TIME (30)
@class ConvRecord;
@interface MiLiaoUtilArc : NSObject

+ (MiLiaoUtilArc *)getUtil;

/** 初始化密聊消息数组 */
- (void)initMiLiaoMsgArray;

/**
 返回格式化的密聊消息

 @param msgType 消息类型
 @param msg 消息内容(语音、图片、视频对应的url)
 @param fileName 文件名字
 @param fileSize 文件大小
 @return 格式化的密聊消息
 */
- (NSString *)formatMiLiaoMsg:(int)msgType andMsg:(NSString *)msg andFileName:(NSString *)fileName andFileSize:(int)fileSize;

/** 格式化文本密聊消息 */
- (NSString *)formatMiLiaoMsg:(NSString *)inputText;

/** 根据convId（加了 “m_” 的） 得到 empId */
- (NSString *)getEmpIdWithMiLiaoConvId:(NSString *)convId;

/** 根据empId 得到 convId（加了 “m_” 的）*/
- (NSString *)getMiLiaoConvIdWithEmpId:(int)empId;

/** 判断是否密聊会话 */
- (BOOL)isMiLiaoConv:(NSString *)convId;

- (BOOL)LGisMiLiaoConv:(NSString *)convId;

/** 把密聊消息加到数组里 */
- (void)addToMiLiaoMsgArray:(ConvRecord *)_convRecord;

/** 从密聊信息数组里获取id相同的record */
- (ConvRecord *)getRecordFromMiLiaoMsgArray:(ConvRecord *)_convRecord;

    /** 从数组里删除密聊消息 */
- (void)removeFromMiLiaoMsgArray:(ConvRecord *)_convRecord;

/** 预处理密聊消息 */
- (void)setMiLiaoPropertyOfRecord:(ConvRecord *)_convRecord;
@end
