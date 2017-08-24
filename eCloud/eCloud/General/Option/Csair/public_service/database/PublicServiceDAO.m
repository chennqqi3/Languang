//
//  PublicServiceDAO.m
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PublicServiceDAO.h"
#import "eCloudNotification.h"
#import "LogUtil.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "Conversation.h"
#import "ConvRecord.h"
#import "PublicServiceDAOSql.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "PSMsgUtil.h"
#import "ConvNotification.h"
#import "ServiceMenuModel.h"

#import "NotificationUtil.h"
#import "Emp.h"

#import "ServiceModel.h"
#import "ServiceMessage.h"
#import "ServiceMessageDetail.h"

//机组群的有效期
#define flt_group_valid_interval (7 * 24 * 60 * 60)

static PublicServiceDAO *publicServiceDAO;

@implementation PublicServiceDAO
+(id)getDatabase
{
	if(publicServiceDAO == nil)
	{
		publicServiceDAO = [[PublicServiceDAO alloc]init];
	}
	return publicServiceDAO;
}

//保存服务号
-(bool)savePublicService:(NSArray *)info
{
    for (ServiceModel *serviceModel in info)
    {
        [self addOneService:serviceModel];
    }
    return true;
}

-(bool)addOneService:(ServiceModel*)serviceModel
{
	bool success = false;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(service_id,service_code,service_name,service_pinyin,service_desc,service_url,service_icon,follow_flag,rcv_msg_flag,service_type,service_status) values(?,?,?,?,?,?,?,?,?,?,?)",table_public_service];
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		pthread_mutex_lock(&add_mutex);
		sqlite3_bind_int(stmt, 1, serviceModel.serviceId);
		sqlite3_bind_text(stmt, 2, [serviceModel.serviceCode UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 3, [serviceModel.serviceName UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 4, [serviceModel.servicePinyin UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 5, [serviceModel.serviceDesc UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 6, [serviceModel.serviceUrl UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 7, [serviceModel.serviceIcon UTF8String], -1, NULL);
		sqlite3_bind_int(stmt, 8, serviceModel.followFlag);
		sqlite3_bind_int(stmt, 9, serviceModel.rcvMsgFlag);
		sqlite3_bind_int(stmt, 10, serviceModel.serviceType);
		sqlite3_bind_int(stmt, 11, serviceModel.serviceStatus);
		//	执行
		state = sqlite3_step(stmt);
		
		pthread_mutex_unlock(&add_mutex);
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
        
        
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		
		//		如果是需要显示在会话列表里的服务号，还要往会话表里增加一条记录
		if(serviceModel.serviceType == 1)
		{
            [self createConversation:serviceModel];
		}
	}
	return success;
}

//需要显示在会话列表里的服务号，需要在会话表里添加对应的记录
- (void)createConversation:(ServiceModel *)serviceModel
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    NSString *convId = [StringUtil getStringValue:serviceModel.serviceId];
    
    if([db searchConversationBy:convId] == nil)
    {
        NSString *convType = [StringUtil getStringValue:serviceConvType];
        //				默认屏蔽，收到该服务号的消息后，再设置为打开
        NSString *recvFlag = [StringUtil getStringValue:open_msg];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             convId,@"conv_id",
                             convType,@"conv_type",
                             serviceModel.serviceName,@"conv_title",
                             recvFlag,@"recv_flag", nil];
        
        [db addConversation:[NSArray arrayWithObject:dic]];
    }
}

//获取南航热点id
-(int)getServiceIdByName:(NSString*)name
{
    int service_id=-1;
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select service_id from %@ where service_name like '%%%@%%'",table_public_service,name];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
        if (result&&[result count]>0) {
            service_id = [[[result objectAtIndex:0]valueForKey:@"service_id"]intValue];
        }
		
	}
	return service_id;
    
}

//查询一个服务号
-(ServiceModel*)getServiceByServiceId:(int)serviceId
{
	ServiceModel *serviceModel = [[ServiceModel alloc]init];
	serviceModel.serviceId = -1;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_id = %d",table_public_service,serviceId];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if(result.count == 1)
		{
            //			[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[[result objectAtIndex:0]description]]];
			
			[self saveResult:[result objectAtIndex:0] toServiceModel:serviceModel];
		}
	}
	
	return [serviceModel autorelease];
}

//查询服务号个数
-(int)getServiceCount
{
	int count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where service_type = 0",table_public_service];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
	}
	return count;
}

//查询服务号列表
-(NSArray*)getAllService:(int)serviceType
{
	NSMutableArray *services = [NSMutableArray array];
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = nil;
    if (serviceType == service_type_all) {
        sql = [NSString stringWithFormat:@"select * from %@ where service_status = 0",table_public_service];
    }
    else if (serviceType == service_type_in_ps)
    {
        sql = [NSString stringWithFormat:@"select * from %@ where service_type = %d and service_status = 0",table_public_service,service_type_in_ps];
    }
    
    if (sql) {
        NSMutableArray *result = [[NSMutableArray alloc]init];
        [self operateSql:sql Database:_handle toResult:result];
        for(NSDictionary *dic in result)
        {
            ServiceModel *serviceModel = [[ServiceModel alloc]init];
            [self saveResult:dic toServiceModel:serviceModel];
            [services addObject:serviceModel];
            [serviceModel release];
        }
        [result release];
        [pool release];
    }
    return services;
}
-(void)saveResult:(NSDictionary*)dic toServiceModel:(ServiceModel*)serviceModel
{
	serviceModel.serviceId = [[dic valueForKey:@"service_id"]intValue];
	serviceModel.serviceCode = [dic valueForKey:@"service_code"];
	serviceModel.serviceName = [dic valueForKey:@"service_name"];
	serviceModel.servicePinyin = [dic valueForKey:@"service_pinyin"];
	serviceModel.serviceDesc = [dic valueForKey:@"service_desc"];
	serviceModel.serviceIcon = [dic valueForKey:@"service_icon"];
	serviceModel.serviceUrl = [dic valueForKey:@"service_url"];
	serviceModel.followFlag = [[dic valueForKey:@"follow_flag"]intValue];
	serviceModel.rcvMsgFlag = [[dic valueForKey:@"rcv_msg_flag"]intValue];
	serviceModel.lastInputMsg = [dic valueForKey:@"last_input_msg"];
	serviceModel.serviceType = [[dic valueForKey:@"service_type"]intValue];
}

