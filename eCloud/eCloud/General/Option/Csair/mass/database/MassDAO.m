//
//  MassDAO.m
//  eCloud
//
//  Created by Richard on 14-1-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "MassDAO.h"
#import "massConversationObject.h"
#import "eCloudDAO.h"
#import "MassSql.h"
#import "Conversation.h"
#import "ConvRecord.h"
#import "Dept.h"
#import "Emp.h"
#import "eCloudDefine.h"
#import "conn.h"
//72小时
#define MASS_MSG_MERGE_TIME (259200)

static MassDAO *massDAO;
@implementation MassDAO

//获取数据库的实例
+(id)getDatabase
{
	if(massDAO == nil)
	{
		massDAO = [[MassDAO alloc]init];
       
	}
	return massDAO;
}

#pragma mark 增加群发会话
-(void)addConversation:(NSDictionary *) dic
{
	NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,conv_title,create_emp_id,create_time,last_msg_id,last_msg_time,emp_count) values(?,?,?,?,?,?,?)",table_mass_conversation];
	
	sqlite3_stmt *stmt = nil;
	
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
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
	sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"conv_title"] UTF8String],-1,NULL);//conv_title
	sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"create_emp_id"]intValue]);//create_emp_id
	sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"create_time"]UTF8String],-1,NULL);//create_time
	sqlite3_bind_int(stmt, 5, [[dic valueForKey:@"last_msg_id"]intValue]);//last_msg_id
	sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"create_time"]UTF8String],-1,NULL);//last_msg_time 和 create_time 一致
	sqlite3_bind_int(stmt, 7, [[dic valueForKey:@"emp_count"]intValue]);//emp_count
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

#pragma mark  增加群发成员
-(void)addConvMember:(NSArray *) info
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"conv_id",@"member_type",@"member_id", nil];
	
	if([self beginTransaction])
	{
		NSString    *sql        =   nil;
		
		for (NSDictionary *dic in info)
		{
			sql =   [self insertTable:table_mass_conv_member newInfo:dic keys:keys];
			
			char *errorMessage;
			
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
			
			if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
		}
		[self commitTransaction];
	}
}

