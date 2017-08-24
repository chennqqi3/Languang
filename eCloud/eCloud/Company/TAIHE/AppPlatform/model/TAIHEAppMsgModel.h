//
//  TAIHEAppMsgModel.h
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAIHEAppMsgModel : NSObject

//{"msgtype":1,"title":"待办采购服务器申请单","content":"采购服务器的厂商列表如下:IBM、联想","url":"https://www.baidu.com/","sender":"EmailMessage","receiver":"suzhemin","sendtime":1487214000}

//{
//    "apptype":	2,
//    "subtype":	"待办",
//    "title":	"请审批管理员提交的流程：c's",
//    "content":	"请审批管理员提交的流程：c's",
//    "url":	"https://oa.tahoecn.com/ekp/km/review/km_review_main/kmReviewMain.do?method=view&fdId=15aeb99fba8b48801f8a110495bacf90",
//    "pcurl":	"https://oa.tahoecn.com/ekp/km/review/km_review_main/kmReviewMain.do?method=view&fdId=15aeb99fba8b48801f8a110495bacf90",
//    "sender":	"流程管理",
//    "sendtime":	1490011440,
//    "TerControl ":	"2"
//}

//邮箱消息
//{
//    "apptype":	1,
//    "subtype":	"邮件",
//    "title":	"待办采购服务器申请单",
//    "content":	"采购服务器的厂商列表如下: IBM、联想",
//    "url":	"https://www.baidu.com/",
//    "sender":	"Todo",
//    "sendtime":	1487214000
//}

//会议消息
//{"msgtype":1,"confid":"91100","title":"龙建福的会议 03-21", "starttime":1490064300,"endtime":1490067900,"invitetype":0,"invite":4422,"invitename":"龙建福","conftype":1, "location":"的法国队风格化地方个"}


/** 推送的应用标识  邮箱：1  OA服务：2  	考勤：3   哪个第三方轻应用*/
@property (nonatomic,assign) int apptype;

/** 推送的应用标识  待办 待阅   			目前只针对OA*/
@property (nonatomic,copy) NSString *subtype;

/** 标题  */
@property (nonatomic,copy) NSString *title;

/** 内容  */
@property (nonatomic,copy) NSString *content;

/** 详情链接  */
@property (nonatomic,copy) NSString *url;

/** 发送人  */
@property (nonatomic,copy) NSString *sender;

/** 接收人  */
@property (nonatomic,copy) NSString *receiver;

/** 发送时间  */
@property (nonatomic,assign) long long sendtime;

/** 消息下发的时间  */
@property (nonatomic,copy) NSString *msgtime;

/*会议的id confid*/
@property (nonatomic,copy) NSString *confid;

/*会议的开始时间 starttime*/
@property (nonatomic,assign) int starttime;

/*会议的地址 location*/
@property (nonatomic,copy) NSString *location;


+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic;

@end
