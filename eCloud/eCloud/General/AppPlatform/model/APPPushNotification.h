//
//  APPPushNotification.h
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

//-----应用推送消息-----//

#import <Foundation/Foundation.h>

@interface APPPushNotification : NSObject{
    
}
@property (assign) int msgId;     //消息id
@property(assign) int read_flag;                 //0.未读 1.已读

@property (nonatomic,retain) NSString *appid; //应用编号
@property(assign) int notinum;//相关通知数量
@property(assign) int pri; //优先级 范围：0-10 数字越大优先级越高
@property(nonatomic,retain) NSString *title;//通知标题
@property(nonatomic,retain) NSString *summary;//概要
@property(nonatomic,retain) NSString *pushurl;//推送消息URL
@property(nonatomic,assign) int notitime;//时间
@property(nonatomic,retain) NSString *src;//消息发送者

//显示的时间
@property(nonatomic,retain) NSString *notiTimeDisplay;
//增加一个属性，是否显示时间
@property(nonatomic,assign) BOOL needDisplayTime;

@end