//保存服务号的消息
-(bool)saveServiceMessage:(ServiceMessage*)serviceMessage
{
    if (serviceMessage.msgType == ps_msg_type_news) {
        if (!serviceMessage.detail.count) {
            return false;
        }
    }
    conn *_conn = [conn getConn];
    if(serviceMessage.msgFlag == rcv_msg)
    {
        ServiceModel *serviceModel = [self getServiceByServiceId:serviceMessage.serviceId];
        if(serviceModel.serviceId == -1)
        {
            //			[_conn syncPublicService];
            return false;
        }
    }
    
    serviceMessage.msgId = [self getMaxMsgId] + 1;
    
    bool success = false;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(msg_id,service_id,msg_time,msg_body,msg_url,msg_link,msg_type,msg_flag,read_flag,send_flag,file_size,red_dot_flag) values(?,?,?,?,?,?,?,?,?,?,?,?)",table_public_service_message];
    
    sqlite3_stmt *stmt = nil;
    
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
    }
    else
    {
        //		保存主表
        pthread_mutex_lock(&add_mutex);
        sqlite3_bind_int(stmt, 1, serviceMessage.msgId);
        sqlite3_bind_int(stmt, 2, serviceMessage.serviceId);
        sqlite3_bind_int(stmt, 3, serviceMessage.msgTime);
        sqlite3_bind_text(stmt, 4, [serviceMessage.msgBody UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [serviceMessage.msgUrl UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [serviceMessage.msgLink UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 7, serviceMessage.msgType);
        sqlite3_bind_int(stmt, 8, serviceMessage.msgFlag);
        sqlite3_bind_int(stmt, 9, serviceMessage.readFlag);
        sqlite3_bind_int(stmt,10,serviceMessage.sendFlag);
        sqlite3_bind_int(stmt, 11, serviceMessage.fileSize);
        sqlite3_bind_int(stmt, 12, serviceMessage.redDotFlag);
        
        //	执行
        state = sqlite3_step(stmt);
        
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        
        //	执行结果
        if(state != SQLITE_DONE &&  state != SQLITE_OK)
        {
            //			执行错误
            NSLog(@"%s,exe state is %d",__FUNCTION__,state);
        }
        else
        {
            //			开始保存明细
            for(ServiceMessageDetail *serviceMessageDetail in serviceMessage.detail)
            {
                serviceMessageDetail.serviceMsgId = serviceMessage.msgId;
                [self saveDetailMessage:serviceMessageDetail];
            }
        }
    }
    
    //		如果该推送消息对应的服务号需要在会话列表显示，那么需要在会话表里进行相应的修改，对于显示在会话列表里的服务号，会话id就是服务号id，对于没有显示在会话列表里的服务号，会话id需要根据会话类型查询
    NSString *convId = [self getConvIdByServiceId:serviceMessage.serviceId];
    //
    //		ServiceModel *_serviceModel = [self getServiceByServiceId:serviceMessage.serviceId];
    //		if(_serviceModel.serviceType == 1)
    //		{
    //			convId = [StringUtil getStringValue:serviceMessage.serviceId];
    //            [self createConversation:_serviceModel];
    //		}
    //		else if(_serviceModel.serviceType == 0)
    //		{
    //            //			不再会话列表的显示的服务号
    //			sql = [NSString stringWithFormat:@"select conv_id from %@ where conv_type = %d",table_conversation,serviceNotInConvType];
    //			NSMutableArray *result = [NSMutableArray array];
    //			[self operateSql:sql Database:_handle toResult:result];
    //			if(result.count > 0)
    //			{
    //                //				修改最后一条消息
    //				convId = [[result objectAtIndex:0]valueForKey:@"conv_id"];
    //			}
    //			else
    //			{
    //                //				增加一个新的会话，显示不在会话列表显示的服务号消息入口，默认的convid为第一条收到的服务号的serviceid
    //				//				默认屏蔽，收到该服务号的消息后，再设置为打开
    //				NSString *recvFlag = [StringUtil getStringValue:open_msg];
    //				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
    //									 [StringUtil getStringValue:_serviceModel.serviceId],@"conv_id",
    //									 [StringUtil getStringValue:serviceNotInConvType],@"conv_type",
    //									 NSLocalizedString(@"public_service", @"服务号"),@"conv_title",
    //									 recvFlag,@"recv_flag",nil];
    //
    //				[[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
    //
    //				convId = [StringUtil getStringValue:_serviceModel.serviceId];
    //			}
    //		}
    
    if(convId)
    {
        NSString *msgBody = serviceMessage.msgBody;
        if(serviceMessage.detail.count > 0)
        {
            ServiceMessageDetail *dtlMsg = [serviceMessage.detail objectAtIndex:0];
            msgBody = dtlMsg.msgBody;
        }
        
        //记录last_msg_id,last_msg_body,last_msg_time ，默认是文本消息
        NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? , last_msg_type = %d,display_flag = 0 where conv_id = '%@' and (conv_type = %d  or conv_type = %d) "
                         ,table_conversation,type_text,convId,serviceConvType,serviceNotInConvType];
        //		编译
        pthread_mutex_lock(&add_mutex);
        int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
        pthread_mutex_unlock(&add_mutex);
        
        if(state != SQLITE_OK)
        {
            //			编译错误
            [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
            //			释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
        }
        else
        {
            //		绑定值
            pthread_mutex_lock(&add_mutex);
            
            sqlite3_bind_int(stmt, 1,serviceMessage.msgId);
            if (serviceMessage.msgType == ps_msg_type_pic) {
                sqlite3_bind_text(stmt, 2, [[StringUtil getLocalizableString:@"msg_type_pic"] UTF8String],-1,NULL);
            }else{
                sqlite3_bind_text(stmt, 2, [msgBody UTF8String],-1,NULL);
            }
            sqlite3_bind_text(stmt, 3, [[StringUtil getStringValue:serviceMessage.msgTime] UTF8String],-1,NULL);//last_msg_time
            //	执行
            state = sqlite3_step(stmt);
            
            pthread_mutex_unlock(&add_mutex);
            //	执行结果
            if(state != SQLITE_DONE &&  state != SQLITE_OK)
            {
                //			执行错误
                [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
            }
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            //
            conn *_conn = [conn getConn];
//            现在收完离线消息后，不再从数据库里重新读取了，所以这里不做判断了
//            if (_conn.isOfflineMsgFinish)
//            {
                [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil] andCmdType:add_new_conv_record];
//            }
        }
    }
    
    success = true;
    [pool release];
    return success;
}

-(int)getMaxMsgId
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select max(msg_id) as max_msg_id from %@",table_public_service_message];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int maxMsgId = [[[result objectAtIndex:0]valueForKey:@"max_msg_id"]intValue];
	[pool release];
	return maxMsgId;
}

-(int)getMaxMsgIdOfDetail
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select max(msg_id) as max_msg_id from %@",table_public_service_message_detail];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int maxMsgId = [[[result objectAtIndex:0]valueForKey:@"max_msg_id"]intValue];
	[pool release];
	return maxMsgId;
}