#pragma mark 增加群发消息包括发送的和收到的
-(NSDictionary*)addConvRecord:(NSDictionary*)dic
{
	NSLog(@"%s,%@",__FUNCTION__,dic);
	NSString *msgBody = [dic valueForKey:@"msg_body"];
	
	//			如果是发送的消息，那么就需要重新生成msg_id
	//		增加了同步消息功能后，应该是判断如果消息id为空，才生成消息id
	NSString *_sendOriginMsgId = [dic valueForKey:@"origin_msg_id"];
	
	if(_sendOriginMsgId == nil || _sendOriginMsgId.length == 0)
	{
		_sendOriginMsgId = [NSString stringWithFormat:@"%lld", [[conn getConn]getNewMsgId]];
	}
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,emp_id,msg_type,msg_body,msg_time,read_flag,msg_flag,send_flag,file_size,file_name,origin_msg_id,is_set_redstate,read_notice_flag,send_msg_id) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",table_mass_conv_records];
	
	sqlite3_stmt *stmt = nil;
	
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
		return nil;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
	sqlite3_bind_int(stmt, 2, [[dic valueForKey:@"emp_id"] intValue]);//emp_id
	sqlite3_bind_int(stmt,3,[[dic valueForKey:@"msg_type"] intValue]);//msg_type
	sqlite3_bind_text(stmt,4,[msgBody UTF8String],-1,NULL);//msg_body
	sqlite3_bind_text(stmt,5,[[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//msg_time
	sqlite3_bind_int(stmt,6,[[dic valueForKey:@"read_flag"] intValue]);//read_flag
	sqlite3_bind_int(stmt,7,[[dic valueForKey:@"msg_flag"] intValue]);//msg_flag
	sqlite3_bind_int(stmt,8,[[dic valueForKey:@"send_flag"] intValue]);//send_flag
	sqlite3_bind_int(stmt,9,[[dic valueForKey:@"file_size"]intValue]);//file_size
	sqlite3_bind_text(stmt,10,[[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//file_name
	sqlite3_bind_text(stmt,11,[_sendOriginMsgId UTF8String],-1,NULL);//origin_msg_id
	sqlite3_bind_int(stmt,12,[[dic valueForKey:@"is_set_redstate"] intValue]);//is_set_redstate
	sqlite3_bind_int(stmt,13,[[dic valueForKey:@"read_notice_flag"] intValue]);//
	sqlite3_bind_int(stmt,14,[[dic valueForKey:@"send_msg_id"] intValue]);//
	//	执行
	state = sqlite3_step(stmt);
	
	pthread_mutex_unlock(&add_mutex);
	//	执行结果
	if(state != SQLITE_DONE &&  state != SQLITE_OK)
	{
		//			执行错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		return nil;
	}
	//释放资源
	pthread_mutex_lock(&add_mutex);
	sqlite3_finalize(stmt);
	pthread_mutex_unlock(&add_mutex);
	
	//		这里查询一下数据库中自动增长的消息id
	
	sql = [NSString stringWithFormat:@"select max(id) as _id from %@",table_mass_conv_records];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count == 1)
	{
		//			查到之后，把两个id，一个是消息id，一个数据库自增长id，一起返回，便于灵活使用
		NSString *_id = [[result objectAtIndex:0]valueForKey:@"_id"];
		[self updateConvLastMsg:dic andNewMsgId:_id.intValue];
		
		NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_id,@"msg_id",_sendOriginMsgId,@"origin_msg_id", nil];
		return _dic;
	}
	return nil;
}

#pragma mark 判断是不是第一次向这个群发会话发消息
-(bool)isFirstSendMsg:(NSString*)convid
{
	NSString *sql = [NSString stringWithFormat:@"select last_msg_id from %@ where conv_id = '%@' ",table_mass_conversation,convid];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] > 0)
	{
		//		如果last_msg_id为-1，表示还没有发送过消息
		if([[[result objectAtIndex:0]valueForKey:@"last_msg_id"]intValue] == -1)
			return true;
		return false;
	}
	return true;
}

#pragma mark 修改会话信息 会话名称
-(void)updateConvTitle:(NSString*)convId andConvTitle:(NSString*)convTitle
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set conv_title = ? where conv_id='%@' ",table_mass_conversation,convId];
	
	sqlite3_stmt *stmt = nil;
	
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
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	
	sqlite3_bind_text(stmt, 1, [convTitle UTF8String],-1,NULL);
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

#pragma mark 修改会话的最后一条消息的消息内容等
-(void)updateConvLastMsg:(NSDictionary*)dic andNewMsgId:(int)_id
{
	int msgFlag = [[dic valueForKey:@"msg_flag"]intValue];
	NSString *convId = [dic valueForKey:@"conv_id"];
	
	sqlite3_stmt *stmt = nil;
	int state;
	
	if(msgFlag == send_msg)//如果是发送的消息，那么修改最后一条消息的相关属性
	{
		NSString *msgBody = [dic valueForKey:@"msg_body"];
		int msgType = [[dic valueForKey:@"msg_type"] intValue];
		//			如果是长消息那么应该保存消息头，如果是文件消息则保存文件名字
		if(msgType == type_long_msg || msgType == type_file)
		{
			msgBody = [dic valueForKey:@"file_name"];
		}

		if([self isFirstSendMsg:convId] && msgType != type_group_info)//如果是第一次发送一呼万应的消息，则需要修改标题
		{
			[self updateConvTitle:convId andConvTitle:msgBody];
		}
		
		NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ? where conv_id =? "
						 ,table_mass_conversation];
		
		//		编译
		pthread_mutex_lock(&add_mutex);
		state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
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
			
			sqlite3_bind_int(stmt, 1,_id);//last_msg_id

			sqlite3_bind_text(stmt, 2, [msgBody UTF8String],-1,NULL);//last_msg_body
			sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
			sqlite3_bind_int(stmt, 4, [[dic valueForKey:@"emp_id"] intValue]);//last_emp_id
			sqlite3_bind_int(stmt, 5, [[dic valueForKey:@"msg_type"] intValue]);//last_msg_type
			sqlite3_bind_text(stmt, 6, [convId UTF8String],-1,NULL);//conv_id
			
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
	else
	{
		NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_time=? where conv_id =? "
						 ,table_mass_conversation];
		
		//		编译
		pthread_mutex_lock(&add_mutex);
		state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
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
			sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
			sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
			
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


#pragma mark  根据msgId获取一条会话记录
-(ConvRecord *)getConvRecordByMsgId:(NSString*)msgId
{
	NSString * sql = [NSString stringWithFormat:@"select * from %@ where id = %@ ",table_mass_conv_records, msgId];
	NSMutableArray *result = [self querySql:sql];
	if(result && [result count]>0)
	{
		NSDictionary *dic = [result objectAtIndex:0];
		ConvRecord *record = [[[ConvRecord alloc]init]autorelease];
		[self putData:dic toConvRecord:record];
		return record;
	}
	return nil;
}

#pragma mark 根据会话Id，查询某个会话的总的记录个数，但只包括发送的
-(int)getConvRecordCountBy:(NSString*)convId
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where conv_id = '%@' and msg_flag = %d ",table_mass_conv_records,convId,send_msg];

	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
}

#pragma mark  根据会话id，查询会话记录，按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getConvRecordBy:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset
{
	NSMutableArray *records = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and msg_flag = %d  order by msg_time,id limit(%d) offset(%d)",table_mass_conv_records,convId,send_msg,_limit,_offset];
	
	NSMutableArray *result = [self querySql:sql];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [[ConvRecord alloc]init];
		[self putData:dic toConvRecord:record];
		[records addObject:record];
		[record release];
	}
	return records;
}

#pragma mark 获取最后一条输入信息
-(NSString *)getLastInputMsgByConvId:(NSString *)conv_id
{
	NSString *lastInputMsg=@"";
    NSString *sql = [NSString stringWithFormat:@"select lastmsg_body from %@ where conv_id= '%@' ",table_mass_conversation,conv_id];
  	NSMutableArray *result = [self querySql:sql];
	if([result count]>0)
	{
        NSDictionary *dic=[result objectAtIndex:0];
        lastInputMsg=[dic objectForKey:@"lastmsg_body"];
    }
	return  lastInputMsg;
}

#pragma mark 修改会话消息,图片等上传成功后，不修改时间，而是修改状态为正在sending
-(void)updateConvRecord:(NSString *)msgId andMSG:(NSString*)msg_body andFileName:(NSString*)file_name andMsgType:(int)msgType
{
	//	图片上传成功后，不修改时间，而是修改状态为正在sending
	NSString *sql = nil;
 	
    if(msgType == type_file)
    {
//        文件类型，发送文件保存时增加后缀 _
//        update by shisp
        sql =[NSString stringWithFormat:@"update %@ set msg_body='%@_',send_flag = %d where id=%@ ",table_mass_conv_records,msg_body,sending,msgId];
    }
    else
    {
       	//	如果是长消息，上传成功后，不修改文件名称
        if(file_name == nil)
        {
            sql =[NSString stringWithFormat:@"update %@ set msg_body='%@',send_flag = %d where id=%@ ",table_mass_conv_records,msg_body,sending,msgId];
        }
        else
        {
            sql =[NSString stringWithFormat:@"update %@ set msg_body='%@',file_name='%@',send_flag = %d where id=%@ ",table_mass_conv_records,msg_body,file_name,sending,msgId];
        }
    }
	
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,上传图片或录音成功后，修改数据库记录失败",__FUNCTION__]];
	}
}

