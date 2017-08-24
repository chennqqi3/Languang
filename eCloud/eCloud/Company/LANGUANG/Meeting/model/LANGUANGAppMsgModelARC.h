//
//  LANGUANGAppMsgModel.h
//  eCloud
//
//  Created by Ji on 17/6/9.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
{
    "type":"meeting",
    "confid":"1",
    "meetingMsgType":"1",
    "importance":"正式",
    "title":"测试",
    "host":"大白",
    "startTime":"2017-05-2710: 00: 00",
    "place":"测试地点",
    "duration":"30分",
    "summary":"测试"
}
 
 */
@interface LANGUANGAppMsgModelARC : NSObject

/** 视频会议： meeting，待办： backlog,新闻 ：news*/
@property (nonatomic,strong) NSString *type;

/** 会议id*/
@property (nonatomic,strong) NSString *idNum;

/** 1.会议审核通过通知，2.会议取消，4开会前通知，5开会结束会通知,6其他会议*/
@property (nonatomic,strong) NSString *meetingMsgType;

/** 重要性（正式，非正式）*/
@property (nonatomic,strong) NSString *importance;

/** 会议标题*/
@property (nonatomic,strong) NSString *title;

/** 主持人姓名*/
@property (nonatomic,strong) NSString *host;

/** 会议开始时间*/
@property (nonatomic,strong) NSString *startTime;

/** 会议结束时间*/
@property (nonatomic,strong) NSString *endTime;

/** 会议地点*/
@property (nonatomic,strong) NSString *place;

/** 会议持续时间*/
@property (nonatomic,strong) NSString *duration;

/** 会议摘要*/
@property (nonatomic,strong) NSString *summary;

/** 消息下发的时间  */
@property (nonatomic,strong) NSString *msgtime;

/** 会议通知时间  */
@property (nonatomic,strong) NSString *approach;

/** 是否待办通知 */
@property (nonatomic,assign) BOOL isDaiBanMsg;

+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic;

@end