-(bool)saveDetailMessage:(ServiceMessageDetail *)serviceMessageDetail
{
	serviceMessageDetail.msgId = [self getMaxMsgIdOfDetail]+1;
	
	bool success = false;
	NSString *sql = [NSString stringWithFormat:@"insert into %@(msg_id,service_msg_id,msg_body,msg_url,msg_link) values(?,?,?,?,?)",table_public_service_message_detail];
	
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		//		保存detail表
		pthread_mutex_lock(&add_mutex);
		sqlite3_bind_int(stmt, 1, serviceMessageDetail.msgId);
		sqlite3_bind_int(stmt, 2, serviceMessageDetail.serviceMsgId);
		sqlite3_bind_text(stmt, 3, [serviceMessageDetail.msgBody UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 4, [serviceMessageDetail.msgUrl UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 5, [serviceMessageDetail.msgLink UTF8String], -1, NULL);
		
		//	执行
		state = sqlite3_step(stmt);
		
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
	}
	return success;
}


//查询服务号的消息
-(NSArray*)getServiceMessageByServiceId:(int)serviceId andLimit:(int)_limit andOffset:(int)_offset
{
	NSMutableArray *records = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //	查询主表
    //	NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_id = '%d' and msg_type = %d order by msg_time limit(%d) offset(%d)",table_public_service_message,serviceId,ps_msg_type_news, _limit,_offset];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_id = '%d' order by msg_time limit(%d) offset(%d)",table_public_service_message,serviceId, _limit,_offset];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
    
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		int msgType = [[dic valueForKey:@"msg_type"]intValue];
        if (msgType == ps_msg_type_news) {
            ServiceMessage *serviceMessage = [[ServiceMessage alloc]init];
            [self saveResult:dic toServiceMessage:serviceMessage];
            
            //		查询明细数据
            int msgType = serviceMessage.msgType;
            if(msgType == ps_msg_type_news)
            {
                //				详细消息中也保存serviceid，这样可以从service对应目录下获取资源文件
                NSArray *detail = [self getDetailMsgByMessage:serviceMessage];
                serviceMessage.detail = detail;
            }
            
            [records addObject:serviceMessage];
            [serviceMessage release];
        }
        else
        {
            ConvRecord *_convRecord = [[ConvRecord alloc]init];
            [self saveResult:dic toConvRecord:_convRecord];
            [records addObject:_convRecord];
            [_convRecord release];
        }
    }
	[pool release];
	
	return records;
    
}
//保存普通消息
-(void)saveResult:(NSDictionary*)dic toConvRecord:(ConvRecord*)_convRecord
{
	_convRecord.msgId = [[dic valueForKey:@"msg_id"]intValue];
	_convRecord.conv_id =  [StringUtil getStringValue:[[dic valueForKey:@"service_id"]intValue]];

    int msgType = [[dic valueForKey:@"msg_type"]intValue];
    if (msgType == ps_msg_type_text) {
        _convRecord.msg_type = type_text;
    }
    else if (msgType == ps_msg_type_pic)
    {
        _convRecord.msg_type = type_pic;
    }else if (msgType == ps_msg_type_record)
    {
        _convRecord.msg_type = type_record;
    }

//	_convRecord.msg_type = type_text;
	_convRecord.msg_body = [dic valueForKey:@"msg_body"];
	_convRecord.msg_flag = [[dic valueForKey:@"msg_flag"]intValue];
	_convRecord.msg_time = [NSString stringWithFormat:@"%@",[dic valueForKey:@"msg_time"]];
	_convRecord.msgTimeDisplay = [StringUtil getDisplayTime_day:_convRecord.msg_time];
	_convRecord.recordType = ps_conv_record_type;
    _convRecord.send_flag = [[dic objectForKey:@"send_flag"] integerValue];
    
    if (_convRecord.msg_flag == send_msg) {
        _convRecord.emp_id = [conn getConn].userId.intValue;
    }
}