#pragma mark 保存聊天记录到对象中
-(void)putData:(NSDictionary*)dic toConvRecord:(ConvRecord *)record
{
	record.recordType = mass_conv_record_type;
	record.msgId = [[dic objectForKey:@"id"]intValue];
	record.conv_id = [dic objectForKey:@"conv_id"];
	record.emp_id = [[dic objectForKey:@"emp_id"]intValue];
	record.msg_type = [[dic objectForKey:@"msg_type"]intValue];
	record.msg_body = [dic objectForKey:@"msg_body"];
	record.msg_time = [dic objectForKey:@"msg_time"];
	record.read_flag = [[dic objectForKey:@"read_flag"]intValue];
	record.msg_flag = [[dic objectForKey:@"msg_flag"]intValue];
	record.send_flag = [[dic objectForKey:@"send_flag"]intValue];
	record.file_size = [StringUtil getStringValue:[[dic objectForKey:@"file_size"]intValue]];
	record.file_name = [dic objectForKey:@"file_name"];
	NSString *originMsgId = [dic valueForKey:@"origin_msg_id"];
	NSRange range = [originMsgId rangeOfString:@"|"];
	if(range.length > 0)
	{
		originMsgId = [originMsgId substringToIndex:range.location];
	}
	record.origin_msg_id = [originMsgId longLongValue];
    record.is_set_redstate=([dic objectForKey:@"is_set_redstate"]==nil)?0:[[dic objectForKey:@"is_set_redstate"] intValue];
	record.readNoticeFlag = [[dic objectForKey:@"read_notice_flag"] intValue];
	
//	查询总人数，计算已回复人数
	record.mass_total_emp_count = [self getTotalEmpCountByConvId:record.conv_id];
	record.mass_reply_emp_count = [self getReplyEmpCountByMsgId:record.msgId];
}

-(int)getTotalEmpCountByConvId:(NSString*)convId
{
	NSString *sql = [NSString stringWithFormat:@"select emp_count from %@ where conv_id = '%@'",table_mass_conversation,convId];
	NSMutableArray *result = [self querySql:sql];
	if(result.count > 0)
	{
		return [[[result objectAtIndex:0]valueForKey:@"emp_count"]intValue];
	}	
	return 0;
}

-(int)getReplyEmpCountByMsgId:(int)msgId
{
	NSString *sql = [NSString stringWithFormat:@"select distinct(emp_id) from %@ where msg_flag = %d and send_msg_id = %d",table_mass_conv_records,rcv_msg,msgId];
	NSMutableArray *result = [self querySql:sql];
	return result.count;
}

#pragma mark 根据群发会话id获取成员
-(NSArray*)getConvMemberByConvId:(NSString*)convId
{
	NSMutableArray *memberArray = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select member_type,member_id from %@ where conv_id = '%@'",table_mass_conv_member,convId];
	NSMutableArray *result = [self querySql:sql];
	for(NSDictionary *dic in result)
	{
		int memberType = [[dic valueForKey:@"member_type"]intValue];
		int memberId = [[dic valueForKey:@"member_id"]intValue];
		if(memberType == emp_member_type)
		{
			Emp *emp = [[Emp alloc]init];
			emp.emp_id = memberId;
			[memberArray addObject:emp];
			[emp release];
		}
		else
		{
			Dept *dept = [[Dept alloc]init];
			dept.dept_id = memberId;
			[memberArray addObject:dept];
			[dept release];
		}
	}
	return memberArray;
}

