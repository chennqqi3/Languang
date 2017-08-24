// 新消息提醒使用的对象
//

#import <Foundation/Foundation.h>

@interface NewMsgNotice : NSObject

/*
//消息类型，是普通会话，还是服务号推送消息
@property(nonatomic,assign) int msgType;

//普通会话
@property(nonatomic,retain) NSString* msgId;
@property(nonatomic,retain) NSString *convId;

//服务号
@property(nonatomic,assign)int serviceId;
@property(nonatomic,assign)int serviceMsgId;

//第三方应用
@property(nonatomic,retain)NSString *appid;
@property(nonatomic,assign)int appMsgId;
 */

/** 消息类型，0是普通新消息，1是新的公众号消息，2是应用平台消息，3是一呼万应回复消息 */
@property(nonatomic,assign) int msgType;
/** 消息id */
@property(nonatomic,retain) NSString* msgId;
/** 会话id */
@property(nonatomic,retain) NSString *convId;
/** 服务id */
@property(nonatomic,assign)int serviceId;
/** 服务消息id */
@property(nonatomic,assign)int serviceMsgId;
/** 轻应用id */
@property(assign)NSString *appid;
/** 轻应用消息id */
@property(nonatomic,assign)int appMsgId;

@end