//把普通的推送消息ServiceMessage对象转化为ConvRecord对象，便于显示
-(void)convertServiceMessage:(ServiceMessage*)message toConvRecord:(ConvRecord*)_convRecord
{
	_convRecord.msgId = message.msgId;
	_convRecord.conv_id =  [StringUtil getStringValue:message.serviceId];
   
    
//    add by shisp 把公众号的消息类型转换为普通的消息类型
    int msgType = message.msgType;
    
    if (msgType == ps_msg_type_text) {
        _convRecord.msg_type = type_text;
    }
    else if (msgType == ps_msg_type_record)
    {
        _convRecord.msg_type = type_record;
        _convRecord.file_size = [StringUtil getStringValue:message.fileSize];
        _convRecord.file_name = message.msgUrl;
    }
    else if (msgType == ps_msg_type_pic)
    {
        _convRecord.msg_type = type_pic;
        if (_convRecord.msg_flag == send_msg) {
            _convRecord.file_size = [StringUtil getStringValue:message.fileSize];
//            如果是图片类型的消息 msgUrl里保存了 图片的URL，如果本地还没有下载下来图片，那么就使用这个url去下载图片，也可以直接放到msgbody里吧
            _convRecord.file_name = message.msgUrl;
        }
    }
    
	_convRecord.msg_body = message.msgBody;
	_convRecord.msg_flag = message.msgFlag;
	_convRecord.msg_time = [StringUtil getStringValue:message.msgTime];
	_convRecord.msgTimeDisplay = [StringUtil getDisplayTime_day:_convRecord.msg_time];
	_convRecord.recordType = ps_conv_record_type;
    _convRecord.send_flag = message.sendFlag;
    
    if (_convRecord.msg_flag == send_msg) {
        _convRecord.emp_id = [conn getConn].userId.intValue;
    }
}

//保存新闻消息
-(void)saveResult:(NSDictionary*)dic toServiceMessage:(ServiceMessage*)serviceMessage
{
	serviceMessage.msgId = [[dic valueForKey:@"msg_id"]intValue];
	serviceMessage.serviceId = [[dic valueForKey:@"service_id"]intValue];
	serviceMessage.msgTime = [[dic valueForKey:@"msg_time"]intValue];
	serviceMessage.msgTimeDisplay = [StringUtil getDisplayTime_day:[dic valueForKey:@"msg_time"]];
	serviceMessage.singlePsMsgDate = [StringUtil getSinglePsMsgDate:[[dic valueForKey:@"msg_time"]intValue]];
	serviceMessage.msgBody = [dic valueForKey:@"msg_body"];
	serviceMessage.msgUrl = [dic valueForKey:@"msg_url"];
	serviceMessage.msgLink = [dic valueForKey:@"msg_link"];
	serviceMessage.msgFlag = [[dic valueForKey:@"msg_flag"]intValue];
	serviceMessage.msgType = [[dic valueForKey:@"msg_type"]intValue];
	serviceMessage.readFlag = [[dic valueForKey:@"read_flag"]intValue];
    serviceMessage.sendFlag = [[dic objectForKey:@"send_flag"] integerValue];
}

//查询消息明细
-(NSArray*)getDetailMsgByMessage:(ServiceMessage*)message
{
	int serviceMsgId = message.msgId;
	NSMutableArray *detail = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_msg_id = %d",table_public_service_message_detail,serviceMsgId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	int row = 0;
	for(NSDictionary *dic in result)
	{
//        NSLog(@"%s %@",__FUNCTION__,[dic description]);
		ServiceMessageDetail *serviceMessageDetail = [[ServiceMessageDetail alloc]init];
		serviceMessageDetail.row = row;
		row++;
		serviceMessageDetail.serviceMsgId = serviceMsgId;
		serviceMessageDetail.serviceId = message.serviceId;
		[self saveResult:dic toServiceMessageDetail:serviceMessageDetail];
		[detail addObject:serviceMessageDetail];
		[serviceMessageDetail release];
	}
	[pool release];
	return detail;
}

-(void)saveResult:(NSDictionary*)dic toServiceMessageDetail:(ServiceMessageDetail*)serviceMessageDetail
{
	serviceMessageDetail.msgId = [[dic valueForKey:@"msg_id"]intValue];
	serviceMessageDetail.msgBody = [dic valueForKey:@"msg_body"];
	serviceMessageDetail.msgLink = [dic valueForKey:@"msg_link"];
	serviceMessageDetail.msgUrl = [dic valueForKey:@"msg_url"];
}

//查询服务号的消息的条数
-(int)getServiceMsgCountByServiceId:(int)serviceId
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where service_id = %d",table_public_service_message,serviceId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
	[pool release];
	return count;
}

//查询是否有公众服务号推送的消息，如果有那么返回YES，这样就可以在会话列表的第一项置顶显示服务号的消息
-(BOOL)hasPSMsg
{
	int _count = 0;
	@autoreleasepool {
        //		只查询显示在服务号里面的服务号的消息
        //		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@",table_public_service_message];
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a,%@ b where a.service_type = 0 and a.service_id = b.service_id",table_public_service,table_public_service_message];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
    
	if(_count > 0)
	{
		return YES;
	}
	return NO;
}

//如果有服务号推送的消息，那么取出最近一条消息，包括时间，包括标题，如果是新闻类型消息，那么就显示第一条详细消息的title
-(ServiceMessage*)getLastPSMsg:(int)serviceId
{
	ServiceMessage *message = [[ServiceMessage alloc]init];
	message.msgId = -1;
	
	@autoreleasepool {
		NSString *sql;
		if(serviceId == -1)
		{
			sql = [NSString stringWithFormat:@"select * from %@ order by msg_time desc limit 1",table_public_service_message];
            //			sql = [NSString stringWithFormat:@"select * from %@ where msg_type = %d order by msg_time desc limit 1",table_public_service_message,ps_msg_type_news];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select * from %@ where service_id = %d order by msg_time desc limit 1",table_public_service_message,serviceId];
		}
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			NSDictionary *dic = [result objectAtIndex:0];
			[self saveResult:dic toServiceMessage:message];
			
            //			[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[dic description]]];
			
			if(message.msgType == ps_msg_type_news)
			{
				sql = [NSString stringWithFormat:@"select * from %@ where service_msg_id = %d order by msg_id limit 1",table_public_service_message_detail,message.msgId];
				
				result = [NSMutableArray array];
				[self operateSql:sql Database:_handle toResult:result];
				if([result count] > 0)
				{
					ServiceMessageDetail *detail = [[ServiceMessageDetail alloc]init];
					dic = [result objectAtIndex:0];
					
                    //					[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[dic description]]];
                    
					[self saveResult:dic toServiceMessageDetail:detail];
					message.detail = [NSArray arrayWithObject:detail];
					[detail release];
				}
			}
		}
	}
	return [message autorelease];
}