#pragma mark 点击头像进入相应用户的单聊会话 根据消息id，根据用户id，
-(void)transferMassMsgByMsgId:(int)msgId andEmpId:(int)empId andReplyCount:(int)replyCount
{
//	根据msgId查询msgId对应的会话id
	NSString *sql = [NSString stringWithFormat:@"select conv_id from %@ where id = %d",table_mass_conv_records,msgId];
	NSMutableArray *result = [self querySql:sql];
	if(result.count > 0)
	{
		//		判断单聊会话是否存在，如果不存在则创建
		if(replyCount > 0)
		{
			[self createSingleConversation:empId];
		}
		
		NSString *convId = [[result objectAtIndex:0]valueForKey:@"conv_id"];
		//	复制该群发会话里所有发出去的消息，不包括提示消息
		sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and msg_flag = %d and msg_type <> %d ",table_mass_conv_records,convId,send_msg,type_group_info];
		result = [self querySql:sql];
		for(NSDictionary *dic in result)
		{
			ConvRecord *_convRecord = [[ConvRecord alloc]init];
			[self putData:dic toConvRecord:_convRecord];
			_convRecord.conv_id = [StringUtil getStringValue:empId];
			_convRecord.send_flag = send_success;
			if(_convRecord.origin_msg_id>0)
			{//调整origin_msg_id的值，否则会造成插入会话表失败
				_convRecord.origin_msg_id = _convRecord.origin_msg_id - empId;
			}
			else
			{
				_convRecord.origin_msg_id = _convRecord.origin_msg_id + empId;
			}
			[self transferMassMsg:_convRecord];
			[_convRecord release];
		}
//		把收到的此emp的消息设置为已读
		sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where emp_id = %d and msg_flag = %d and conv_id = '%@'",table_mass_conv_records,empId,rcv_msg,convId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

-(void)updateLastMsg:(ConvRecord*)_convRecord andConvId:(NSString*)convId
{
	int msgId = _convRecord.msgId;
	NSString *msgBody = _convRecord.msg_body;
	int msgType = _convRecord.msg_type;
	if(msgType == type_file || msgType == type_long_msg)
	{
		msgBody = _convRecord.file_name;
	}
	NSString *msgTime = _convRecord.msg_time;
	int empId = _convRecord.emp_id;
	
	
	NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ?,display_flag = 0 where conv_id =? "
					 ,table_conversation];
	
	sqlite3_stmt *stmt = nil;
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
		sqlite3_bind_int(stmt, 1,msgId);//last_msg_id
		sqlite3_bind_text(stmt, 2, [msgBody UTF8String],-1,NULL);//last_msg_body
		sqlite3_bind_text(stmt, 3, [msgTime UTF8String],-1,NULL);//last_msg_time
		sqlite3_bind_int(stmt, 4, empId);//last_emp_id
		sqlite3_bind_int(stmt, 5, msgType);//last_msg_type
		sqlite3_bind_text(stmt, 6, [convId UTF8String],-1,NULL);//conv_id
		
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

-(void)createSingleConversation:(int)empId
{
	NSString *convId = [StringUtil getStringValue:empId];
	
	eCloudDAO *db = [eCloudDAO getDatabase];
	
	//		如果会话表里没有这条单聊记录，则添加
	if(![db searchConversationBy:convId])
	{
		NSString *empName = [db getEmpNameByEmpId:convId];
		conn *_conn = [conn getConn];
		NSString *nowTime =[_conn getSCurrentTime];
		//				单人会话
		NSString *convType = [StringUtil getStringValue:singleType];
		//				不屏蔽
		NSString *recvFlag = [StringUtil getStringValue:open_msg];
		
		NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",convType,@"conv_type",empName,@"conv_title",recvFlag,@"recv_flag",_conn.userId,@"create_emp_id",nowTime,@"create_time", nil];
		
		//		增加会话数据
		[db addConversation:[NSArray arrayWithObject:dic]];
		
		//			第一次和某个人聊天，下载用户资料和头像
		[db getUserInfoAndDownloadLogo:convId];
		
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' order by msg_time desc limit(1) ",table_conv_records,convId];
		NSMutableArray *result = [self querySql:sql];
		if(result.count > 0)
		{
			ConvRecord *_convRecord = [db getConvRecordByDicData:[result objectAtIndex:0]];
			[self updateLastMsg:_convRecord andConvId:convId];
		}
	}
}

#pragma mark 把群发相关的消息入到普通的单人会话记录中
-(void)transferMassMsg:(ConvRecord*)_convRecord
{
	if(_convRecord.file_name == nil)
	{
		_convRecord.file_name = @"";
	}
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
						  _convRecord.conv_id,@"conv_id",
						  [StringUtil getStringValue:_convRecord.emp_id],@"emp_id",
						  [StringUtil getStringValue:_convRecord.msg_type] ,@"msg_type",
						  _convRecord.msg_body,@"msg_body",
						  _convRecord.msg_time,@"msg_time",
						  [StringUtil getStringValue:_convRecord.msg_flag],@"msg_flag",
						  @"0",@"read_flag",
						  _convRecord.file_name,@"file_name",
						  _convRecord.file_size,@"file_size",
						  [NSString stringWithFormat:@"%lld",_convRecord.origin_msg_id],@"origin_msg_id",
						  [StringUtil getStringValue:_convRecord.is_set_redstate],@"is_set_redstate",
						 [StringUtil getStringValue:_convRecord.send_flag],@"send_flag",nil];
	eCloudDAO *db = [eCloudDAO getDatabase];
	dic = [db addConvRecord:[NSArray arrayWithObject:dic]];
	if(dic)
	{
		NSString *msgId = [dic valueForKey:@"msg_id"];
		[LogUtil debug:[NSString stringWithFormat:@"入普通单聊消息库成功%@",msgId]];
	}
}

#pragma mark 根据消息的id查询
-(NSString *)getMsgIdByOriginMsgId:(NSString*)_originMsgId
{
	NSString *msgId = nil;
	conn *_conn = [conn getConn];
	NSString *sql = [NSString stringWithFormat:@"select id from %@ where emp_id = %@ and origin_msg_id = %@",table_mass_conv_records,_conn.userId,_originMsgId];
	
	NSMutableArray *result = [self querySql:sql];
	if(result && result.count == 1)
	{
		msgId = [StringUtil getStringValue:[[[result objectAtIndex:0]valueForKey:@"id"]intValue]];
	}
	return msgId;
}

#pragma mark  修改消息状态，发送失败还是成功，发送或接受的状态
-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set send_flag = %d where id = %@ ",table_mass_conv_records,flag,msgId];
	[self operateSql:sql Database:_handle toResult:nil];
}
#pragma mark 获取所有发送的广播
-(NSArray *)getAllMassConversation
{
	NSMutableArray *all_conv = [NSMutableArray array];

	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by last_msg_time desc",table_mass_conversation];
	
	NSMutableArray *result = [self querySql:sql];
    massConversationObject *massObject;
    NSDictionary *dic;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		massObject=[[massConversationObject alloc]init];
        massObject.conv_id=[dic  objectForKey:@"conv_id"];
        massObject.conv_title=[dic  objectForKey:@"conv_title"];
        massObject.create_emp_id=[dic  objectForKey:@"create_emp_id"];
        massObject.create_time=[dic  objectForKey:@"create_time"];
        massObject.last_msg_id=[dic  objectForKey:@"last_msg_id"];
        massObject.lastmsg_body=[dic  objectForKey:@"lastmsg_body"];
        massObject.last_msg_body=[dic  objectForKey:@"last_msg_body"];
        massObject.last_msg_time=[dic  objectForKey:@"last_msg_time"];
        massObject.last_emp_id= [dic  objectForKey:@"last_emp_id"];
        massObject.last_msg_type= [[dic  objectForKey:@"last_msg_type"]intValue];
        massObject.emp_count=[[dic  objectForKey:@"emp_count"]intValue];
        massObject.unread=[self getUnReadNumByConvId:massObject.conv_id];
		[all_conv addObject:massObject];
		[massObject release];
	}
    
	return all_conv;
}
#pragma mark 广播的所有未读数量
-(int)getAllUnReadNum
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag=1",table_mass_conv_records];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;

}
#pragma mark 某条广播的所有未读数量
-(int)getUnReadNumByConvId:(NSString *)conv_id
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where conv_id = %@ and read_flag=1",table_mass_conv_records,conv_id];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
    
}

