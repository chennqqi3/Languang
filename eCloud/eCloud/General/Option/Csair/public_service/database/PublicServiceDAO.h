//
//  PublicServiceDAO.h
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ConvDAO.h"

@class ServiceModel;
@class ServiceMessage;
@class ServiceMessageDetail;

//add by shisp
typedef enum
{
    service_type_in_ps = 0,//在服务号里面展示的服务号类型；
    service_type_out_ps = 1,//在服务号外面展示的服务号类型；
    service_type_all = 2 //所有的服务号类型
}serviceTypeDef;

@class ServiceMenuModel;
@interface PublicServiceDAO : eCloud

+(id)getDatabase;

//保存服务号
-(bool)savePublicService:(NSArray *)info;

//修改服务号

//查询一个服务号
-(ServiceModel*)getServiceByServiceId:(int)serviceId;

//查询服务号个数
-(int)getServiceCount;

//查询服务号列表
-(NSArray*)getAllService:(int)serviceType;

//设置服务号的flag

//保存服务号的消息
-(bool)saveServiceMessage:(ServiceMessage*)serviceMessage;

//查询服务号的消息的条数
-(int)getServiceMsgCountByServiceId:(int)serviceId;


//查询服务号的消息
-(NSArray*)getServiceMessageByServiceId:(int)serviceId andLimit:(int)_limit andOffset:(int)_offset;

//删除服务号的消息

//查询是否有公众服务号推送的消息，如果有那么返回YES，这样就可以在会话列表的第一项置顶显示服务号的消息
-(BOOL)hasPSMsg;

//如果有服务号推送的消息，那么取出最近一条消息，包括时间，包括标题，如果是新闻类型消息，那么就显示第一条详细消息的title
-(ServiceMessage*)getLastPSMsg:(int)serviceId;

//查询所有未读的服务号消息，显示在会话列表的服务号的未读消息数
-(int)getUnreadMsgCountOfPS:(int)serviceId;


//查询是否有机组群，如果有返回YES，这样就可以在会话列表显示机组群
-(BOOL)hasFLTGroup;

//查询机组群中未读消息数，然后显示在会话列表机组群的未读消息数
-(int)getUnreadMsgCountOfFLT;

//查询机组群中最近的一条消息
-(ConvRecord*)getLastConvRecordOfFLT;

//查询最近50个机组群，可以参照查询最近的50个会话
-(NSArray*)getRecentFLTGroup;

//查询会话时，要排除掉机组群，机组群需要放在

//查询所有的服务号，如果有推送的消息，那么就显示最近的消息和消息时间，还要显示本服务号的未读消息数
-(NSArray*)getAllPSMsgList;

//把某一个服务号的所有的未读消息修改为已读
-(void)updateReadFlagOfPSMsg:(int)serviceId;

//保存某服务号未发送的消息
-(void)saveLastInputMsgOfService:(int)serviceId andLastInputMsg:(NSString*)message;

//是否还有显示最后一条消息？还是未读消息呢？

//把普通的推送消息ServiceMessage对象转化为ConvRecord对象，便于显示
-(void)convertServiceMessage:(ServiceMessage*)message toConvRecord:(ConvRecord*)_convRecord;

//根据serviceMsgid获取对应的消息
-(ServiceMessage*)getMessageByServiceMsgId:(int)serviceMsgId;

//设置serviceMsgId对应的消息为已读
-(void)updateReadFlagByServiceMsgId:(int)serviceMsgId;

- (void)updateSendFlagOfServiceMessage:(ServiceMessage*)serviceMessage;//更新公众号消息发送状态


//把所有的服务号的消息设置为已读
-(void)setAllPSMsgToRead;

//删除一条推送消息
-(void)deleteServiceMessage:(ServiceMessage*)serviceMessage;
//获取南航热点id
-(int)getServiceIdByName:(NSString*)name;

#pragma mark 当添加一条聊天记录时，如果发现是机组群的消息，那么需要把这条消息保存为会话列表中机组群的最后一条消息
- (void)processFltGroupMsg:(NSDictionary *)dic andId:(int)_id;

#pragma mark 当获取机组群的时候，查看最早的机组群，看是否已经过了7天的有效期，如果已经过了，那么删除这条会话，然后再查询下一条，如果没有过，那么就退出
- (void)deleteNotValidFltGroup;


//公众平台自定义菜单
-(bool)savePSMenuListInfo:(NSArray *)info;//保存公众平台菜单信息
-(NSMutableArray *)getAllMenuList;//获取所有公众号菜单
-(ServiceMenuModel*)getPSMenuListByPlatformid:(int)platformid;//根据platformid获取菜单信息
-(void)deletePSMenuListByByPlatformid:(int)platformid;////删除公众号菜单

#pragma mark  根据服务号id，查询公众号收到的图片记录，按照时间排序，最近的要排在前面
-(NSArray *)getPicConvRecordBy:(int)serviceId;

#pragma mark 删除某个公众号的所有消息
- (void)removeAllRecordsOfService:(int)serviceId;

@end