//查询所有未读的服务号消息，显示在会话列表的服务号的未读消息数
-(int)getUnreadMsgCountOfPS:(int)serviceId
{
	int _count = 0;
	@autoreleasepool {
		NSString *sql;
		if(serviceId == -1)
		{
            //			查询所有服务号的未读消息
//			sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 1",table_public_service_message];
            
            sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a, %@ b where b.read_flag = 1 and a.service_id = b.service_id and a.service_status = 0",table_public_service,table_public_service_message];
		}
		else if(serviceId == -2)
		{
			//			只查询显示在服务号里面的服务号的消息
			sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a, %@ b where b.read_flag = 1 and a.service_id = b.service_id and a.service_type = 0 and a.service_status = 0",table_public_service,table_public_service_message];
		}
		else
		{
			sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where service_id = %d and read_flag = 1",table_public_service_message,serviceId];
            
		}
        
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}


//查询是否有机组群，如果有返回YES，这样就可以在会话列表显示机组群
-(BOOL)hasFLTGroup
{
	int _count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where substr(conv_id,1,1) = 'g' ",table_conversation];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //		[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	
	if(_count > 0)
	{
		return YES;
	}
	return NO;
}

//查询机组群中未读消息数，然后显示在会话列表机组群的未读消息数
-(int)getUnreadMsgCountOfFLT
{
	int _count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 1 and substr(conv_id,1,1) = 'g' ",table_conv_records];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
    
}

//查询机组群中最近的一条消息
-(ConvRecord*)getLastConvRecordOfFLT
{
	ConvRecord *record = [[ConvRecord alloc]init];
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where substr(conv_id,1,1) = 'g' order by msg_time desc limit 1",table_conv_records];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		
		if([result count] > 0)
		{
			NSDictionary *dic = [result objectAtIndex:0];
			
            //			[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[dic description]]];
            
			record.msg_type = [[dic objectForKey:@"msg_type"]intValue];
			record.msg_body = [dic objectForKey:@"msg_body"];
			record.msg_time = [dic objectForKey:@"msg_time"];
			record.emp_id = [[dic objectForKey:@"emp_id"]intValue];
			
            record.send_flag = [[dic objectForKey:@"send_flag"]intValue];
            
            eCloudDAO *db = [eCloudDAO getDatabase];
            
			Emp *emp = [db getEmployeeById:[StringUtil getStringValue:record.emp_id]];
			
			if(emp)
			{//本地包含此员工
				if(emp.emp_name && emp.emp_name.length > 0)
				{
					record.emp_name = emp.emp_name;
				}
				else if(emp.empCode && emp.empCode.length > 0)
				{
					record.emp_name = emp.empCode;
				}
			}
			else
			{//本地不包含此员工
				record.emp_name = [StringUtil getStringValue:record.emp_id];
			}
		}
	}
	return [record autorelease];
}


//查询最近50个机组群，可以参照查询最近的50个会话
-(NSArray*)getRecentFLTGroup
{
	NSMutableArray *array = [NSMutableArray array];
	@autoreleasepool {
        //		NSString *sql = [select ]
	}
	
	return nil;
}

//查询会话时，要排除掉机组群，机组群需要放在

//查询所有的服务号，如果有推送的消息，那么就显示最近的消息和消息时间，还要显示本服务号的未读消息数
-(NSArray*)getAllPSMsgList
{
	NSMutableArray *array = [NSMutableArray array];
	@autoreleasepool {
        NSArray *allService = [self getAllService:service_type_in_ps];
		int serviceId;
		for(ServiceModel *_service in allService)
		{
			serviceId = _service.serviceId;
			ServiceMessage *message = [self getLastPSMsg:serviceId];
			if(message.msgId < 0)
			{
                //				如果还没有收到过推送消息，那么不处理
				continue;
			}
			
            //			如果
			int unread = [self getUnreadMsgCountOfPS:serviceId];
			
			Conversation *_conv = [[Conversation alloc]init];
			_conv.serviceModel = _service;
			
			_conv.conv_id = [StringUtil getStringValue:serviceId];
			
			_conv.unread = unread;
			_conv.conv_title = _service.serviceName;
			
            [LogUtil debug:[NSString stringWithFormat:@"%s 服务号名字是 %@ 未读数是 %d",__FUNCTION__,_service.serviceName,unread]];
            
			ConvRecord *_convRecord = [[ConvRecord alloc]init];
			if(message.msgType == ps_msg_type_news && message.detail.count>0)
			{
				ServiceMessageDetail *detailMsg = [message.detail objectAtIndex:0];
				_convRecord.msg_body = detailMsg.msgBody;
			}
			else
			{
                if (message.msgType == ps_msg_type_pic) {
                    _convRecord.msg_body = [StringUtil getLocalizableString:@"msg_type_pic"];
                }else{
                    _convRecord.msg_body = message.msgBody;                    
                }
			}
			
			_convRecord.msg_time = [StringUtil getStringValue:message.msgTime];
			
			_convRecord.msg_flag = message.msgFlag;
			
			if(message.msgFlag == send_msg)
			{
				conn *_conn = [conn getConn];
				_convRecord.emp_name = _conn.userName;
			}
			_conv.last_record = _convRecord;
			[_convRecord release];
			
			[array addObject:_conv];
			[_conv release];
		}
	}
	
    array = [array sortedArrayUsingSelector:@selector(compareByLastMsgTimeOnly:)];
	return array;
}