#pragma mark 某条广播的未读回复数量
-(int)getUnReadNumByMsgId:(int)msg_id
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where send_msg_id = %d and read_flag=1",table_mass_conv_records,msg_id];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
    
}
#pragma mark 某条广播的某人未读回复数量
-(int)getUnReadNumByEmpId:(int)emp_id andMsgId:(int)msg_id
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where emp_id = %d and send_msg_id = %d and read_flag=1",table_mass_conv_records,emp_id,msg_id];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;

}

#pragma mark 三级以下未读回复数量
-(int)getUnReadNumByConvID:(NSString*)conv_id andMsgId:(int)msg_id
{
    NSMutableArray *emps = [NSMutableArray array];
    
	NSString *sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id in(select member_id from %@ where conv_id=%@ and member_type=0)",table_department,table_mass_conv_member,conv_id];
	
	NSMutableArray *result = [self querySql:sql];
    
    NSDictionary *dic;
    NSString *dept_list=nil;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		if (dept_list==nil) {
            dept_list=[dic objectForKey:@"sub_dept"];
        }else{
            dept_list=[NSString stringWithFormat:@"%@,%@",dept_list,[dic objectForKey:@"sub_dept"]];
        }
	}
    NSLog(@"dept_list----- %@",dept_list);
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where emp_id in(select distinct e.emp_id from employee e,emp_dept d where e.emp_id=d.emp_id and (d.rank_id>5 or d.rank_id =0) and ( d.dept_id in(%@) or d.emp_id in(select member_id from mass_conv_member where conv_id=%@ and member_type=1))) and send_msg_id = %d and read_flag=1",table_mass_conv_records,dept_list,conv_id,msg_id];
    
	result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
    
}
#pragma mark 某条广播的某部门未读回复数量
-(int)getUnReadNumByDeptId:(NSString *)dept_id andMsgId:(int)msg_id
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where emp_id in (select emp_id from temp_employee where emp_dept_id in(select dept_id from temp_department where dept_id=%@ or dept_parent_dept = %@ or dept_parent_dept like '%%,%@,%%' or dept_parent_dept like '%%,%@' or dept_parent_dept like '%@,%%')) and send_msg_id = %d and read_flag=1",table_mass_conv_records,dept_id,dept_id,dept_id,dept_id,dept_id,msg_id];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
    
}

-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andMsgId:(int)msg_id
{

    NSString *sql = [NSString stringWithFormat:@"select * from temp_employee where emp_dept_id =%@ order by emp_status",dept_id];
	NSMutableArray *queryResult = [self querySql:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Emp *emp = [[Emp alloc]init];
            [self putDicData:dic toEmp:emp];
            emp.emp_dept=[dept_id intValue];
            emp.emp_level=level;
            emp.isSelected=isSelected;
            emp.unread=[self getUnReadNumByEmpId:emp.emp_id andMsgId:msg_id];
            [result addObject:emp];
            [emp release];
		}
		return result;
	}
	return nil;
}
-(void)putDicData:(NSDictionary*)dic toEmp:(Emp*)emp
{
	emp.emp_id = [[dic objectForKey:@"emp_id"] intValue];
	emp.emp_name = [dic objectForKey:@"emp_name"];
	emp.emp_sex = [[dic objectForKey:@"emp_sex"] intValue];
	emp.emp_status = [[dic objectForKey:@"emp_status"] intValue];
	emp.emp_mail = [dic objectForKey:@"emp_mail"];
	emp.emp_tel = [dic objectForKey:@"emp_tel"];
	emp.emp_mobile = [dic objectForKey:@"emp_mobile"];
	emp.emp_logo = [dic objectForKey:@"emp_logo"];
    emp.emp_hometel=[dic objectForKey:@"emp_hometel"];
    emp.emp_emergencytel=[dic objectForKey:@"emp_emergencytel"];
  	NSString * sInfoFlag = [dic objectForKey:@"emp_info_flag"];
	if([sInfoFlag compare:@"Y"] == NSOrderedSame)
	{
		emp.info_flag = true;
	}
	else
	{
		emp.info_flag = false;
	}
	emp.comp_id = [[dic objectForKey:@"emp_comp_id"] intValue];
	
	emp.titleName = [dic objectForKey:@"emp_title"];
	emp.empCode = [dic objectForKey:@"emp_code"];
	emp.signature = [dic objectForKey:@"emp_signature"];
	emp.loginType = [[dic objectForKey:@"emp_login_type"] intValue];
	
	//	如果员工name没有，那么显示员工工号
	if(emp.emp_name == nil || emp.emp_name.length == 0)
		emp.emp_name = emp.empCode;
}
#pragma mark 临时部门及人员
-(void)createTempDeptAndEmpByConvID:(NSString*)conv_id andMsgId:(int)msg_id
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ ",table_temp_department];
	[self operateSql:deletesql Database:_handle toResult:nil];
    deletesql = [NSString stringWithFormat:@"delete from %@ ",table_temp_employee];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
   //获取广播的每条消息的成员  三级正以下级别 并存temp_employee
    NSString *sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id in(select member_id from %@ where conv_id=%@ and member_type=0)",table_department,table_mass_conv_member,conv_id];
	
	NSMutableArray *result = [self querySql:sql];
    
    NSDictionary *dic;
    NSString *dept_list=nil;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		if (dept_list==nil) {
            dept_list=[dic objectForKey:@"sub_dept"];
        }else{
            dept_list=[NSString stringWithFormat:@"%@,%@",dept_list,[dic objectForKey:@"sub_dept"]];
        }
	}
    NSLog(@"dept_list----- %@",dept_list);
    sql = [NSString stringWithFormat:@"replace into temp_employee select e.* from employee e,emp_dept d where e.emp_id=d.emp_id and (d.rank_id>5 or d.rank_id =0) and ( d.dept_id in(%@) or d.emp_id in(select member_id from mass_conv_member where conv_id=%@ and member_type=1))",dept_list,conv_id];
    NSLog(@"---getEmpsEqAndBelowTreeRankByConvID--\n %@",sql);
    [self operateSql:sql Database:_handle toResult:nil];
    //新建临时 部门关系
    sql = [NSString stringWithFormat:@"select * from %@ where dept_id in(select dept_id from emp_dept  where (rank_id>5 or rank_id =0) and (dept_id in(%@) or emp_id in(select member_id from mass_conv_member where conv_id=%@ and member_type=1)))",table_department,dept_list,conv_id];
	NSMutableArray *queryResult = [self querySql:sql];
    NSLog(@"--sql--\n %@",sql);
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
            NSString *dept_parent_dept=[dic objectForKey:@"dept_parent_dept"];
            NSArray *array = [dept_parent_dept componentsSeparatedByString:@","];
            int count_num=[array count];
            NSString *dept_id= [NSString stringWithFormat:@"%d",[[dic objectForKey:@"dept_id"]intValue]];
