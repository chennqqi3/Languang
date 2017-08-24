//
//  RedPacketModelArc.h
//  eCloud
//
//  Created by Ji on 17/5/10.
//  Copyright © 2017年 网信. All rights reserved.
//

/*
 
 1 =     {
 ID = 70361313963475328;
 "is_money_msg" = 1;
 "money_greeting" = "恭喜发财，大吉大利！";
 "money_receiver_id" = 18681590271;
 "money_sender" = 15889752470;
 "money_sender_id" = 15889752470;
 "money_sponsor_name" = "云账户红包";
 "money_type_special" = "";
 "special_money_receiver_id" = 18681590271;
 };
 
 */

#import <Foundation/Foundation.h>

@interface RedPacketModelArc : NSObject

/** 红包id */
@property (nonatomic,strong) NSString *readPacketId;


@property (nonatomic,strong) NSString *type;

/** 发送人 */
@property (nonatomic,strong) NSString *guestName;

/** 接收人id */
@property (nonatomic,strong) NSString *guestId;

/** 发送人id */
@property (nonatomic,strong) NSString *hostId;

/** 是否是红包消息 */
@property (nonatomic,assign) int is_money_msg;

/** 红包内容 */
@property (nonatomic,strong) NSString *greeting;

///** 接收人id */
//@property (nonatomic,assign) int money_receiver_id;
//
///** 发送人id */
//@property (nonatomic,assign) int money_sender_id;
//
///** 发送人 */
//@property (nonatomic,assign) int money_sender;

/** 赞助商名称 */
@property (nonatomic,strong) NSString *money_sponsor_name;

/** 未知 */
@property (nonatomic,strong) NSString *money_type_special;

@property (nonatomic,assign) int special_money_receiver_id;

+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic;

@end