//把某一个服务号的所有的未读消息修改为已读
-(void)updateReadFlagOfPSMsg:(int)serviceId
{
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where service_id = %d",table_public_service_message,serviceId];
		[self operateSql:sql Database:_handle toResult:nil];
        
//        这里需要一些细节处理 add by shisp 显示的会话列表里的服务号 和 显示的服务号里面的服务号，处理方法会有不同。暂时先不处理
        NSString *convId = [self getConvIdByServiceId:serviceId];
        if (convId) {
            [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil] andCmdType:read_all_msg];
        }
        
        eCloudNotification *_notification = [[[eCloudNotification alloc]init]autorelease];
        _notification.cmdId = ps_msg_read;
        
        [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notification andUserInfo:nil];
	}
}

//保存某服务号未发送的消息
-(void)saveLastInputMsgOfService:(int)serviceId andLastInputMsg:(NSString*)message
{
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set last_input_msg = '%@' where service_id = %d",table_public_service,message,serviceId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}


//根据serviceMsgid获取对应的消息
-(ServiceMessage*)getMessageByServiceMsgId:(int)serviceMsgId
{
	ServiceMessage *message = [[ServiceMessage alloc]init];
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = %d",table_public_service_message,serviceMsgId];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if(result.count > 0)
		{
			NSDictionary *dic = [result objectAtIndex:0];
			[self saveResult:dic toServiceMessage:message];
			if(message.msgType == ps_msg_type_news)
			{
				NSArray *detail = [self getDetailMsgByMessage:message];
				message.detail = detail;
			}
		}
	}
	return [message autorelease];
}

//设置serviceMsgId对应的消息为已读
-(void)updateReadFlagByServiceMsgId:(int)serviceMsgId
{
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where msg_id = %d",table_public_service_message,serviceMsgId];
		[self operateSql:sql Database:_handle toResult:nil];
        
        sql = [NSString stringWithFormat:@"select service_id from %@ where msg_id = %d",table_public_service_message,serviceMsgId];
        NSMutableArray *result = [self querySql:sql];
        if (result && result.count > 0) {
            NSDictionary *dic = [result objectAtIndex:0];
            int serviceId = [[dic valueForKey:@"service_id"]intValue];
            
            NSString *convId = [self getConvIdByServiceId:serviceId];
            if (convId) {
                [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil] andCmdType:read_one_msg];
            }
        }
	}
}

//更新公众号消息发送状态
- (void)updateSendFlagOfServiceMessage:(ServiceMessage*)serviceMessage{
    int msgId = serviceMessage.msgId;
    int sendFlag = serviceMessage.sendFlag;
    
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set send_flag = '%d' where msg_id = '%d'",table_public_service_message,sendFlag,msgId];
        NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
	}
}


//把所有的服务号的消息设置为已读
-(void)setAllPSMsgToRead
{
	int unreadCount = [self getUnreadMsgCountOfPS:-1];
	if(unreadCount > 0)
	{
		@autoreleasepool {
			NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where read_flag = 1",table_public_service_message];
			[self operateSql:sql Database:_handle toResult:nil];
		}
	}
}

//删除一条推送消息
-(void)deleteServiceMessage:(ServiceMessage*)serviceMessage;
{
	int serviceMsgId = serviceMessage.msgId;
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where msg_id = %d",table_public_service_message,serviceMsgId];
	[self operateSql:sql Database:_handle toResult:nil];
	
    //	如果是新闻消息，那么需要删除明细信息
	if(serviceMessage.msgType == ps_msg_type_news)
	{
		sql = [NSString stringWithFormat:@"delete from %@ where service_msg_id = %d",table_public_service_message_detail,serviceMsgId];
		[self operateSql:sql Database:_handle toResult:nil];
		
		for(ServiceMessageDetail *detailMsg in serviceMessage.detail)
		{
			[StringUtil deleteFile:[PSMsgUtil getDtlImgPath:detailMsg]];
		}
	}
    else if (serviceMessage.msgType == ps_msg_type_pic)
    {
        ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
        _convRecord.conv_id = [StringUtil getStringValue:serviceMessage.serviceId];
        _convRecord.msgId = serviceMsgId;
        [StringUtil deleteFile:[PSMsgUtil getPSPicMsgImagePath:_convRecord]];
    }
}