//            int dept_emp_num=[self getTempDeptEmpNum:dept_id andRank:rank_list andBusiness:business_list andCity:city_list];
            NSString *dept_emp_num_str=@"0";//[NSString stringWithFormat:@"%d",dept_emp_num];
            NSDictionary *tempdic=[NSDictionary dictionaryWithObjectsAndKeys:dept_id,@"dept_id",dept_emp_num_str,@"emp_count",[dic objectForKey:@"dept_parent"],@"dept_parent",[dic objectForKey:@"dept_name"],@"dept_name",@"0",@"sub_dept",[dic objectForKey:@"dept_sort"],@"dept_sort",[dic objectForKey:@"dept_parent_dept"],@"dept_parent_dept", nil];
            [self addItemToTempDept:tempdic];
            for (int i=0; i<count_num; i++) {
                if (i+1<count_num) {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=[array objectAtIndex:i+1];
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
//                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
//                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=@"0";//[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }else
                {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=@"0";
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
//                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
//                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=@"0";//[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }
                
            }
            
		}
		
	}
	[pool release];

}
-(NSDictionary *)getDeptNameByID:(NSString *)dept_id
{
    NSString *sql = [NSString stringWithFormat:@"select dept_name,dept_sort from %@ where dept_id =%@ ",table_department,dept_id];
	NSMutableArray *queryResult = [self querySql:sql];
	int count = [queryResult count];
	if(count > 0)
	{
        NSDictionary *getdic= [queryResult objectAtIndex:0];
		
		return getdic;
	}
	return nil;
}
-(void)addItemToTempDept:(NSDictionary *)dic
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"dept_id",@"dept_parent",@"dept_name",@"dept_parent_dept",@"sub_dept",@"dept_sort",@"emp_count",nil];// sub_dept 1表示有子部门，其他表示没有
	NSString    *sql        =   nil;
    
    sql =   [self replaceIntoTable:table_temp_department newInfo:dic keys:keys];
    [self operateSql:sql Database:_handle toResult:nil];
    
}
#pragma mark 根据上级部门id，获取直接子部门，并定位级别
-(NSMutableArray *)getTempDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected andMsgId:(int)msg_id
{
	NSMutableArray *depts = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat: @"select * from %@ where dept_parent = '%@' order by dept_sort",table_temp_department,deptParent];
	NSMutableArray * result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
		//		[LogUtil debug:[NSString stringWithFormat:@"deptid is %@ child_dept is %@",deptParent , result]];
		for(int i = 0;i<[result count];i++)
		{
			Dept *dept = [[Dept alloc]init];
			NSDictionary *dic = [result objectAtIndex:i];
			NSString *dept_id = [dic objectForKey:@"dept_id"];
			dept.dept_id = [dept_id intValue];
			dept.dept_name = [dic objectForKey:@"dept_name"];
			dept.dept_parent = [deptParent intValue];
			dept.dept_level=level;
			dept.dept_emps = nil;
            dept.isChecked=isSelected;
            dept.totalNum=[self getUnReadNumByDeptId:dept_id andMsgId:msg_id];
            dept.subDeptsStr=[dic objectForKey:@"sub_dept"];
			[depts addObject:dept];
			[dept release];
		}
	}
	[pool release];
	return depts;
}
#pragma mark 级正以下级别 人数
-(int)getBelowThreeEmpNum
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ ",table_temp_employee];
    
	NSMutableArray *result = [self querySql:sql];
	if([result count] > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	return _count;
}
#pragma mark 获取广播的每条消息的成员  三级正以下级别
-(NSArray *)getEmpsEqAndBelowTreeRankByConvID:(NSString*)conv_id andMsgId:(int)msg_id
{
    NSMutableArray *emps = [NSMutableArray array];
    
	NSString *sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id in(select member_id from %@ where conv_id=%@ and member_type=0)",table_department,table_mass_conv_member,conv_id];
	
	NSMutableArray *result = [self querySql:sql];
    
    NSDictionary *dic;
    NSString *dept_list=nil;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		if (dept_list==nil) {
            dept_list=[dic objectForKey:@"sub_dept"];
        }else{
            dept_list=[NSString stringWithFormat:@"%@,%@",dept_list,[dic objectForKey:@"sub_dept"]];
        }
	}
    NSLog(@"dept_list----- %@",dept_list);
    
    sql = [NSString stringWithFormat:@"select * from(select distinct e.emp_id,e.* from employee e,emp_dept d where e.emp_id=d.emp_id and (d.rank_id>5 or d.rank_id =0) and ( d.dept_id in(%@) or d.emp_id in(select member_id from mass_conv_member where conv_id=%@ and member_type=1)) order by e.emp_pinyin)order by emp_status",dept_list,conv_id];
    NSLog(@"---getEmpsEqAndAboveTreeRankByConvID--\n %@",sql);
    result = [self querySql:sql];
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
        emp.unread=[self getUnReadNumByEmpId:emp.emp_id andMsgId:msg_id];
        [emps addObject:emp];
		[emp release];
    }
    
    
	return emps;
    
}
-(BOOL)isInTheSameDept
{
    BOOL isTheSame=NO;
    NSString *sql = [NSString stringWithFormat:@"select distinct emp_dept_id from temp_employee"];
    NSMutableArray *result = [self querySql:sql];
   if([result count]==1)isTheSame=YES;

    return isTheSame;
}
#pragma mark   三级正以下级别,已回复的
-(NSArray *)getEmpsEqAndBelowTreeRankByMsgId:(int)msg_id
{

    NSMutableArray *emps = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from ( select * from employee where emp_id in (select emp_id from emp_dept where emp_id in(select distinct emp_id  from mass_conv_records  where send_msg_id = %d ) and  (rank_id>5 or rank_id =0)) order by emp_pinyin) order by emp_status",msg_id];
    NSLog(@"---getEmpsEqAndAboveTreeRankByConvID--\n %@",sql);
    NSMutableArray *result = [self querySql:sql];
    NSDictionary *dic;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
        emp.unread=[self getUnReadNumByEmpId:emp.emp_id andMsgId:msg_id];
        [emps addObject:emp];
		[emp release];
    }
    
    
	return emps;
    
}
#pragma mark 获取广播的每条消息的成员  三级正及以上级别
-(NSArray *)getEmpsEqAndAboveTreeRankByConvID:(NSString*)conv_id andMsgId:(int)msg_id
{
    NSMutableArray *emps = [NSMutableArray array];
    
	NSString *sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id in(select member_id from %@ where conv_id=%@ and member_type=0)",table_department,table_mass_conv_member,conv_id];
	
	NSMutableArray *result = [self querySql:sql];
    
    NSDictionary *dic;
    NSString *dept_list=nil;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		if (dept_list==nil) {
            dept_list=[dic objectForKey:@"sub_dept"];
        }else{
            dept_list=[NSString stringWithFormat:@"%@,%@",dept_list,[dic objectForKey:@"sub_dept"]];
        }
	}
    NSLog(@"dept_list----- %@",dept_list);
    
   sql = [NSString stringWithFormat:@"select * from( select distinct e.emp_id,e.* from employee e,emp_dept d where e.emp_id=d.emp_id and (d.rank_id<=5 and d.rank_id>0) and ( d.dept_id in(%@) or d.emp_id in(select member_id from mass_conv_member where conv_id=%@ and member_type=1)) order by e.emp_pinyin)order by emp_status",dept_list,conv_id];
    NSLog(@"---getEmpsEqAndAboveTreeRankByConvID--\n %@",sql);
    result = [self querySql:sql];
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
        emp.unread=[self getUnReadNumByEmpId:emp.emp_id andMsgId:msg_id];
        [emps addObject:emp];
		[emp release];
    }

    
	return emps;


}
-(Emp *)getEmpByDicData:(NSDictionary *)dic
{
	Emp *emp = [[Emp alloc]init];
	emp.emp_id = [[dic objectForKey:@"emp_id"] intValue];
	emp.emp_name = [dic objectForKey:@"emp_name"];
	emp.emp_sex = [[dic objectForKey:@"emp_sex"] intValue];
	emp.emp_status = [[dic objectForKey:@"emp_status"] intValue];
	emp.emp_mail = [dic objectForKey:@"emp_mail"];
	emp.emp_tel = [dic objectForKey:@"emp_tel"];
	emp.emp_mobile = [dic objectForKey:@"emp_mobile"];
	emp.emp_logo = [dic objectForKey:@"emp_logo"];
    emp.emp_hometel=[dic objectForKey:@"emp_hometel"];
    emp.emp_emergencytel=[dic objectForKey:@"emp_emergencytel"];
  	NSString * sInfoFlag = [dic objectForKey:@"emp_info_flag"];
	if([sInfoFlag compare:@"Y"] == NSOrderedSame)
	{
		emp.info_flag = true;
	}
	else
	{
		emp.info_flag = false;
	}
	emp.comp_id = [[dic objectForKey:@"emp_comp_id"] intValue];
	
	emp.titleName = [dic objectForKey:@"emp_title"];
	emp.empCode = [dic objectForKey:@"emp_code"];
	emp.signature = [dic objectForKey:@"emp_signature"];
	emp.loginType = [[dic objectForKey:@"emp_login_type"] intValue];
	
	//	如果员工name没有，那么显示员工工号
	if(emp.emp_name == nil || emp.emp_name.length == 0)
		emp.emp_name = emp.empCode;
	
  	return emp ;
}