#pragma mark 判断会话列表中是否包含 fltGroupConvType 类型的会话记录，如果没有则创建这样一条记录，把收到的机组群的grpid去掉g,作为群组id
- (NSString *)createConvOfFltGroupType:(NSString *)fltGroupId
{
    NSString *sql = [NSString stringWithFormat:@"select conv_id from %@ where conv_type = %d",table_conversation,fltGroupConvType];
    NSMutableArray *result = [self querySql:sql];
    if (result.count >= 1) {
        //        NSLog(@"机组群会话类型存在，直接返回conv_id即可");
        return [[result objectAtIndex:0]valueForKey:@"conv_id"];
    }
    else
    {
        //        NSLog(@"机组类型的会话类型不存在，需要创建");
        if (fltGroupId && [fltGroupId hasPrefix:@"g"]) {
            NSString *convId = [fltGroupId substringFromIndex:1];
            
            NSString *recvFlag = [StringUtil getStringValue:open_msg];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [StringUtil getStringValue:convId],@"conv_id",
                                 [StringUtil getStringValue:fltGroupConvType],@"conv_type",
                                 [StringUtil getLocalizableString:@"flt_group"],@"conv_title",
                                 recvFlag,@"recv_flag",nil];
            
            [[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
            
            return convId;
        }
    }
    //    NSLog(@"机组类型的会话类型不存在，也没有创建成功");
    return nil;
}

#pragma mark 当添加一条聊天记录时，如果发现是机组群的消息，那么需要把这条消息保存为会话列表中机组群的最后一条消息
- (void)processFltGroupMsg:(NSDictionary *)dic andId:(int)_id
{
    NSString *convId = [dic valueForKey:@"conv_id"];
    //    如果是机组群消息，那么需要去创建机组群类型的会话，并且修改最后一条消息记录
    if (convId && [convId hasPrefix:@"g"])
    {
        NSString *fltGrpConvId = [self createConvOfFltGroupType:convId];
        
        if (fltGrpConvId == nil) {
            return;
        }
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? , last_msg_type = ?,display_flag = 0 where conv_id = '%@' ",table_conversation,fltGrpConvId];
        
        sqlite3_stmt *stmt = nil;
        
        pthread_mutex_lock(&add_mutex);
        int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
        pthread_mutex_unlock(&add_mutex);
        
        if(state != SQLITE_OK)
        {
            //			编译错误
            [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
            //			释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
        }
        else
        {
            //		绑定值
            pthread_mutex_lock(&add_mutex);
            
            sqlite3_bind_int(stmt, 1,_id);
            sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"msg_body"] UTF8String],-1,NULL);
            sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
            sqlite3_bind_int(stmt, 4,[[dic valueForKey:@"msg_type"]intValue]);
            //	执行
            state = sqlite3_step(stmt);
            
            pthread_mutex_unlock(&add_mutex);
            //	执行结果
            if(state != SQLITE_DONE &&  state != SQLITE_OK)
            {
                //			执行错误
                [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
            }
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
        }
    }
}

#pragma mark 当获取机组群的时候，查看最早的机组群，看是否已经过了7天的有效期，如果已经过了，那么删除这条会话，然后再查询下一条，如果没有过，那么就退出
- (void)deleteNotValidFltGroup
{
    NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_title from %@ where conv_type = %d  and conv_id like 'g%%' order by create_time limit(1)",table_conversation,mutiableType];
    NSMutableArray *result = [self querySql:sql];
    
    if (result && result.count > 0)
    {
        NSString *convId = [[result objectAtIndex:0]valueForKey:@"conv_id"];
        NSString *convTitle = [[result objectAtIndex:0]valueForKey:@"conv_title"];
        
        if (convTitle && convTitle.length > 0)
        {
            NSRange startRange = [convTitle rangeOfString:@"["];
            if (startRange.length > 0)
            {
                NSRange endRange = [convTitle rangeOfString:@"]" options:NSBackwardsSearch];
                if (endRange.length > 0 && startRange.location < endRange.location)
                {
                    NSString *fltDateStr = [convTitle substringWithRange:NSMakeRange(startRange.location + 1, endRange.location - startRange.location - 1)];
                    
                    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
                    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *fltDate = [inputFormatter dateFromString:fltDateStr];
                    int timeInterval =  [[NSDate date]timeIntervalSinceNow] - [fltDate timeIntervalSinceNow];
                    if (timeInterval > flt_group_valid_interval) {
                        NSLog(@"%@已经过期,删除",convTitle);
                        [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:convId];
                        [self deleteNotValidFltGroup];
                    }
                }
                else
                {
                    NSLog(@"会话id以g开头，但不包含]，或者位置不对");
                    [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:convId];
                    [self deleteNotValidFltGroup];
                }
            }
            else
            {
                NSLog(@"会话id以g开头，但会话标题中不包含[");
                [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:convId];
                [self deleteNotValidFltGroup];
            }
        }
        else
        {
            NSLog(@"还没有机组群");            
        }
    }
}

//根据serviceId得到convId
- (NSString *)getConvIdByServiceId:(int)serviceId
{
    NSString *convId = nil;
    
    ServiceModel *_serviceModel = [self getServiceByServiceId:serviceId];
    if(_serviceModel.serviceType == 1)
    {
        convId = [StringUtil getStringValue:serviceId];
        [self createConversation:_serviceModel];
    }
    else if(_serviceModel.serviceType == 0)
    {
        //			不再会话列表的显示的服务号
        NSString *sql = [NSString stringWithFormat:@"select conv_id from %@ where conv_type = %d",table_conversation,serviceNotInConvType];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:_handle toResult:result];
        if(result.count > 0)
        {
            //				修改最后一条消息
            convId = [[result objectAtIndex:0]valueForKey:@"conv_id"];
        }
        else
        {
            //				增加一个新的会话，显示不在会话列表显示的服务号消息入口，默认的convid为第一条收到的服务号的serviceid
            //				默认屏蔽，收到该服务号的消息后，再设置为打开
            NSString *recvFlag = [StringUtil getStringValue:open_msg];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [StringUtil getStringValue:_serviceModel.serviceId],@"conv_id",
                                 [StringUtil getStringValue:serviceNotInConvType],@"conv_type",
                                 [StringUtil getLocalizableString:@"public_service"],@"conv_title",
                                 recvFlag,@"recv_flag",nil];
            
            [[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
            
            convId = [StringUtil getStringValue:_serviceModel.serviceId];
        }
    }

    return convId;
}

#pragma mark ----------------------------公众平台菜单相关-----------------------------------

#pragma mark - 保存公众平台菜单信息
-(bool)savePSMenuListInfo:(NSArray *)info{
    bool success = false;
    
    for (ServiceMenuModel *menuModel in info)
    {
        ServiceMenuModel *updateMenuModel = [self getPSMenuListByPlatformid:menuModel.platformid];
        if (updateMenuModel.platformid) {
            //数据库存在，更新数据库
            [self updateMenuInfo:updateMenuModel withNewMenuModel:menuModel];
        }
        else{
            [self addOneMenuInfo:menuModel];
        }
    }
    
    return success;
}

-(bool)updateMenuInfo:(ServiceMenuModel*)oldMenuModel withNewMenuModel:(ServiceMenuModel*)menuModel
{
	bool success = false;
	NSString *sql = [NSString stringWithFormat:@"update %@ set button = ?,createtime = ? where platformid = '%d'", table_public_service_menu_list,menuModel.platformid];
    
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		pthread_mutex_lock(&add_mutex);
        
        sqlite3_bind_text(stmt, 1, [[menuModel.button JSONString] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [menuModel.createtime UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 2, menuModel.createtime);
        
        //执行
		state = sqlite3_step(stmt);
		
		pthread_mutex_unlock(&add_mutex);
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
        
        
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	return success;
}


-(bool)addOneMenuInfo:(ServiceMenuModel*)menuModel
{
	bool success = false;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(platformid,button,createtime) values(?,?,?)", table_public_service_menu_list];
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		pthread_mutex_lock(&add_mutex);
        sqlite3_bind_int(stmt, 1, menuModel.platformid);
        sqlite3_bind_text(stmt, 2, [[menuModel.button JSONString] UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [menuModel.createtime UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 3, menuModel.createtime);
        
        //执行
		state = sqlite3_step(stmt);
		
		pthread_mutex_unlock(&add_mutex);
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
        
        
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	return success;
}

#pragma mark - 获取所有公众号菜单
-(NSMutableArray *)getAllMenuList{
    NSMutableArray *appsList = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@",table_public_service_menu_list];
	NSMutableArray *result = [[NSMutableArray alloc]init];
	[self operateSql:sql Database:_handle toResult:result];
    
//    NSLog(@"result-------%@",result);
    
	for(NSDictionary *dic in result)
	{
		ServiceMenuModel *menuModel = [[ServiceMenuModel alloc]init];
		[self saveResult:dic toMenuModel:menuModel];
		[appsList addObject:menuModel];
		[menuModel release];
	}
	[result release];
	[pool release];
    
	return appsList;
}

#pragma mark - 根据platformid获取菜单信息
-(ServiceMenuModel*)getPSMenuListByPlatformid:(int)platformid{
    
    ServiceMenuModel *menuModel = [[ServiceMenuModel alloc]init];
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where platformid = '%d'",table_public_service_menu_list,platformid];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if(result.count == 1)
		{
			[self saveResult:[result objectAtIndex:0] toMenuModel:menuModel];
		}
	}
	
	return [menuModel autorelease];
}

-(void)saveResult:(NSDictionary*)dic toMenuModel:(ServiceMenuModel *)menuModel
{
	menuModel.platformid = [[dic valueForKey:@"platformid"] intValue];
	menuModel.createtime = [dic valueForKey:@"createtime"];
    menuModel.button = [[dic valueForKey:@"button"] objectFromJSONString];
}

#pragma mark - 删除公众号菜单
-(void)deletePSMenuListByByPlatformid:(int)platformid{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where platformid = %d",table_public_service_menu_list,platformid];
        [self operateSql:sql Database:_handle toResult:nil];
        
    }
}

#pragma mark  根据服务号id，查询公众号收到的图片记录，按照时间排序，最近的要排在前面
-(NSArray *)getPicConvRecordBy:(int)serviceId{
    NSMutableArray *records = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_id = '%d' and msg_type = %d order by msg_time",table_public_service_message,serviceId,ps_msg_type_pic];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [[ConvRecord alloc]init];
        [self saveResult:dic toConvRecord:record];
        [records addObject:record];
        [record release];
    }
    [pool release];
    return records;
}

#pragma mark 删除某个公众号的所有消息
- (void)removeAllRecordsOfService:(int)serviceId
{
    //	查询这个服务号 一共有哪些 消息 因为需要删除 对应 的资源 文件
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where service_id = %d",table_public_service_message,serviceId];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    for(int i=0;i<[result count];i++)
    {
//        取出一条
        NSDictionary *dic = [result objectAtIndex:i];
        
//        NSLog(@"%s %@",__FUNCTION__,[dic description]);
        
//        判断类型
        int msgType = [[dic valueForKey:@"msg_type"]intValue];

        if (msgType == ps_msg_type_news) {
//            新闻类型
            ServiceMessage *serviceMessage = [[[ServiceMessage alloc]init]autorelease];
            [self saveResult:dic toServiceMessage:serviceMessage];
            

            NSArray *details = [self getDetailMsgByMessage:serviceMessage];
            
            //                删除 新闻 对应 的资源
            for (ServiceMessageDetail *detailMsg in details) {
                [StringUtil deleteFile:[PSMsgUtil getDtlImgPath:detailMsg]];
            }

            //    删除明细消息
            sql = [NSString stringWithFormat:@"delete from %@ where service_msg_id = %d",table_public_service_message_detail,serviceMessage.msgId];
            [self operateSql:sql Database:_handle toResult:nil];

            NSLog(@"%s 新闻类型消息",__FUNCTION__);

        } else if (msgType == ps_msg_type_pic){
            ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
            [self saveResult:dic toConvRecord:_convRecord];
            [StringUtil deleteFile:[PSMsgUtil getPSPicMsgImagePath:_convRecord]];
            NSLog(@"%s 图片类型消息",__FUNCTION__);

        }else{
            NSLog(@"%s 其它类型消息",__FUNCTION__);
        }
    }

    sql = [NSString stringWithFormat:@"delete from %@ where service_id = %d ",table_public_service_message,serviceId];
    [self operateSql:sql Database:_handle toResult:nil];
    NSLog(@"delete ok");
    
}
@end