#pragma mark 更新最后输入信息
-(void)updateLastInputMsgByConvId:(NSString *)conv_id LastInputMsg:(NSString *)lastInputMsg
{
    //	修改收到的消息的状态为已读
    NSString *sql  = [NSString stringWithFormat:@"update %@ set lastmsg_body = ? where conv_id='%@'",table_mass_conversation,conv_id];
	
	sqlite3_stmt *stmt = nil;
	
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
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	
	sqlite3_bind_text(stmt, 1, [lastInputMsg UTF8String],-1,NULL);
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
#pragma mark 更新最后输入信息时间
-(void)updateLastInputMsgTimeByConvId:(NSString *)conv_id nowTime:(NSString *)nowTime
{
    //	修改收到的消息的状态为已读
    NSString *sql  = [NSString stringWithFormat:@"update %@ set last_msg_time= ? where conv_id='%@'",table_mass_conversation,conv_id];
	
	sqlite3_stmt *stmt = nil;
	
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
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	
	sqlite3_bind_text(stmt, 1, [nowTime UTF8String],-1,NULL);
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

#pragma mark 根据会话id删除其对应的会话成员
-(void)deleteMassMemberBy:(NSString*)convId
{
	//	如果是多人会话，需要删除会话人员
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_mass_conv_member,convId];
	
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark   清除会话记录
-(void)deleteConvRecordBy:(NSString*)convId
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@'",table_mass_conv_records,convId];
	NSMutableArray *result = [self querySql:sql];
	for(NSDictionary *dic in result)
	{
		[self deleteMsgFile:dic];
	}
	
	sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_mass_conv_records,convId];
	[self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"update %@ set last_msg_body = NULL where  conv_id=%@",table_mass_conversation,convId];
	[self operateSql:sql Database:_handle toResult:nil];
	
}

#pragma mark  清除会话记录的同时，清除会话本身
-(void)deleteConvAndConvRecordsBy:(NSString*)convId
{
	//	删除聊天记录对应的文件
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@'",table_mass_conv_records,convId];
	NSMutableArray *result = [self querySql:sql];
	for(NSDictionary *dic in result)
	{
		[self deleteMsgFile:dic];
	}
	
	//	删除会话对应的记录
	sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_mass_conv_records,convId];
	[self operateSql:sql Database:_handle toResult:nil];
	
	//    删除会话
    sql = [NSString stringWithFormat:@"delete from %@ where  conv_id=%@",table_mass_conversation,convId];
	[self operateSql:sql Database:_handle toResult:nil];
	
//	删除会话成员
	[self deleteMassMemberBy:convId];
	
}

#pragma mark 删除某一条聊天记录
-(void)deleteOneMsg:(NSString *)msgid
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where id='%@'",table_mass_conv_records,msgid];
	//     [LogUtil debug:[NSString stringWithFormat:@"sql--deleteOneMsg  %@",sql);
	NSMutableArray *result = [self querySql:sql];
	for(NSDictionary *dic in result)
	{
		[self deleteMsgFile:dic];
	}
    
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ where id = '%@' ",table_mass_conv_records,msgid];
	[self operateSql:deletesql Database:_handle toResult:nil];
}

#pragma mark add by shisp 删除和消息相关的文件
-(void)deleteMsgFile:(NSDictionary *)dic
{
	eCloudDAO *db = [eCloudDAO getDatabase];
	[db deleteMsgFile:dic];
}


#pragma remark 合并一呼万应的消息，如果收到的消息超过了 72小时，那么合并到单聊会话
- (BOOL)mergeMassMessageToSingleConv:(Conversation *)conv
{
    NSString *convId = conv.conv_id;
    
    conn *_conn = [conn getConn];
    eCloudDAO *db = [eCloudDAO getDatabase];
    
    NSDictionary *dic;
    NSString *sql;
    NSMutableArray *result;
    
    BOOL *needMerge = NO;
    
    NSRange range = [convId rangeOfString:@"|"];
    NSString *senderEmpId = [convId substringFromIndex:(range.location + 1)];
    NSString *srcMassMsgId = [convId substringToIndex:range.location];
//    NSLog(@"senderEmpId is %@,srcMassMsgId is %@",senderEmpId,srcMassMsgId);
    
    sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and emp_id = %@",table_conv_records,convId,senderEmpId];

    result = [self querySql:sql];
    
//    NSLog(@"%@",[result description]);
    
    if(result.count > 0)
    {
        dic = [result objectAtIndex:0];
        
        int msgTime = [[dic valueForKey:@"msg_time"] intValue];
        int nowTime = [_conn getCurrentTime];
        int interval = nowTime - msgTime;
        
        if(interval > MASS_MSG_MERGE_TIME)
        {
            NSLog(@"间隔超过了，开始合并");
            needMerge = YES;
        }
    }
    else
    {
        NSLog(@"没有找到消息，进行合并");
        needMerge = YES;
    }
    
    if(needMerge)
    {
        sql = [NSString stringWithFormat:@"update %@ set conv_id = '%@' where conv_id = '%@'",table_conv_records,senderEmpId,convId];
        [self operateSql:sql Database:_handle toResult:nil];
        
        sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_conversation,convId];
        [self operateSql:sql Database:_handle toResult:nil];

        dic = [db searchConversationBy:senderEmpId];
        if(dic == nil)
        {
            NSLog(@"还没有单聊会话，需要创建单聊会话");
            NSString *convType = [StringUtil getStringValue:singleType];
            NSString *recvFlag = [StringUtil getStringValue:open_msg];
            
            dic = [NSDictionary dictionaryWithObjectsAndKeys:senderEmpId,@"conv_id",convType,@"conv_type",conv.emp.emp_name,@"conv_title",recvFlag,@"recv_flag",
                   senderEmpId,@"create_emp_id",[_conn getSCurrentTime],@"create_time", nil];
            
            [db addConversation:[NSArray arrayWithObject:dic]];
        }
        
        int state;
        sqlite3_stmt *stmt = nil;

//        找到最近的消息，更新最后一条消息
        dic = [db getConvMsgTime:senderEmpId andType:1];
        
//        NSLog(@"last msg is %@",[dic description]);
        
        sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ?,display_flag = 0 where conv_id =? "
               ,table_conversation];
        
        //		编译
        pthread_mutex_lock(&add_mutex);
        state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
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
            sqlite3_bind_int(stmt, 1,[[dic valueForKey:@"id"]intValue]);
            
            if([[dic valueForKey:@"msg_type"] intValue] == type_long_msg || [[dic valueForKey:@"msg_type"] intValue] == type_file)
            {
                sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//last_msg_body
            }
            else
            {
                sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"msg_body"] UTF8String],-1,NULL);//last_msg_body
            }
            sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
            sqlite3_bind_int(stmt, 4, [[dic valueForKey:@"emp_id"] intValue]);//last_emp_id
            sqlite3_bind_int(stmt, 5, [[dic valueForKey:@"msg_type"] intValue]);//last_msg_type
            sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
            
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
    
    return needMerge;
}


#pragma mark  根据会话id，查询会话记录里面的图片记录，按照时间排序，最近的要排在前面
-(NSArray *)getPicConvRecordBy:(NSString *)convId{
    NSMutableArray *records = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and msg_type = %d order by msg_time",table_mass_conv_records,convId,type_pic];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [[ConvRecord alloc]init];
		[self putData:dic toConvRecord:record];
		[records addObject:record];
		[record release];
	}
	[pool release];
	return records;
}
@end
