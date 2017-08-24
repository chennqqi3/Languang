//
//  eCloudConv.m
//  eCloud
//
//  Created by Richard on 13-9-27.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ConvDAO.h"
#import "UserDisplayUtil.h"
#import "VirtualGroupDAO.h"
#import "BroadcastUtil.h"
#import "MiLiaoUtilArc.h"

#ifdef _GOME_FLAG_
#import "GOMEMailDefine.h"
#endif

#ifdef _HUAXIA_FLAG_
#import "HXConvDefine.h"
#endif

#import "APPListModel.h"
#import "ServiceModel.h"

#import "APPConn.h"

#import "JSONKit.h"

#import "RemindModel.h"

#import "UserDataDAO.h"

#import "UIAdapterUtil.h"

#import "OpenNotificationDefine.h"

#import "eCloudDefine.h"
#import "conn.h"

#import "VirGroupObj.h"
#import "OffenGroup.h"
#import "helperObject.h"
#import "Conversation.h"

#import "ApplicationManager.h"

#import "LocationMsgUtil.h"
#import "ConvNotification.h"
#import "ReceiptDAO.h"
#import "PublicServiceDAO.h"
#import "talkSessionUtil.h"
#import "MassDAO.h"
#import "RobotDAO.h"
#import "APPPlatformDOA.h"
#import "StringUtil.h"
#import "AppDelegate.h"

#import "NotificationUtil.h"
#import "ImageUtil.h"

#import "EmpLogoConn.h"
#import "FileAssistantDOA.h"

#import "MsgConn.h"
#import "broadcastListViewController.h"

#import "MsgNotice.h"

#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"
#import "FileAssistantRecordSql.h"
#import "FileAssistantRecordDOA.h"
#import "TextMsgExtDefine.h"

typedef enum
{
    delete_type_one_msg = 0,
    delete_type_one_conv,
    delete_type_all_conv
}delete_type_def;

#define KEY_DELETE_TYPE @"delete_type"

@implementation ConvDAO

#pragma mark ----会话表----
#pragma mark 查看某个群组是否屏蔽了群组消息，如果屏蔽了返回YES
-(BOOL)getRcvMsgFlagOfConvByConvId:(NSString*)convId
{
    NSString *sql = [NSString stringWithFormat:@"select recv_flag from %@ where conv_id = '%@'",table_conversation,convId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        int rcvMsgFlag = [[[result objectAtIndex:0]valueForKey:@"recv_flag"]intValue];
        if(rcvMsgFlag == 1)
        {
            return YES;
        }
    }
    return NO;
}
#pragma mark 设置群组是否屏蔽群组消息
-(void)updateRcvMsgFlagOfConvByConvId:(NSString*)convId andRcvMsgFlag:(int)rcvMsgFlag
{
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set recv_flag = %d where conv_id = '%@'",table_conversation,rcvMsgFlag,convId];
		[self operateSql:sql Database:_handle toResult:nil];

        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[StringUtil getStringValue:rcvMsgFlag],@"rcv_msg_flag" ,nil];
        [self sendNewConvNotification:dic andCmdType:update_rcv_msg_flag];
	}
}

#pragma mark  根据会话id，查询会话表，返回会话信息
-(NSDictionary *)searchConversationBy:(NSString*)convId
{
	NSDictionary * dic=nil;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id='%@' ",table_conversation,convId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
    if (result!=nil&&[result count]==1) {
		dic = [[NSDictionary alloc]initWithDictionary:[result objectAtIndex:0]];
    }
	[pool release];
	
	if(dic)
		return [dic autorelease];
	return nil;
}
#pragma mark 增加会话
-(void)addConversation:(NSArray *) info
{
	for (NSDictionary *dic in info)
	{
        int convType = [dic[@"conv_type"]intValue];
        
#ifdef _HUAXIA_FLAG_
//        有几个特殊的账号，不用保存来自这几个账号的消息，也不用创建和这几个账号的单聊会话
        NSString *convId = dic[@"conv_id"];
        if (convType == singleType) {
            for (NSNumber *empId in not_save_msg_user_array) {
                if (empId.intValue == [convId intValue]) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s emp id is %d 不用创建此单聊",__FUNCTION__,empId.intValue]];
                    return;
                }
            }
        }
#endif
        
		NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,conv_type,conv_title,conv_remark,recv_flag,create_emp_id,create_time,last_msg_id,last_msg_time) values(?,?,?,?,?,?,?,?,?)",table_conversation];
		
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
		sqlite3_bind_int(stmt, 2, [[dic valueForKey:@"conv_type"] intValue]);//conv_type
		sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"conv_title"] UTF8String],-1,NULL);//conv_title
		sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"conv_remark"] UTF8String],-1,NULL);//conv_remark
		sqlite3_bind_int(stmt, 5, [[dic valueForKey:@"recv_flag"]intValue]);//recv_flag
        
        if (convType == mutiableType) {
            //                龙湖要求修改回来，默认还是提醒

//            if ( [UIAdapterUtil isHongHuApp]) {
//                NSNumber *groupType = [dic valueForKey:@"group_type"];
//                if (groupType == nil || groupType.intValue != system_group_type) {
//                    [LogUtil debug:[NSString stringWithFormat:@"%s 龙湖要求新创建的普通讨论组群组默认为关闭新消息提醒",__FUNCTION__]];
//                    sqlite3_bind_int(stmt, 5, shield_msg);//recv_flag
//                    [[conn getConn] setRcvFlagOfConv:[dic valueForKey:@"conv_id"] andRcvMsgFlag:shield_msg];
//                }
//            }
        }
		sqlite3_bind_int(stmt, 6, [[dic valueForKey:@"create_emp_id"]intValue]);//create_emp_id
		sqlite3_bind_text(stmt, 7, [[dic valueForKey:@"create_time"]UTF8String],-1,NULL);//create_time
		sqlite3_bind_int(stmt, 8, [[dic valueForKey:@"last_msg_id"]intValue]);//last_msg_id
		sqlite3_bind_text(stmt, 9, [[dic valueForKey:@"create_time"]UTF8String],-1,NULL);//last_msg_time 和 create_time 一致
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
//如果是单聊，那么也在会话成员表中增加一个成员记录
		if([[dic valueForKey:@"conv_type"] intValue] == singleType)
		{
            NSMutableArray *tempArray = [NSMutableArray array];
            /** 如果是密聊，密聊会话id有所不同，所以增加人员时不能直接使用 */
            if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:[dic valueForKey:@"conv_id"]]) {
                dic = [NSDictionary dictionaryWithObjectsAndKeys:[dic valueForKey:@"conv_id"],@"conv_id",[[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:[dic valueForKey:@"conv_id"]],@"emp_id", nil];
            }else{
                dic = [NSDictionary dictionaryWithObjectsAndKeys:[dic valueForKey:@"conv_id"],@"conv_id",[dic valueForKey:@"conv_id"],@"emp_id", nil];
            }
			[tempArray addObject:dic];
			[self addConvEmp:tempArray];
		}
        
        if ([[dic valueForKey:@"conv_type"]intValue] == mutiableType) {
            //            如果是南航版本，那么用户自己创建的群，默认为常用讨论组
            if ([UIAdapterUtil isCsairApp]) {
                int createUserId = [[dic valueForKey:@"create_emp_id"]intValue];
                if ([conn getConn].userId.intValue == createUserId) {
                    [[UserDataDAO getDatabase]addOneCommonGroup:[dic valueForKey:@"conv_id"]];
                }
            }
        }
//
//        if ([UIAdapterUtil isHongHuApp]) {
//            [LogUtil debug:[NSString stringWithFormat:@"%s 龙湖要求默认讨论组默认为新消息不提醒",__FUNCTION__]];
////              
////            [_conn setRcvFlagOfConv:self.convId andRcvMsgFlag:_switch.isOn?0:1]
//        }
        
//        [self sendNewConvNotification:dic andCmdType:add_new_conversation];
	}
}

#pragma mark 修改会话，获取到群组消息后，保存会话标题，会话创建人，创建时间
-(void)updateConversation:(NSString*)convId andValues:(NSDictionary *)dic
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set conv_title = ? ,create_emp_id = ?,create_time = ? where conv_id = '%@'",table_conversation,convId];
	
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
	
	sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"conv_title"] UTF8String],-1,NULL);
	sqlite3_bind_int(stmt, 2, [[dic valueForKey:@"create_emp_id"] intValue]);
	sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"create_time"] UTF8String],-1,NULL);
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
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [mDic setObject:convId forKey:@"conv_id"];
    [self sendNewConvNotification:mDic andCmdType:update_conversaion_info];
}

#pragma mark 展示最近的会话，不包括公众号（显示在会话列表的，没有显示在会话列表的）,用来转发消息
- (NSArray *)getRecentConvForTransMsg
{
    NSString *sql = [NSString stringWithFormat:@"select *, 'Y' as display_merge_logo  from %@ where display_flag = 0 and (conv_type = %d or conv_type = %d) order by last_msg_time desc limit (%d)",table_conversation,singleType,mutiableType,forward_max_recent_conv_count];

#ifdef _LANGUANG_FLAG_
    sql = [NSString stringWithFormat:@"select *, 'Y' as display_merge_logo  from %@ where display_flag = 0 and (conv_type = %d or conv_type = %d) and conv_id not like '%@%%' order by last_msg_time desc limit (%d)",table_conversation,singleType,mutiableType,MILIAO_PRE,forward_max_recent_conv_count];
#endif

    NSMutableArray *result = [self querySql:sql];
    
    if(result.count > 0)
    {
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:result.count];
        
        for(NSDictionary *dic in result)
        {
            Conversation *conv = [self getConversationByDicData:dic];
            conv.recordType = normal_conv_type;
            [mArray addObject:conv];
            
            if (conv.conv_type == mutiableType)
            {
                conv.totalEmpCount = [self getAllConvEmpNumByConvId:conv.conv_id];;
            }
        }
        return mArray;
    }
    return nil;
}


#pragma mark 展示最近会话：联系人界面调用，按照最后一条会话的时间排序，最近的要排在前面
//update by shisp 展示最近会话
-(NSArray *)getRecentConversation:(int)type
{
	NSMutableArray *_result = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql;
//	if(type == flt_group_type)
//	{
//        //        查看是否有过期的机组群，如果有则删除
//        //        [[PublicServiceDAO getDatabase]deleteNotValidFltGroup];
//
//		sql = [NSString stringWithFormat:@"select * from %@ where substr(conv_id,1,1) = 'g' and display_flag = 0 order by last_msg_time desc limit %d ",table_conversation,max_recent_conv_count];
//	}
//	else
//	{
//        update by shisp 先去查询下是否有需要合并的一呼万应消息，如果有，则进行合并
//        sql = [NSString stringWithFormat:@"select * from %@ where conv_type = %d",table_conversation,rcvMassType];
//        NSMutableArray *tempArray = [self querySql:sql];
//        if(tempArray.count == 0)
//        {
////            NSLog(@"没有一呼万应消息");
//        }
//        else
//        {
//            MassDAO *massDAO = [MassDAO getDatabase];
//            for(NSDictionary *dic in tempArray)
//            {
//                Conversation *conv = [self getConversationByDicData:dic];
//                [massDAO mergeMassMessageToSingleConv:conv];
//            }
//       }
    
//        substr(conv_id,1,1) <> 'g' and
//    在sql语句里增加一个常量，就是不显示合成图
    
//	}
    
#ifdef _LANGUANG_FLAG_
    if (type == normal_conv_type) {
        /** 查询最近的非密聊会话 */
        
        sql = [NSString stringWithFormat:@"select *,'N' as display_merge_logo from %@ where display_flag = 0 and conv_id not like '%@%%' and conv_id not like '%@%%' order by last_msg_time desc limit %d ",table_conversation,MILIAO_PRE,APPROVAL_PRE,max_recent_conv_count];
        
    }else if (type == miliao_conv_type){
        /** 查询所有密聊会话 */
        sql = [NSString stringWithFormat:@"select *,'N' as display_merge_logo from %@ where display_flag = 0 and conv_id like '%@%%' order by last_msg_time desc",table_conversation,MILIAO_PRE];
    }
    
#else
    sql = [NSString stringWithFormat:@"select *,'N' as display_merge_logo from %@ where display_flag = 0 order by last_msg_time desc limit %d ",table_conversation,max_recent_conv_count];
    
#endif

    
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	if(result &&[result count]>0)
	{
		[_result addObjectsFromArray:[self getConvListByResult:result]];
	}
	[pool release];
	return _result;
}

#pragma mark 根据用户输入的内容，查询会话的标题和会话参与人，找到符合条件的会话记录，显示在会话列表 目前转发时选择联系人界面 查询使用到了此方法
-(NSArray *)getConversationBy:(NSString *)searchStr
{
	NSMutableArray *convIdArray = [NSMutableArray array];
	
//	查询会话表，找到会话标题中包含输入内容的会话记录
    NSString * sql = [NSString stringWithFormat:@"select distinct(conv_id) from %@ where conv_title like ? ",table_conversation];

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
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string

	NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
	if(result.count > 0)
	{
//		NSLog(@"sql is %@",sql);
		for(NSDictionary *dic in result)
		{
//			NSLog(@"%s,%@",__FUNCTION__,[dic valueForKey:@"conv_id"]);
			[convIdArray addObject:[dic valueForKey:@"conv_id"]];
		}
	}
	
//	根据输入内容查找用户表
	NSArray *empArray = [self searchUserBy:searchStr];
	if(empArray.count > 0)
	{
        Emp *emp = [empArray objectAtIndex:0];
		NSMutableString *mStr = [NSMutableString stringWithString:[StringUtil getStringValue:emp.emp_id]];
		for(int i = 1;i<empArray.count;i++)
		{
            emp = [empArray objectAtIndex:i];
			[mStr appendFormat:@","];
			[mStr appendFormat:[StringUtil getStringValue:emp.emp_id]];
		}
	
		sql = [NSString stringWithFormat:@"select distinct(conv_id) from %@ where emp_id in (%@)",table_conv_emp,mStr];
		
//		NSLog(@"%s,sql is %@",__FUNCTION__,sql);
		
		result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		
		for(NSDictionary *dic in result)
		{
//			NSLog(@"%s,%@",__FUNCTION__,[dic valueForKey:@"conv_id"]);
			[convIdArray addObject:[dic valueForKey:@"conv_id"]];
		}
	}

	if(convIdArray.count > 0)
	{
		NSMutableString *mStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"'%@'",[convIdArray objectAtIndex:0]]];
		for(int i = 1;i<convIdArray.count;i++)
		{
			[mStr appendString:@","];
			[mStr appendString:[NSString stringWithFormat:@"'%@'",[convIdArray objectAtIndex:i]]];
		}
		sql = [NSString stringWithFormat:@"select *,'Y' as display_merge_logo from %@ where conv_id in (%@)  order by last_msg_time desc",table_conversation,mStr];
//		NSLog(@"%s,sql is %@",__FUNCTION__,sql);
		
		result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		
		if(result &&[result count]>0)
		{
            NSArray *convArray = [self getConvListByResult:result];
//            增加获取人数
            for (Conversation *conv in convArray) {
                if (conv.conv_type == mutiableType) {
                    conv.totalEmpCount = [self getAllConvEmpNumByConvId:conv.conv_id];
                }
            }
            return convArray;
		}
	}
	
	return nil;
}

#pragma mark 查询所有会话的个数
-(int)getAllConvCount
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@",table_conversation];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}

#pragma mark 查询某一页的会话记录
//-(NSArray *)getConvsOfPage:(int)curPage
//{
//	NSMutableArray *_result = [NSMutableArray array];
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//	int offset = 0;
//	if(curPage > 1)
//	{
//		offset = (curPage -1) * perpage_conv;
//	}
//	NSString * sql = [NSString stringWithFormat:@"select * from %@ order by last_msg_time desc limit %d offset %d",table_conversation,perpage_conv,offset];
//	NSMutableArray *result = [NSMutableArray array];
//	[self operateSql:sql Database:_handle toResult:result];
//	if([result count]>0)
//	{
//		[_result addObjectsFromArray:[self getConvListByResult:result]];
//	}
//	[pool release];
//	return _result;
//}

-(NSArray *)getConvsOfPage:(int)curPage andAllPageNum:(int)totalPage 
{
    NSMutableArray *_result = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    int offset = 0;
    
    offset = (totalPage - curPage) * perpage_conv;
    
    NSString * sql = [NSString stringWithFormat:@"select *,'Y' as display_merge_logo from %@ order by last_msg_time desc limit %d offset %d",table_conversation,perpage_conv,offset];
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if([result count]>0)
    {
        [_result addObjectsFromArray:[self getConvListByResult:result]];
    }
    [pool release];
    return _result;
}

#pragma mark 查询历史会话记录
-(NSArray *)searchChatRecordByConvName:(NSString *)convName
{
    NSMutableArray *_result = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select *,'Y' as display_merge_logo from %@ where conv_title like ? order by last_msg_time desc",table_conversation];
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
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",convName] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);

    if([result count]>0)
    {
        [_result addObjectsFromArray:[self getConvListByResult:result]];
    }
    return _result;
}

#pragma mark 删除所有会话记录
-(void)deleteAllConversation
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_type <> type_text",table_conv_records];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
    
	for(NSMutableDictionary *dic in result)
	{
        [dic setValue:[NSNumber numberWithInt:delete_type_all_conv] forKey:KEY_DELETE_TYPE];
        [self deleteMsgFile:dic];
	}
    
	//删除显示在会话列表的应用推送消息
    sql = [NSString stringWithFormat:@"select * from %@ where conv_type = '%d'",table_conversation,appInConvType];
    [self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        NSString *appid = [dic objectForKey:@"conv_id"];
		[[APPPlatformDOA getDatabase] deleteAPPPushByAppid:appid];
	}
    
	//	删除所有的会话记录
	sql = [NSString stringWithFormat:@"delete from %@",table_conv_records];
	[self operateSql:sql Database:_handle toResult:nil];

//    删除所有普通的群组
    sql = [NSString stringWithFormat:@"delete from %@ where group_type = %d",table_conversation,normal_group_type];
    [self operateSql:sql Database:_handle toResult:nil];
    
//    修改固定群组和自定义群组为不显示
    sql = [NSString stringWithFormat:@"update %@ set display_flag = %d where group_type = %d or group_type = %d",table_conversation,1,system_group_type,common_group_type];
    
    [self operateSql:sql Database:_handle toResult:nil];
    
//    
//    sql = [NSString stringWithFormat:@"select conv_id,conv_type,group_type from %@",table_conversation];
//    result = [self querySql:sql];
//    for (NSDictionary *_dic in result) {
//        NSString *convId = [_dic valueForKey:@"conv_id"];
//        int convType = [[_dic valueForKey:@"conv_type"]intValue];
//        int groupType = [[_dic valueForKey:@"group_type"]intValue];
//        if ((convType == mutiableType) && (groupType == system_group_type || groupType == common_group_type)) {
////            固定组或自定义组 不能物理删除，设置为不在会话列表显示
//            [self updateDisplayFlag:convId andFlag:1];
//        }
//        else
//        {
//            sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@'",table_conv_emp,convId];
//            [self operateSql:sql Database:_handle toResult:nil];
//            
//            sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@'",table_conversation,convId];
//            [self operateSql:sql Database:_handle toResult:nil];
//        }
//    }
    
    
    //更新Tabar提示
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_PUSH_REFRESH_NOTIFICATION object:nil];
    
    [self sendNewConvNotification:nil andCmdType:delete_all_conversation];
}

#pragma mark 修改会话信息 type:0 会话名称 1 会话备注
-(void)updateConvInfo:(NSString*)convId andType:(int)type andNewValue:(NSString*)newValue
{
	NSString *sql;
	if(type == 0)
	{
		sql = [NSString stringWithFormat:@"update %@ set conv_title = ? where conv_id='%@' ",table_conversation,convId];
	}
	else {
		sql = [NSString stringWithFormat:@"update %@ set conv_remark = ? where conv_id='%@' ",table_conversation,convId];
	}
	
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
	
	sqlite3_bind_text(stmt, 1, [newValue UTF8String],-1,NULL);
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
    
    if (type == 0) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",newValue,@"conv_title", nil];
        [self sendNewConvNotification:dic andCmdType:update_conv_title];
    }
}

#pragma mark 获取create_emp_id
-(int)getConvCreateEmpIdByConvId:(NSString*)convId
{
    NSString *sql;
    sql = [NSString stringWithFormat:@"select create_emp_id from %@ where conv_id='%@'",table_conversation,convId];
    NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		return [[[result objectAtIndex:0]objectForKey:@"create_emp_id"] intValue];
	}
    return 0;
}

#pragma mark --会话人员表---

#pragma mark  增加会话人员 如果增加成功那么就保存在一个Dictionary里
-(NSDictionary*)addConvEmp:(NSArray *) info
{
//    群人数增加，修改为采用事务方式入库群组成员
    conn *_conn = [conn getConn];
    int start = [_conn getCurrentTime];
    
	NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
	
	NSArray *keys           =   [NSArray arrayWithObjects:@"conv_id",@"emp_id", nil];
	
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:info.count];
//    NSMutableArray *empIdArray = [NSMutableArray arrayWithCapacity:info.count];
    NSString    *sql        =   nil;
    
    NSString *convId;
    NSString *empIdStr;
    
    NSMutableArray *result;
    
    int isValid;
    
	for (NSDictionary *dic in info)
	{
        convId = [dic valueForKey:@"conv_id"];
        empIdStr = [dic valueForKey:@"emp_id"];
  
        sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and emp_id = %@",table_conv_emp,convId,empIdStr];
        
        result = [self querySql:sql];
        
        if (result.count == 0)
        {
//        insert
            [_dic setValue:@"1" forKey:empIdStr];
            
            sql = [NSString stringWithFormat:@"insert into %@(conv_id,emp_id) values('%@',%@)",table_conv_emp,convId,empIdStr];
            [sqlArray addObject:sql];
        }
        else
        {
            isValid = [[[result objectAtIndex:0]valueForKey:@"is_valid"]intValue];
            if (isValid == 0)
            {
//                已经存在，不用处理
            }
            else
            {
//                修改
                [_dic setValue:@"1" forKey:empIdStr];
                sql = [NSString stringWithFormat:@"update %@ set is_valid = 0 where conv_id = '%@' and emp_id = %@",table_conv_emp,convId,empIdStr];
                [sqlArray addObject:sql];
            }
        }
 	}
    
    if([self beginTransaction])
    {
        for(int i = 0;i<sqlArray.count;i++)
        {
            sql = [sqlArray objectAtIndex:i];
            char *errorMessage;
            
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
            pthread_mutex_unlock(&add_mutex);
        }
        [self commitTransaction];
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s 增加群组成员时开启事务失败，单个执行",__FUNCTION__]];
        for(int i = 0;i<sqlArray.count;i++)
        {
            sql = [sqlArray objectAtIndex:i];
            [self operateSql:sql Database:_handle toResult:nil];
        }
    }
    int end = [_conn getCurrentTime];
//    NSLog(@"end - start is %d",end - start);
	return _dic;
}

#pragma mark  删除一个会话人员
-(void)deleteConvEmp:(NSArray *)info
{
	NSString *convId;
	NSString *empId;
	NSString *sql;
	for(NSDictionary *dic in info)
	{
		convId = [dic objectForKey:@"conv_id"];
		empId = [dic objectForKey:@"emp_id"];
        sql = [NSString stringWithFormat:@"update %@ set is_valid = 1 where conv_id = '%@' and emp_id = %@ ",table_conv_emp,convId,empId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

-(int)getAllConvEmpNumByConvId:(NSString *)convId
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select count(distinct(a.emp_id)) as _count from %@ a,%@ b,%@ c where b.conv_id = '%@' and b.is_valid = 0 and b.emp_id = a.emp_id and c.dept_id > 0 and a.emp_id = c.emp_id",table_employee,table_conv_emp,table_emp_dept,convId];

	// [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	[pool release];
	return _count;
}
#pragma mark 查询某个会话的会话人员
-(NSArray*)getAllConvEmpBy:(NSString *)convId
{
//    先按照状态，再按照level，再按照账号进行排序
    
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//,c.emp_sort 如果emp_sort的值不同，那么即使是在不同部门的两个相同用户，也不会过滤掉，所以不获取emp_sort.
//    目前搞不清楚，如果不获取emp_sort，那么是否可以按照emp_sort排序呢？
	NSString *sql = [NSString stringWithFormat:@"select distinct(a.emp_id),a.* ,b.is_admin,b.rcv_msg_flag from %@ a,%@ b ,%@ c where b.conv_id = '%@' and b.is_valid = 0  and b.emp_id = a.emp_id and c.dept_id > 0 and a.emp_id = c.emp_id order by c.emp_sort desc,a.emp_code",table_employee,table_conv_emp,table_emp_dept,convId];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        sql = [NSString stringWithFormat:@"select distinct(a.emp_id),a.* ,b.is_admin,b.rcv_msg_flag from %@ a,%@ b ,%@ c where b.conv_id = '%@' and b.is_valid = 0  and b.emp_id = a.emp_id and c.dept_id > 0 and a.emp_id = c.emp_id order by a.emp_code",table_employee,table_conv_emp,table_emp_dept,convId];
#endif
    
    NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
    
	NSMutableArray *empsPCOnline = [NSMutableArray array];
    
    NSMutableArray *empsPCLeave = [NSMutableArray array];
    
    NSMutableArray *empsMobileOnline = [NSMutableArray array];
    
    NSMutableArray *empsOffline= [NSMutableArray array];

	//	查询在线的和离开的
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
        
        //    获取是否管理员，是否设置了屏蔽消息
        emp.isAdmin = NO;
        int isAdmin = [[dic valueForKey:@"is_admin"]intValue];
        if (isAdmin == 1) {
            emp.isAdmin = YES;
        }
        emp.isNotRcvMsg = NO;
        int rcvMsgFlag = [[dic valueForKey:@"rcv_msg_flag"]intValue];
        if (rcvMsgFlag == 1) {
            emp.isNotRcvMsg = YES;
        }
        
        if (emp.emp_status == status_online)
        {
            if (emp.loginType == TERMINAL_PC)
            {
                [empsPCOnline addObject:emp];
            }
            else
            {
                [empsMobileOnline addObject:emp];
            }
        }
        else if (emp.emp_status==status_leave)
        {
            [empsPCLeave addObject:emp];
        }
        else
        {
            [empsOffline addObject:emp];
        }
        
		[emp release];
	}
    
    [emps addObjectsFromArray:empsPCOnline];
    [emps addObjectsFromArray:empsPCLeave];
    [emps addObjectsFromArray:empsMobileOnline];
    [emps addObjectsFromArray:empsOffline];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
//        创建人占第一个
    int createEmpId = [self getConvCreateEmpIdByConvId:convId];
    for (Emp *_emp in emps) {
        if (_emp.emp_id == createEmpId) {
            [emps removeObject:_emp];
            Emp *createEmp = [self getEmployeeById:[StringUtil getStringValue:createEmpId]];
            [emps insertObject:createEmp atIndex:0];
            break;
        }
    }
#endif
    
    return emps;
}

// 查询某个会话的需要显示在会话列表群组头像里的人员
-(NSArray*)getGroupLogoEmpArrayBy:(NSString *)convId
{
    NSMutableArray *emps = [NSMutableArray array];
    
//    取出所有的，谁有头像就优先显示
//    现在修改为只取前4个
//limit(4)
	NSString *sql = [NSString stringWithFormat:@"select distinct(b.emp_id),b.emp_logo,b.emp_sex from %@ a , %@ b , %@ c where a.conv_id = '%@' and a.is_valid = 0 and a.emp_id = b.emp_id and a.emp_id = c.emp_id and c.dept_id > 0 order by c.emp_sort desc,b.emp_code ",table_conv_emp,table_employee,table_emp_dept,convId];
    
	NSMutableArray *result = [self querySql:sql];
    
    for (NSDictionary *_dic in result)
    {
        Emp *_emp = [[Emp alloc]init];
        _emp.emp_id = [[_dic valueForKey:@"emp_id"]intValue];
        _emp.emp_logo = [_dic valueForKey:@"emp_logo"];
        _emp.emp_sex = [[_dic valueForKey:@"emp_sex"]intValue];
        [emps addObject:_emp];
        [_emp release];
    }
    
    
    NSMutableArray *logoEmpArray = [NSMutableArray array];
    
    //            有头像的emp
    NSMutableArray *hasLogoEmpArray = [NSMutableArray array];
    //            没有头像的emp
    NSMutableArray *noLogoEmpArray = [NSMutableArray array];
    
    int index = 0;
    for (Emp *_emp in emps)
    {
        UIImage *image = [ImageUtil getEmpLogoWithoutDownload:_emp];
        if (image)
        {
            _emp.logoImage = image;
            _emp.isUserLogo = YES;
            
            [hasLogoEmpArray addObject:_emp];
            //                    如果有头像的emp已经等于或大于4，则退出循环
            if (hasLogoEmpArray.count >= 4)
            {
                //                NSLog(@"有头像的emp等于或大于4个");
                break;
            }
        }
        else
        {
            _emp.isUserLogo = NO;
            [noLogoEmpArray addObject:_emp];
        }
    }
    
    if (hasLogoEmpArray.count >= 4)
    {
        [logoEmpArray addObjectsFromArray:hasLogoEmpArray];
    }
    else
    {
        //            NSLog(@"有头像的emp为%d",hasLogoEmpArray.count);
        
        [logoEmpArray addObjectsFromArray:hasLogoEmpArray];
        for (int i = 0; i < emps.count - hasLogoEmpArray.count; i++)
        {
            Emp *_emp = [noLogoEmpArray objectAtIndex:i];
            //            先显示为默认头像
            
            if ([eCloudConfig getConfig].useNameAsLogo) {
                NSDictionary *dic = [UserDisplayUtil getUserDefinedGroupLogoDicOfEmp:_emp];
                UIImage *image = [ImageUtil createUserDefinedLogo:dic];
                if (image) {
                    _emp.logoImage = image;
                }
            }else{
                _emp.logoImage = [ImageUtil getDefaultLogo:_emp];
            }
            [logoEmpArray addObject:_emp];
            
            NSString *empId = [StringUtil getStringValue:_emp.emp_id];
//            NSLog(@"选择组成群组头像的小头像时，发现有的头像还没有下载，现在启动下载");
            [StringUtil downloadUserLogo:[StringUtil getStringValue:_emp.emp_id] andLogo:_emp.emp_logo andNeedSaveUrl:false];

            if (logoEmpArray.count >= 4) {
                break;
            }
        }
    }
    
    return logoEmpArray;
}

#pragma mark 查询某个会话的会话人员
-(NSArray*)getChooseTipEmp:(NSString *)convId
{
    conn *_conn = [conn getConn];
    
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select a.* from %@ a,%@ b where b.conv_id = '%@' and b.emp_id!=%@ and b.is_valid = 0 and b.emp_id = a.emp_id  and (a.emp_status = %d or a.emp_status = %d) order by emp_code",table_employee,table_conv_emp,convId,_conn.userId,status_online,status_leave];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	//	查询在线的和离开的
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
		[emps addObject:emp];
		[emp release];
	}
	//查询离线的
	sql = [NSString stringWithFormat:@"select a.* from %@ a,%@ b where b.conv_id = '%@' and b.emp_id!=%@ and b.is_valid = 0 and b.emp_id = a.emp_id and (a.emp_status = %d or a.emp_status = %d) order by emp_code ",table_employee,table_conv_emp,convId,_conn.userId,status_exit,status_offline];
	result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		Emp *emp = [self getEmpByDicData:dic];
		[emps addObject:emp];
		[emp release];
	}
	[pool release];
    
    //    增加一个 emp 代表 全体成员 默认为男性头像
    Emp *_emp = [[[Emp alloc]init]autorelease];
    _emp.emp_name = AT_ALL_CN;
    _emp.empNameEng = AT_ALL_EN;
    _emp.emp_sex = 1;
    _emp.emp_id = -1;
    _emp.empCode = AT_ALL_EN;
    //    设置成robot就不显示状态了
    _emp.isRobot = YES;
    
    [emps insertObject:_emp atIndex:0];
    
	return emps;
}


#pragma mark 获取最近的10个联系人，修改用户头像后，通知这10个联系人
-(NSArray *)getRecentContact
{
	NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type from %@ where conv_type = %d or conv_type = %d order by last_msg_time desc limit %d",table_conversation,singleType,mutiableType,10];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	return result;
}

#pragma mark -- 会话记录表--
#pragma mark 查询用户是否向这个会话里第一次发消息，如果是第一次，那么获取用户资料，并且下载头像
-(bool)isFirstSndMsgToConv:(NSString*)convId andEmpId:(int)empId
{
	NSString *sql = [NSString stringWithFormat:@"select id from %@ where conv_id = '%@' and emp_id = %d limit 1",table_conv_records,convId,empId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result.count == 1)
		return false;
	return true;
}


#pragma mark 修改会话消息,图片等上传成功后，不修改时间，而是修改状态为正在sending
-(void)updateConvRecord:(NSString *)msgId andMSG:(NSString*)msg_body andFileName:(NSString*)file_name andNewTime:(NSString *)nowtime andConvId:(NSString *)conv_id andMsgType:(int)msgType
{
	//	图片上传成功后，不修改时间，而是修改状态为正在sending
	NSString *sql = nil;
 	
    if(msgType == type_file)
    {
        //        文件类型，发送文件保存时增加后缀 _
        //        sql =[NSString stringWithFormat:@"update %@ set msg_body='%@_',send_flag = %d where id=%@ ",table_conv_records,msg_body,sending,msgId];
        
        sql =[NSString stringWithFormat:@"update %@ set msg_body='%@',send_flag = %d where id=%@ ",table_conv_records,msg_body,sending,msgId];
    }
    else if(msgType)
    {
        //	如果是长消息，上传成功后，不修改文件名称
        if(file_name == nil)
        {
            sql =[NSString stringWithFormat:@"update %@ set msg_body='%@',send_flag = %d where id=%@ ",table_conv_records,msg_body,sending,msgId];
        }
        else
        {
            sql =[NSString stringWithFormat:@"update %@ set msg_body='%@',file_name='%@',send_flag = %d where id=%@ ",table_conv_records,msg_body,file_name,sending,msgId];
        }
    }

	
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,上传图片或录音成功后，修改数据库记录失败",__FUNCTION__]];
	}
    
}

#pragma mark 保存会话记录
-(NSDictionary *)addConvRecord:(NSArray *)info
{
	NSAutoreleasePool *_pool = [[NSAutoreleasePool alloc]init];
    NSDictionary *_dic = [info objectAtIndex:0];
    
    conn *_conn = [conn getConn];
    long long srcMsgId = [[_dic valueForKey:@"rcv_msg_id"]longLongValue];
    int netId =  [[_dic valueForKey:@"rcv_net_id"]intValue];
    
#ifdef _HUAXIA_FLAG_
//    如果是华夏幸福，那么有几个账号的消息不用收，直接发送消息已收到即可
    NSString *sendId = [_dic objectForKey:@"emp_id"];
    
    for (NSNumber *empId in not_save_msg_user_array) {
        if (sendId.intValue == empId.intValue) {
            [LogUtil debug:[NSString stringWithFormat:@"%s emp id is %d 不用保存此消息",__FUNCTION__,empId.intValue]];

            if (srcMsgId) {
                //        只有收的消息才发应答
                [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
            }
            return nil;
        }
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    
    /** 如果是收到红包信息，判断当前用户是否和红包消息相关的，如果不相关，就不保存这条消息，并不显示。适用于群组红包 */
    int msgFlag = [[_dic valueForKey:@"msg_flag"] intValue];
    NSData* jsonData = [_dic[@"msg_body"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [jsonData objectFromJSONData];
    
    if(msgFlag == rcv_msg)
    {
        
        if ([resultDict[@"type"] isEqualToString:@"redPacketAction"]) {
            
            if ([[conn getConn].userId isEqualToString:resultDict[@"guestId"]] || [[conn getConn].userId isEqualToString:resultDict[@"hostId"]]) {
                
            }else{
                
                [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
                return nil;
            }
        }
        
        /** 如果是待办消息，也不需要显示 */
        if ([resultDict[@"type"]isEqualToString:KEY_LANGUANG_DAIBAN_TYPE] || [resultDict[@"type"]isEqualToString:KEY_LANGUANG_MEETING_TYPE]) {
            
            [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:nil];
            
//            [[conn getConn] performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:resultDict waitUntilDone:YES];
            
            [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
            return nil;
        }
        
        /** 如果是pc远程协助消息，不需要显示 */
        if ([resultDict[@"type"]isEqualToString:@"RDP"]) {
            
            [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
            
            return nil;
        }
    }
    if (msgFlag == send_msg) {
        
        /** 如果是pc远程协助消息，并且发送人是自己不需要显示 */
        NSString *sendId = [_dic objectForKey:@"emp_id"];
        if ([sendId isEqualToString:[conn getConn].userId]) {
            
            if ([resultDict[@"type"]isEqualToString:@"RDP"]) {

                [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
                
                return nil;
            }
        }
    }
#endif
    
#ifdef _XIANGYUAN_FLAG_
    
    /** 祥源待办消息不显示在会话列表 */
    int msgFlag = [[_dic valueForKey:@"msg_flag"] intValue];
    
    if(msgFlag == rcv_msg)
    {
        NSData* jsonData = [_dic[@"msg_body"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [jsonData objectFromJSONData];
        NSString *type = [NSString stringWithFormat:@"%@",resultDict[@"msgType"]];
        
        if ([type isEqualToString:KEY_XY_DAIBAN_MSG_TYPE] || [type isEqualToString:KEY_XY_TONGGAO_MSG_TYPE]) {
            
            [[conn getConn]createLocalNotification:_dic];
            [[conn getConn] performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:resultDict waitUntilDone:YES];
            [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_REFRESH_COUNT andObject:nil andUserInfo:resultDict];
            [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
            return nil;
            
        }else if ([type isEqualToString:KEY_XY_DAIBAN_UNREAD_TYPE]) {
            
            [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_REFRESH_COUNT andObject:nil andUserInfo:resultDict];
            [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
            return nil;
        }
        
    }
    
#endif
	NSDictionary *dic = [self addConvRecord_temp:_dic];

//文件助手数据库
#ifdef _XIANGYUAN_FLAG_
    
    if ([[_dic objectForKey:@"msg_type"]integerValue] == type_file) {
        [[FileAssistantRecordDOA getFileDatabase]addOneFileRecord:_dic];
    }
    
#endif

	NSDictionary *result = nil;
	if(dic)
    {
        //    入库成功后，向服务器发送消息已收应答
        if ([_dic valueForKey:@"rcv_msg_id"]) {
            //        只有收的消息才发应答
            [_conn sendRcvMsgAckWithMsgId:srcMsgId andNetId:netId];
        }
        
//        入库成功，此时看是否需要本地通知
        MsgNotice *msgNotice = [_dic valueForKey:@"msg_notice"];
        if (msgNotice)
        {
            [[conn getConn]createLocalNotification:_dic];
//            [[conn getConn]createLocalNotification:msgNotice];
        }
        
        result = [[NSDictionary alloc]initWithDictionary:dic];
        
    }
    
	[_pool release];
	return [result autorelease];
}

-(NSDictionary*)addConvRecord_temp:(NSDictionary*)dic
{
	// 如果是收到的消息，那么判断下这个用户是否是否是第一次向本会话发消息，如果是，那么就看下是否需要获取用户资料和头像
	int msgFlag = [[dic valueForKey:@"msg_flag"] intValue];//msg_flag
	if(msgFlag == rcv_msg)
	{
		NSString *convId = [dic valueForKey:@"conv_id"];//conv_id
		int empId = [[dic valueForKey:@"emp_id"] intValue];//emp_id
		if([self isFirstSndMsgToConv:convId andEmpId:empId])
		{
			[self getUserInfoAndDownloadLogo:[StringUtil getStringValue:empId]];
		}
	}	
	
// 取出最近一条消息的消息时间
	NSDictionary *lastMsgDic = [self getConvMsgTime:[dic valueForKey:@"conv_id"] andType:1];
	
	//如果前缀是换行，回车或空格字符，则不显示，如果后缀是换行，回车或空格字符，也不显示
	NSString *msgBody = [dic valueForKey:@"msg_body"];
	while ([msgBody hasPrefix:@"\n"])
	{
		msgBody = [msgBody substringFromIndex:1];
	}
	while ([msgBody hasPrefix:@"\r"])
	{
		msgBody = [msgBody substringFromIndex:1];
	}
	//		while ([msgBody hasPrefix:@" "])
	//		{
	//			msgBody = [msgBody substringFromIndex:1];
	//		}
	while ([msgBody hasSuffix:@"\n"])
	{
		msgBody = [msgBody substringToIndex:([msgBody length] - 1)];
	}
	while ([msgBody hasSuffix:@"\r"])
	{
		msgBody = [msgBody substringToIndex:([msgBody length] - 1)];
	}
	//		while ([msgBody hasSuffix:@" "])
	//		{
	//			msgBody = [msgBody substringToIndex:([msgBody length] - 1)];
	//		}
	//		如果所有的都是空白字符，那么不入库
	if(msgBody.length == 0)
		return nil;
	
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",[dic description]]];
	//			如果是发送的消息，那么就需要重新生成msg_id
	//		增加了同步消息功能后，应该是判断如果消息id为空，才生成消息id
	NSString *_sendOriginMsgId = [dic valueForKey:@"origin_msg_id"];
	
	if(_sendOriginMsgId == nil || _sendOriginMsgId.length == 0)
	{
		_sendOriginMsgId = [NSString stringWithFormat:@"%lld", [[conn getConn]getNewMsgId]];
	}
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,emp_id,msg_type,msg_body,msg_time,read_flag,msg_flag,send_flag,file_size,file_name,origin_msg_id,is_set_redstate,receipt_msg_flag,read_notice_flag) values(?,?,?,?,?,?,?,?,?,?,?,?,?,0)",table_conv_records];
	
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
	sqlite3_bind_text(stmt,9,[[dic valueForKey:@"file_size"] UTF8String],-1,NULL);//file_size
	sqlite3_bind_text(stmt,10,[[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//file_name
	sqlite3_bind_text(stmt,11,[_sendOriginMsgId UTF8String],-1,NULL);//origin_msg_id
	//		sqlite3_bind_int64(stmt, 11, [_sendOriginMsgId longLongValue]);//origin_msg_id
	sqlite3_bind_int(stmt,12,[[dic valueForKey:@"is_set_redstate"] intValue]);//is_set_redstate
	sqlite3_bind_int(stmt,13,[[dic valueForKey:@"receipt_msg_flag"] intValue]);//is_set_redstate
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
	
	sql = [NSString stringWithFormat:@"select max(id) as _id from %@",table_conv_records];
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count == 1)
	{
		//			查到之后，把两个id，一个是消息id，一个数据库自增长id，一起返回，便于灵活使用
		NSString *_id = [[result objectAtIndex:0]valueForKey:@"_id"];
		
		[self processReceiptMsg:dic andMsgId:_id.intValue];
		
//如果还没有消息，或者是最后一条消息的时间比收到的消息的时间早才修改
		
		int lastMsgTime = -1;
		if(lastMsgDic)
		{
			lastMsgTime = [[lastMsgDic valueForKey:@"msg_time"]intValue];
		}
        
//        NSLog(@"%s,old is %d,new is %d",__FUNCTION__,lastMsgTime,[[dic valueForKey:@"msg_time"]intValue]);
		
		if(lastMsgTime < 0 || lastMsgTime <= [[dic valueForKey:@"msg_time"]intValue])
		{
            [[PublicServiceDAO getDatabase]processFltGroupMsg:dic andId:_id.intValue];
            
			//		update by shisp 把最后一条消息的信息更新到会话记录表中
			int msgFlag = [[dic valueForKey:@"msg_flag"] intValue];
			
//            update by shisp 如果是群组通知类型的消息，不主动打开会话 display_flag标志，同时首发消息不再区分，因为msg_group_time这个值并没有用到
            
            sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ?,display_flag = 0 where conv_id =? "
                   ,table_conversation];
            
            if ([[dic valueForKey:@"msg_type"]intValue] == type_group_info) {
                sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ? where conv_id =? "
                       ,table_conversation];
            }
//            
//			if(msgFlag == rcv_msg)
//			{
//				//				收到消息的时候，保存消息所带的群组的时间
//				sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ?,display_flag = 0,msg_group_time = ? where conv_id =? "
//					   ,table_conversation];
//			}
//			else
//			{
//				sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? ,last_emp_id =?, last_msg_type = ?,display_flag = 0 where conv_id =? "
//					   ,table_conversation];
//			}
			
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
				bool isGroupCreate = [self isGroupCreate:[dic valueForKey:@"conv_id"]];
				//		绑定值
				pthread_mutex_lock(&add_mutex);
				//			如果群组已经创建，那么修改为最后一条消息id，否则仍维持-1
				if(isGroupCreate)
				{
					sqlite3_bind_int(stmt, 1,_id.intValue);//last_msg_id
				}
				else
				{
					sqlite3_bind_int(stmt, 1,-1);
				}
				//			如果是长消息那么应该保存消息头，如果是文件消息则保存文件名字
				if([[dic valueForKey:@"msg_type"] intValue] == type_long_msg || [[dic valueForKey:@"msg_type"] intValue] == type_file)
				{
					sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//last_msg_body
//                    不再单独处理 update by shisp
                    // 当会话中的文件时小万界面的要单独处理
//                    if([[RobotDAO getDatabase]isRobotUser:[[dic valueForKey:@"conv_id"] intValue]]) {
//                        sqlite3_bind_text(stmt, 2, [msgBody UTF8String],-1,NULL);//last_msg_body
//                    }
				}
				else
				{
					sqlite3_bind_text(stmt, 2, [msgBody UTF8String],-1,NULL);//last_msg_body
				}
				sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
				sqlite3_bind_int(stmt, 4, [[dic valueForKey:@"emp_id"] intValue]);//last_emp_id
				sqlite3_bind_int(stmt, 5, [[dic valueForKey:@"msg_type"] intValue]);//last_msg_type
				
//				if(msgFlag == rcv_msg)
//				{
//					sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"msg_group_time"] UTF8String],-1,NULL);//conv_id
//					sqlite3_bind_text(stmt, 7, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
//				}
//				else
//				{
					sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
//				}
				
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
                
                conn *_conn = [conn getConn];
//                离线消息是通过事务保存的，不走这里，所以这个就不加判断了
//                if (_conn.isOfflineMsgFinish) {
                    //                    判断下，如果是未读的消息才发送通知
                    int readFlag = [[dic valueForKey:@"read_flag"] intValue];
                    if (readFlag > 0) {
                        [self sendUnreadMsgNumNotification];
                    }
                    
                    [self sendNewConvNotification:dic andCmdType:add_new_conv_record];
//                }
            }
		}
		
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:dic[@"conv_id"]]) {
            
//            保存在密聊消息表
            if ([dic[@"msg_flag"] intValue] == rcv_msg ) {
                [self saveMiLiaoMsg:_id.intValue];
            }
            
            ConvRecord *convRecord = [self getConvRecordByMsgId:_id];
            
            [[MiLiaoUtilArc getUtil]addToMiLiaoMsgArray:convRecord];
        }
		NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:_id,@"msg_id",_sendOriginMsgId,@"origin_msg_id", nil];
		return _dic;
	}
	return nil;
}

#pragma mark 如果是发消息，并且是一户百应消息，那么需要把群成员和一户百应消息id添加到另外一张表中，用于记录一呼百应消息的读取情况
-(void)processReceiptMsg:(NSDictionary *)dic andMsgId:(int)msgId
{
	int msgFlag = [[dic valueForKey:@"msg_flag"] intValue];
	if(msgFlag == send_msg)
	{
		int receiptMsgFlag = [[dic valueForKey:@"receipt_msg_flag"]intValue];
		if(receiptMsgFlag == conv_status_receipt || receiptMsgFlag == conv_status_huizhi)
		{
			NSString *convId = [dic valueForKey:@"conv_id"];
			
			NSString *sql = [NSString stringWithFormat:@"select conv_type from %@ where conv_id = '%@'",table_conversation,convId];
			NSArray *result = [self querySql:sql];
			if(result.count > 0)
			{
//                要查询存在的用户
				NSString *sql = [NSString stringWithFormat:@"select b.emp_id from %@ a, %@ b where b.conv_id = '%@' and b.is_valid = 0 and b.emp_id = a.emp_id",table_employee,table_conv_emp,convId];
				NSArray *result = [self querySql:sql];
				if(result.count > 0)
				{
					NSMutableArray *userList = [[NSMutableArray alloc]initWithCapacity:result.count];
					for(NSDictionary *dic in result)
					{
						[userList addObject:[NSString stringWithFormat:@"%@",[dic valueForKey:@"emp_id"]]];
					}
					[[ReceiptDAO getDataBase]addMsgReadState:msgId andUserList:userList];
					[userList release];
				}
			}
		}
	}
}


#pragma mark 根据会话Id，查询某个会话的总的记录个数
-(int)getConvRecordCountBy:(NSString*)convId
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a, %@ b where a.conv_id = '%@' and a.emp_id=b.emp_id ",table_conv_records,table_employee,convId];
	// [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	[pool release];
	return _count;
}

#pragma mark 获得所有的未读记录个数
-(int)getAllNumNotReadedMessge
{
	int _count = 0;
	
//    update by shisp 只统计没有设置消息屏蔽的未读消息条数
//    NSString *sql = [NSString stringWithFormat:@"select count(*) record_count from %@ a,%@ b where read_flag = 1 and msg_flag = 1 and a.conv_id = b.conv_id and b.recv_flag = 0",table_conv_records,table_conversation];

//    NSString *recentConvSql = [NSString stringWithFormat:@"select * from %@ where substr(conv_id,1,1) <> 'g' and display_flag = 0 order by last_msg_time desc limit %d ",table_conversation,max_recent_conv_count];
    
    //也要统计机组群的未读消息
    NSString *recentConvSql = nil;


    
#ifdef _LANGUANG_FLAG_
    recentConvSql = [NSString stringWithFormat:@"select conv_id,conv_type from %@ where conv_id not like '%@%%' and display_flag = 0 order by last_msg_time desc limit %d ",table_conversation,MILIAO_PRE,max_recent_conv_count];
#else
    recentConvSql = [NSString stringWithFormat:@"select conv_id,conv_type from %@ where display_flag = 0 order by last_msg_time desc limit %d ",table_conversation,max_recent_conv_count];
#endif

    NSMutableArray *convResult = [self querySql:recentConvSql];

//     and b.recv_flag = 0 万达版本，因为设置了新消息不提醒，仍然要显示未读消息条数
    NSString *sql = [NSString stringWithFormat:@"select count(*) record_count from %@ a,(%@) b where read_flag = 1 and msg_flag = 1 and a.conv_id = b.conv_id",table_conv_records,recentConvSql];

    //	[LogUtil debug:[NSString stringWithFormat:@"%s,sql is %@",__FUNCTION__,sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count > 0)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"record_count"]intValue];
	}
	
    int psCount = 0;// [[PublicServiceDAO getDatabase] getUnreadMsgCountOfPS:-1];
    int appCount = 0;//[[APPPlatformDOA getDatabase] getAllNewPushCountOfAPPInContactList];
    int broadcastCount = 0;
    int imNoticeBroadcastCount = 0;
    int appNoticeBroadcastCount = 0;
    
    for (NSDictionary *dic in convResult) {
        int convType = [dic[@"conv_type"]intValue];
        switch (convType) {
            case singleType:
            case mutiableType:
//            case appInConvType:
//            case massType:
//            case rcvMassType:
//            case fltGroupConvType:
//            case publicServiceMsgDtlConvType:
            {
                //                单聊、群聊未读数已经统计
            }
                break;
            case serviceConvType:
            {
//                显示在会话列表里的服务号类型
                int serviceId = [dic[@"conv_id"]intValue];
                psCount += [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:serviceId];
            }
                break;
            case serviceNotInConvType:
            {
//                没有直接显示在会话列表里的服务号类型
                psCount += [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
            }
                break;
                
            case broadcastConvType:
            {
//                普通的广播消息
                broadcastCount = [self getAllNoReadBroadcastNum:normal_broadcast];
            }
                break;
            case imNoticeBroadcastConvType:
            {
//                普通的应用通知 和广播类似，只是类型不同
                imNoticeBroadcastCount = [self getAllNoReadBroadcastNum:imNotice_broadcast];
            }
                break;
            case appNoticeBroadcastConvType:
            {
//                类似龙湖和国美的应用通知
                appNoticeBroadcastCount = [self getAllNoReadBroadcastNum:appNotice_broadcast];
            }
                break;
                
            default:
                break;
        }
    }
    

    
    int count=_count + psCount+appCount+broadcastCount+imNoticeBroadcastCount+appNoticeBroadcastCount;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 未读普通消息总条数：%d 服务号消息总条数:%d 应用推送总条数：%d 普通广播总条数：%d imNOtice总条数：%d appNotice总条数：%d  和为：%d",__FUNCTION__,_count,psCount,appCount,broadcastCount,imNoticeBroadcastCount,appNoticeBroadcastCount,count]];
    
    AppDelegate *delegateTmp = [[UIApplication sharedApplication]delegate];
    [ApplicationManager getManager].noReadCount = count;
	return count;
}

#pragma mark 查询当前会话的未读记录个数，如果>0，那么就返回其msgid数组
-(NSArray*)getNotReadMsgId:(NSString*)convId
{
	NSMutableArray *notReadMsgIds = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//	查询会话记录表，条件是当前会话，收到的消息，并且未读
	NSString *sql = [NSString stringWithFormat:@"select id from %@ where conv_id = '%@' and msg_flag = 1 and read_flag = 1",table_conv_records,convId];
	//	[LogUtil debug:[NSString stringWithFormat:@"%s,sql is %@",__FUNCTION__,sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		[notReadMsgIds addObject:[dic valueForKey:@"id"]];
	}
	
	[pool release];
	return notReadMsgIds;
}

#pragma mark  查询某个会话的，某一页的会话记录
-(NSArray *)getConvRecordListBy:(NSString*)convId andPage:(int)curPage
{
	NSMutableArray *records = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	int offset = 0;
	if(curPage > 1)
	{
		offset = (curPage - 1)*perpage_conv_detail;
	}
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by a.msg_time limit(%d) offset(%d)",table_conv_records,table_employee,table_conversation, convId,perpage_conv_detail,offset];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [self getConvRecordByDicData:dic];
		[records addObject:record];
	}
	[pool release];
	return records;
}

#pragma mark  根据msgId获取一条会话记录
-(ConvRecord *)getConvRecordByMsgId:(NSString*)msgId
{
    //order by a.msg_time desc
	ConvRecord *record = nil;
	NSString * sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.id = '%@' and a.emp_id=b.emp_id and a.conv_id = c.conv_id ",table_conv_records,table_employee,table_conversation, msgId];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count]>0)
	{
		NSDictionary *dic = [result objectAtIndex:0];
		record = [self getConvRecordByDicData:dic];
	}
	if(record)
		return record;
	
	return nil;
}

#pragma mark 查询所有的发送状态为发送中的消息，登录成功后，自动发送这些消息
-(NSArray *)getAllSendingRecords
{
	NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select a.*,b.conv_type from %@ a, %@ b where a.msg_flag = %d and a.send_flag = %d and a.conv_id = b.conv_id order by a.msg_time desc",table_conv_records,table_conversation,send_msg,sending];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		ConvRecord *record = [self getConvRecordByDicData:dic];
        if (record.conv_type == singleType && [[VirtualGroupDAO getDatabase] isVirtualGroupUser:record.conv_id.intValue]) {
            continue;
        }
		[mArray addObject:record];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}

#pragma mark  根据会话id，查询会话记录，按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getConvRecordBy:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset
{
//    long long start = [StringUtil currentMillionSecond];
	NSMutableArray *records = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //    ,id 万达建议不增加id这个排序参数
	NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time limit(%d) offset(%d)",table_conv_records,table_employee,table_conversation,convId,_limit,_offset];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s result is %@",__FUNCTION__,result]];

	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [self getConvRecordByDicData:dic];
		[records addObject:record];
	}
	[pool release];
//    NSLog(@"%s,需要时间:%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
	return records;
}


#pragma mark  根据会话id，查询会话记录里面的图片记录，按照时间排序，最近的要排在前面
-(NSArray *)getPicConvRecordBy:(NSString *)convId{
    NSMutableArray *records = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.msg_type = %d and a.emp_id=b.emp_id and a.conv_id=c.conv_id order by msg_time",table_conv_records,table_employee,table_conversation,convId,type_pic];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [self getConvRecordByDicData:dic];
		[records addObject:record];
	}
	[pool release];
	return records;
}

#pragma mark  删除群组人员
-(void)deleteGroupMember:(NSString *)convid empid:(int)empid
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set is_valid = 1 where conv_id = '%@' and emp_id = %d ",table_conv_emp,convid,empid];
//    NSString *sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' and emp_id=%d",table_conv_emp,convid,empid];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark   清除会话记录
-(void)deleteConvRecordBy:(NSString*)convId
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@'",table_conv_records,convId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSMutableDictionary *dic in result)
	{
        [dic setValue:[NSNumber numberWithInt:delete_type_one_conv] forKey:KEY_DELETE_TYPE];
		[self deleteMsgFile:dic];
        
        //删除对应文件消息上传记录
        NSString *msgid = [NSString stringWithFormat:@"%d",[dic[@"id"]intValue]];
        [[FileAssistantDOA getDatabase] deleteOneUpload:msgid];
        [[FileAssistantDOA getDatabase] deleteOneDownloadRecord:msgid];
        

	}
	
	sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_conv_records,convId];
	[self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"update %@ set last_msg_body = '',last_msg_type = %d where  conv_id= '%@' ",table_conversation,type_text,convId];
	[self operateSql:sql Database:_handle toResult:nil];
    
//    会话的最后一条消息为空，发出这个通知，可以从数据库从新获取这个会话
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
    [self sendNewConvNotification:dic andCmdType:delete_one_msg];
}

#pragma mark  清除会话记录的同时，清除会话本身
-(void)deleteConvAndConvRecordsBy:(NSString*)convId
{
	//	删除聊天记录对应的文件
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@'",table_conv_records,convId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSMutableDictionary *dic in result)
	{
        [dic setValue:[NSNumber numberWithInt:delete_type_one_conv] forKey:KEY_DELETE_TYPE];
		[self deleteMsgFile:dic];
        
        //删除对应文件消息上传记录
        NSString *msgid = [NSString stringWithFormat:@"%d",[dic[@"id"]intValue]];
        [[FileAssistantDOA getDatabase] deleteOneUpload:msgid];
        [[FileAssistantDOA getDatabase] deleteOneDownloadRecord:msgid];

	}
	
	//	删除会话对应的记录
	sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_conv_records,convId];
	[self operateSql:sql Database:_handle toResult:nil];
	
	//    删除会话
    sql = [NSString stringWithFormat:@"delete from %@ where  conv_id='%@'",table_conversation,convId];
	[self operateSql:sql Database:_handle toResult:nil];
	
//	删除会话成员
	[self deleteConvEmpBy:convId];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
    [self sendNewConvNotification:dic andCmdType:delete_conversation];
	
}

#pragma mark 删除某一条聊天记录
-(void)deleteOneMsg:(NSString *)msgid
{
//    先去查询本会话的最后一条消息是不是这条消息，如果是则要修改最后一条消息的数据
    NSString *convId = @"";
    
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where id='%@'",table_conv_records,msgid];
	//     [LogUtil debug:[NSString stringWithFormat:@"sql--deleteOneMsg  %@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSMutableDictionary *dic in result)
	{
        [dic setValue:[NSNumber numberWithInt:delete_type_one_msg] forKey:KEY_DELETE_TYPE];
		[self deleteMsgFile:dic];
        convId = [dic valueForKey:@"conv_id"];
	}
    
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ where id = '%@' ",table_conv_records,msgid];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
    if (convId) {
        [self updateConvLastRecord:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[NSNumber numberWithInt:msgid.intValue],@"msg_id",nil]];
    }

    //删除对应文件消息上传记录
    [[FileAssistantDOA getDatabase] deleteOneUpload:msgid];
    [[FileAssistantDOA getDatabase] deleteOneDownloadRecord:msgid];
}

#pragma mark add by shisp 删除和消息相关的文件

//查询记录对应的文件是否可以删除

- (BOOL)canDeleteFile:(NSDictionary *)dic
{
    int msgType = [[dic objectForKey:@"msg_type"] intValue];
    NSString *msgBody = [dic valueForKey:@"msg_body"];

    int deleteType = [[dic valueForKey:KEY_DELETE_TYPE]intValue];
    if (deleteType == delete_type_all_conv) {
        return YES;
    }
    if (deleteType == delete_type_one_conv) {
        NSString *convId = [dic valueForKey:@"conv_id"];
        NSString *sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where msg_type = %d and msg_body = '%@' and conv_id <> '%@' ",table_conv_records,msgType,msgBody,convId];
        NSArray *result = [self querySql:sql];
        if (result) {
            NSDictionary *dic = [result objectAtIndex:0];
            int count = [[dic valueForKey:@"_count"]intValue];
            if (count > 0) {
                [LogUtil debug:@"其它会话还共用了对应的文件，所以暂时不能删除文件"];
                return NO;
            }
        }
        
        return YES;
    }
    
    if (deleteType == delete_type_one_msg) {
        NSString *sql = [NSString stringWithFormat:@"select count(id) as _count from %@ where msg_type = %d and msg_body = '%@' ",table_conv_records,msgType,msgBody];
        NSArray *result = [self querySql:sql];
        if (result) {
            NSDictionary *dic = [result objectAtIndex:0];
            int count = [[dic valueForKey:@"_count"]intValue];
            if (count > 1) {
                [LogUtil debug:@"其它聊天记录共用了对应的文件，所以暂时不能删除文件"];
                return NO;
            }
        }
    }

    return YES;
}

-(void)deleteMsgFile:(NSDictionary *)dic
{
    int msgType = [[dic objectForKey:@"msg_type"] intValue];
    NSString *msgBody = [dic valueForKey:@"msg_body"];
    
	NSString *filePath = [StringUtil newRcvFilePath];
	NSString *fileName = @"";
    
    /** 如果是回执类型消息，则需要删除读取统计 */
    [[ReceiptDAO getDataBase]deleteReadStateOfMsg:[dic[@"id"]intValue]];
    
//    如果是密聊消息，那么需要从密聊消息列表里删除
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:dic[@"conv_id"]]) {
        ConvRecord *tempRecord = [[[ConvRecord alloc]init]autorelease];
        tempRecord.msgId = [dic[@"id"] intValue];
        [[MiLiaoUtilArc getUtil]removeFromMiLiaoMsgArray:tempRecord];
    }
    
    if(msgType == type_pic)//删除图片消息
	{
        if ([self canDeleteFile:dic]) {
            fileName = [NSString stringWithFormat:@"%@.png",[dic objectForKey:@"msg_body"]];
            if(fileName != nil &&  [fileName length] > 0)
            {
                //			删除原图
                [StringUtil deleteFile:[filePath stringByAppendingPathComponent:fileName]];
                //			删除缩略图
                NSString *smallfile=[NSString stringWithFormat:@"small%@",fileName];
                [StringUtil deleteFile:[filePath stringByAppendingPathComponent:smallfile]];
                [LogUtil debug:[NSString stringWithFormat:@"delete smallfile %@",smallfile]];
            }
        }
    }else if (msgType == type_text){
        ConvRecord *_convRecord = [[[ConvRecord alloc]init]autorelease];
        _convRecord.msg_type = type_text;
        _convRecord.msg_body = dic[@"msg_body"];
        [talkSessionUtil preProcessTextMsg:_convRecord];
        if (_convRecord.locationModel) {
            if ([self canDeleteFile:dic]) {
                NSString *filePath = [LocationMsgUtil getLocationImagePath:_convRecord.locationModel];
                [StringUtil deleteFile:filePath];
            }
        }
    }
	else if(msgType == type_record)//删除录音消息
	{
        fileName = [dic objectForKey:@"file_name"];
        if(fileName != nil &&  [fileName length] > 0)
        {
            [StringUtil deleteFile:[filePath stringByAppendingPathComponent:fileName]];
        }
	}
	else if(msgType == type_long_msg)//删除长消息
	{
        if ([self canDeleteFile:dic]) {
            fileName = [NSString stringWithFormat:@"%@.txt",[dic valueForKey:@"msg_body"]];
            if(fileName != nil &&  [fileName length] > 0)
            {
                [StringUtil deleteFile:[filePath stringByAppendingPathComponent:fileName]];
            }
        }
	}
    else if(msgType == type_file)
    {
//        采用 和 图片 长消息 同样的处理
        fileName = [NSString stringWithFormat:@"%@",[dic valueForKey:@"file_name"]];
        
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        _convRecord.file_name = fileName;
        _convRecord.msg_body = msgBody;
        
        if ([self canDeleteFile:dic]) {
            [StringUtil deleteFile:[filePath stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]]];
        }
        
        [_convRecord release];
        
        //        fileName = [talkSessionUtil getFileName:_convRecord];
        
//        if(fileName != nil &&  [fileName length] > 0)
//        {
//            BOOL needDeleteFile = NO;
//            
//            NSRange range = [msgBody rangeOfString:@"_"];
//            NSString *revMsgBody = @"";
//            if(range.length > 0 ){
//                revMsgBody = [NSString stringWithFormat:@"%@",[msgBody substringToIndex:range.location]];
//            }
//            else{
//                revMsgBody = [NSString stringWithFormat:@"%@",msgBody];
//            }
//            
//            //文件保存本地名字 文件名_url.后缀
//            NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where file_name = '%@' and (msg_body = '%@' or msg_body = '%@')",table_conv_records,fileName,msgBody,revMsgBody];
//            
//            NSMutableArray *result = [self querySql:sql];
//            int count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
//            //                NSLog(@"转发或发送的次数为%d",count);
//            if(count == 1){
//                needDeleteFile = YES;
//            }
//            
//            /*
//             NSRange range = [msgBody rangeOfString:@"_"];
//             if(range.length == 0)
//             {
//             //                 NSLog(@"删除的是下载下来的文件记录，需要看看是否转发过");
//             
//             //                NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where file_name = '%@'",table_conv_records,fileName];
//             
//             NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where file_name = '%@' and msg_body = '%@'",table_conv_records,fileName,msgBody];
//             
//             NSMutableArray *result = [self querySql:sql];
//             int count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
//             //                NSLog(@"转发或发送的次数为%d",count);
//             if(count == 0)
//             {
//             needDeleteFile = YES;
//             }
//             }
//             else
//             {
//             //                NSLog(@"删除的是转发或本地发送的记录，不能删除文件");
//             }
//             */
//            
//            if(needDeleteFile)
//            {
//                [StringUtil deleteFile:[filePath stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]]];
//            }
//        }
//        
//        [_convRecord release];
        
    }
}

#pragma mark 把所有的未读记录，设置为已读
-(void)setAllUnReadToReaded
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where read_flag = 1",table_conv_records];
#ifdef _LANGUANG_FLAG_
    sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where read_flag = 1 and conv_id not like '%@%%'",table_conv_records,MILIAO_PRE];
#endif

	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql);
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
    
	//设置所有的服务号消息为已读
	[[PublicServiceDAO getDatabase] setAllPSMsgToRead];
    
    //设置所有广播消息已读
    [self setAllBroadcastToRead:normal_broadcast];
    [self setAllBroadcastToRead:imNotice_broadcast];
    [self setAllBroadcastToRead:appNotice_broadcast];
    
    //应用平台所有消息设置为已读
    [[APPPlatformDOA getDatabase] setAllAppMsgInContactListToRead];
    
}

#pragma mark  修改消息状态为已读
-(void)updateReadStatusByMsgId:(NSString*)msgId sendRead:(int)sendread
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where id = %@ ",table_conv_records,msgId];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
    sql = [NSString stringWithFormat:@"select conv_id from %@ where id = %@",table_conv_records,msgId];
    NSMutableArray *result = [self querySql:sql];
    if (result && result.count > 0) {
        NSDictionary *dic = [result objectAtIndex:0];
        [self sendNewConvNotification:dic andCmdType:read_one_msg];
    }
}

#pragma mark  修改发出的消息状态为已读 已经没有在使用
-(void)updateSendMsgReadStatus:(NSString *)msgId andConvId:(NSString*)convId andSenderId:(NSString*)senderId
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where conv_id = '%@' and id = %@ and emp_id = %@",table_conv_records,convId,msgId,senderId];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark  修改消息状态，发送失败还是成功，发送或接受的状态
-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set send_flag = %d where id = %@ ",table_conv_records,flag,msgId];
	
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"select conv_id from %@ where id = %@",table_conv_records,msgId];
    NSMutableArray *result = [self querySql:sql];
    if (result && result.count > 0) {
        NSDictionary *dic = [result objectAtIndex:0];
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [mDic setObject:[StringUtil getStringValue:flag] forKey:@"send_flag"];
        [mDic setObject:msgId forKey:@"msg_id"];
        [self sendNewConvNotification:mDic andCmdType:update_send_flag];
    }
}

#pragma mark  在程序异常退出的情况下，会走loginController自动登录的入口，这时需要把未上传成功的图片和录音的状态修改为上传失败，便于再次上传
-(void)updateSendFlagToUploadFailIfUploading
{
    NSString *sql = [NSString stringWithFormat:@"select conv_id,id as msg_id from %@ where send_flag = %d ",table_conv_records,send_uploading];
    NSMutableArray *result = [self querySql:sql];
    
    sql = [NSString stringWithFormat:@"update %@ set send_flag = %d where send_flag = %d",table_conv_records,send_upload_fail,send_uploading];
    
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,修改状态失败,sql is %@",__FUNCTION__,sql]];
	}
    else
    {
        for (NSDictionary *dic in result)
        {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [mDic setObject:[StringUtil getStringValue:send_upload_fail] forKey:@"send_flag"];
            [self sendNewConvNotification:mDic andCmdType:update_send_flag];
        }
    }
}

#pragma mark  消息发送成功或失败后，需要通知页面更新状态。需要根据通知带回的消息id，查询到对应的自增长列的值
-(NSString *)getMsgIdByOriginMsgId:(NSString*)_originMsgId
{
	NSString *msgId = nil;
	conn *_conn = [conn getConn];
	NSString *sql = [NSString stringWithFormat:@"select id from %@ where emp_id = %@ and origin_msg_id = '%@'",table_conv_records,_conn.userId,_originMsgId];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count == 1)
	{
		msgId = [StringUtil getStringValue:[[[result objectAtIndex:0]valueForKey:@"id"]intValue]] ;
	}
	return msgId;
}

#pragma mark 根据originMsgId得到所有符合条件的msgid，用于发送一呼百应已读请求成功后的处理
-(NSArray*)getMsgIdArrayByOriginMsgId:(NSString*)_originMsgId andSenderId:(int)senderId
{
	NSString *sql = [NSString stringWithFormat:@"select id from %@ where emp_id = %d and origin_msg_id like '%@%%'",table_conv_records,senderId,_originMsgId];
//	NSString *sql = [NSString stringWithFormat:@"select id from %@ where origin_msg_id like '%@%%'",table_conv_records,_originMsgId];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
    if(result.count > 0)
    {
        NSMutableArray *msgIdArray = [NSMutableArray arrayWithCapacity:result.count];
        for(NSDictionary *dic in result)
        {
            [msgIdArray addObject:[StringUtil getStringValue:[[dic valueForKey:@"id"]intValue]]];
        }
        return msgIdArray;
    }
	return nil;
}

#pragma 用户读了录音文件后，把红点标志设置为0
-(void)updateMessageToReadState:(NSString *)msgId
{
    NSString *sql  = [NSString stringWithFormat:@"update %@ set is_set_redstate =0 where id=%@ and is_set_redstate = 1 and msg_flag = 1",table_conv_records,msgId];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark 更新为已读，并且返回未读记录的个数，如果有未读消息，则可以进入会话后，定位在不同的位置，便于显示上下文
-(int)updateTextMessageToReadState:(NSString *)conv_id
{
    //    update by shisp 不再先查询 然后 再修改，而是直接运行一个修改语句 返回0
    NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where conv_id='%@' and read_flag = 1",table_conv_records,conv_id];
    [self operateSql:sql Database:_handle toResult:nil];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv_id,@"conv_id", nil];
    [self sendNewConvNotification:dic andCmdType:read_all_msg];
    
    return 0;
}
//{
//	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 1 and msg_flag = 1 and conv_id = '%@' ",table_conv_records,conv_id ];
//	NSMutableArray *result = [NSMutableArray array];
//	[self operateSql:sql Database:_handle toResult:result];
//	int unReadMsgCount = 0;
//	if(result && [result count] > 0)
//	{
//		unReadMsgCount = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
//	}
//	if(unReadMsgCount > 0)
//	{
//		//	修改收到的消息的状态为已读
//		sql  = [NSString stringWithFormat:@"update %@ set read_flag =0 where read_flag = 1 and msg_flag = 1 and conv_id='%@'",table_conv_records,conv_id];
//		
//		[self operateSql:sql Database:_handle toResult:nil];
//	}
//
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv_id,@"conv_id", nil];
//    [self sendNewConvNotification:dic andCmdType:read_all_msg];
//
//	return unReadMsgCount;
//}

#pragma mark 获取最后一条输入信息
-(NSString *)getLastInputMsgByConvId:(NSString *)conv_id
{
	NSString *lastInputMsg=@"";
    NSString *sql = [NSString stringWithFormat:@"select lastmsg_body from %@ where conv_id= '%@' ",table_conversation,conv_id];
  	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count]>0)
	{
        NSDictionary *dic=[result objectAtIndex:0];
        lastInputMsg=[dic objectForKey:@"lastmsg_body"];
    }
	return  lastInputMsg;
}

#pragma mark 更新最后输入信息
-(void)updateLastInputMsgByConvId:(NSString *)conv_id LastInputMsg:(NSString *)lastInputMsg
{
    //	修改收到的消息的状态为已读
    NSString *sql  = [NSString stringWithFormat:@"update %@ set lastmsg_body = ?  where conv_id='%@'",table_conversation,conv_id];
	
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
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv_id,@"conv_id",lastInputMsg,@"conv_draft", nil];
    [self sendNewConvNotification:dic andCmdType:save_draft];
	
}

#pragma mark 更新最后输入信息时间
-(void)updateLastInputMsgTimeByConvId:(NSString *)conv_id nowTime:(NSString *)nowTime
{
   
    //	修改收到的消息的状态为已读
    NSString *sql  = [NSString stringWithFormat:@"update %@ set last_msg_time= ? where conv_id='%@'",table_conversation,conv_id];
	
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
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv_id,@"conv_id",nowTime,@"last_msg_time", nil];
    [self sendNewConvNotification:dic andCmdType:save_last_msg_time];
    
    //    如果display_flag为1则设置为0
    sql = [NSString stringWithFormat:@"update %@ set display_flag = 0 where conv_id = '%@' and display_flag = 1",table_conversation,conv_id];
    [self operateSql:sql Database:_handle toResult:nil];
}
#pragma mark 判断群组是否创建
-(bool)isGroupCreate:(NSString*)convid
{
    NSString *sql = [NSString stringWithFormat:@"select last_msg_id from %@ where conv_id = '%@' ",table_conversation,convid];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] > 0)
	{
		//		如果last_msg_id为-1，表示没有创建
		if([[[result objectAtIndex:0]valueForKey:@"last_msg_id"]intValue] == -1)
			return false;
		return true;
	}
    return false;
}
#pragma mark 群组创建成功后，修改last_msg_id,由-1变为0
-(void)setGroupCreateFlag:(NSString*)convId
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id = 0 where conv_id = '%@'",table_conversation,convId];
	[self operateSql:sql Database:_handle toResult:nil];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
    [self sendNewConvNotification:dic andCmdType:update_last_msg_id_to_0];
}

#pragma mark 修改群组的时间
-(void)updateConversationTime:(NSString*)convId andTime:(int)_time
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set create_time = %d,msg_group_time=%d  where conv_id = '%@' ",table_conversation,_time,_time,convId];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark 根据会话id删除其对应的会话成员
-(void)deleteConvEmpBy:(NSString*)convId
{
//    万达版本，不实际删除人员，只修改下is_valid的值
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set is_valid = 1 where conv_id = '%@'",table_conv_emp,convId];

	//	如果是多人会话，需要删除会话人员
//	NSString *sql = [NSString stringWithFormat:@"delete from %@ where conv_id = '%@' ",table_conv_emp,convId];
	
	[self operateSql:sql Database:_handle toResult:nil];
}
#pragma mark 判断群组成员中是否包含用户自己
-(bool)userExistInConvEmp:(NSString*)convId
{
	conn *_conn = [conn getConn];
//    要判断是否有效
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and emp_id = %@ and is_valid = 0 ",table_conv_emp,convId,_conn.userId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count > 0)
		return true;
	return false;
}
#pragma mark 根据群组id查询群组消息表，查到最早(type = 0)或最晚(type = 1)的一条消息，如果有，则返回这个消息
-(NSDictionary *)getConvMsgTime:(NSString*)convId andType:(int)_type
{
	NSString *sql;
	if(_type == 0)
	{
		sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' order by msg_time asc limit 1",table_conv_records,convId];
	}
	else
	{
		sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' order by msg_time desc limit 1",table_conv_records,convId];
	}
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count == 1)
	{
		return [result objectAtIndex:0];
	}
	return nil;
}

#pragma mark 收到一条群组信息后，如果本地还没有创建这个群组，那么会在本地会话表里入一条会话，会话标题是收到的消息，会话的创建人是0和创建时间为空，现在查询符合这种条件的会话，在登录完成后，自发的去获取群组消息
-(NSArray *)selectConvNeedGetGroupInfo
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where create_emp_id = 0 and create_time = '' ",table_conversation];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count > 0)
	{
		NSMutableArray *_result = [NSMutableArray arrayWithCapacity:result.count];
		for(NSDictionary *dic in result)
		{
			[_result addObject:[dic valueForKey:@"conv_id"]];
		}
		//		[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,_result]];
		return _result;
	}
	return nil;
}

#pragma mark 用户详细资料快同步时，如果可能是用户关心的联系人比如常用联系人，常用组包含的成员，最近联系人，最近联系组包含的成员，那么就去下载头像
-(NSDictionary*)selectContactNeedDownLoadLogo
{
	NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *convId;
	NSString *convType;
	NSString *empId;
	//	最近10联系人，包括单个的联系人和联系群组
	NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type from %@ order by last_msg_time desc limit %d",table_conversation,10];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		convId = [dic valueForKey:@"conv_id"];
		convType = [dic valueForKey:@"conv_type"];
		if(convType.intValue == singleType)//单个联系人
		{
			if(![mDic valueForKey:@"convId"])
			{
				[mDic setValue:@"Y" forKey:convId];
			}
		}
		else
		{//群组联系人
			sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and is_valid = 0",table_conv_emp,convId];
			NSMutableArray *temp = [NSMutableArray array];
			[self operateSql:sql Database:_handle toResult:temp];
			for(NSDictionary *dic in temp)
			{
				empId =  [NSString stringWithFormat:@"%@",[dic valueForKey:@"emp_id"]];
				if(![mDic valueForKey:empId])
				{
					[mDic setValue:@"Y" forKey:empId];
				}
			}
		}
	}
	
	//	常用组
	sql = [NSString stringWithFormat:@"select virgroup_emp_id from %@ where virgroup_id = -2",table_vir_group_emps];
	[result removeAllObjects];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)//常用组
	{
		convId = [dic valueForKey:@"virgroup_emp_id"];
		sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and is_valid = 0",table_conv_emp,convId];
		NSMutableArray *temp = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:temp];
		for(NSDictionary *dic in temp)
		{
			empId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"emp_id"]];
			if(![mDic valueForKey:empId])
			{
				[mDic setValue:@"Y" forKey:empId];
			}
		}
	}
	
	//	常用联系人
	sql = [NSString stringWithFormat:@"select virgroup_emp_id from %@ where virgroup_id = -1",table_vir_group_emps];
	[result removeAllObjects];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)//常用联系人
	{
		convId = [dic valueForKey:@"virgroup_emp_id"];
		if(![mDic valueForKey:convId])
		{
			[mDic setValue:@"Y" forKey:convId];
		}
	}
	
	[pool release];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[mDic description]]];
	if(mDic.count == 0) return nil;
	return mDic;
}

#pragma mark 修改会话纪录为已读  sendread: 0 不发已读 1发已读，之前有配置是否发送已读回执，现在已经没有处理这个 shisp
-(void)updateConvInfoToIsReaded:(NSString*)convId sendReadLimt:(int)sendread
{
	//	修改收到的消息的状态为已读
	NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag =0 where conv_id='%@' and read_flag = 1 and msg_flag = 1 ",table_conv_records,convId];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark 关闭会话
-(void)updateDisplayFlag:(NSString*)convId andFlag:(int)displayFlag
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set display_flag = %d where conv_id = '%@' ",table_conversation,displayFlag,convId];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	[self operateSql:sql Database:_handle toResult:nil];
}

-(ConvRecord *)getConvRecordByDicData:(NSDictionary *)dic
{
	ConvRecord *record = [[ConvRecord alloc]init];
	record.recordType = normal_conv_record_type;
	record.msgId = [[dic objectForKey:@"id"]intValue];
	record.conv_id = [dic objectForKey:@"conv_id"];
	record.emp_id = [[dic objectForKey:@"emp_id"]intValue];
	record.msg_type = [[dic objectForKey:@"msg_type"]intValue];
	record.msg_body = [dic objectForKey:@"msg_body"];
	record.msg_time = [dic objectForKey:@"msg_time"];
	record.read_flag = [[dic objectForKey:@"read_flag"]intValue];
    record.emp_name=[dic objectForKey:@"emp_name"];
    record.emp_name_eng = [dic objectForKey:@"emp_name_eng"];
	record.msg_flag = [[dic objectForKey:@"msg_flag"]intValue];
	record.send_flag = [[dic objectForKey:@"send_flag"]intValue];
	record.file_size = [dic objectForKey:@"file_size"];
	record.file_name = [dic objectForKey:@"file_name"];
	record.emp_logo = [dic objectForKey:@"emp_logo"];
	record.conv_type = [[dic objectForKey:@"conv_type"] intValue];
    record.emp_sex=[[dic objectForKey:@"emp_sex"] intValue];
	record.emp_code = [dic objectForKey:@"emp_code"];
	NSString *originMsgId = [dic valueForKey:@"origin_msg_id"];
    record.localSrcMsgId = originMsgId;

	NSRange range = [originMsgId rangeOfString:@"|"];
	if(range.length > 0)
	{
		originMsgId = [originMsgId substringToIndex:range.location];
	}
	record.origin_msg_id = [originMsgId longLongValue];
//	record.origin_msg_id = [[dic valueForKey:@"origin_msg_id"] longLongValue];
	record.recordType = normal_conv_record_type;
	record.receiptMsgFlag = [[dic valueForKey:@"receipt_msg_flag"]intValue];
    record.is_set_redstate=([dic objectForKey:@"is_set_redstate"]==nil)?0:[[dic objectForKey:@"is_set_redstate"] intValue];
	record.readNoticeFlag = [[dic objectForKey:@"read_notice_flag"] intValue];
//    如果是一呼百应消息 才获取显示的内容
    if (record.isReceiptMsg || record.isHuizhiMsg)
    {
        record.receiptTips = [[ReceiptDAO getDataBase]getReadStateOfMsg:record];
    }
	record.empStatus = [[dic valueForKey:@"emp_status"]intValue];
	record.empLoginType = [[dic valueForKey:@"emp_login_type"]intValue];

    record.conv_title = [dic valueForKey:@"conv_title"]; //文件助手列表需要显示会话标题
    
    /** 如果是密聊消息，并且是没有打开的密聊消息，那么消息类型固定为文本，并且消息内容固定为@"密" */
#ifdef _LANGUANG_FLAG_
    record.isMiLiaoMsgOpen = YES;
    if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:record.conv_id] && record.msg_flag == rcv_msg) {
        if ([self isMiLiaoMsgExist:record.msgId]) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 显示为未打开的密聊消息",__FUNCTION__]];

            record.isMiLiaoMsgOpen = NO;
            record.msg_type = type_text;
            record.msg_body = [StringUtil getLocalizableString:@"encrypt_msg"];//@"密"
            record.receiptTips = [StringUtil getLocalizableString:@"open_encrypt_msg"];// @"点击查看密聊消息";
        }
    }
#endif
    
	return [record autorelease];
}

-(Conversation *)getConversationByDicData:(NSDictionary *)dic
{
	Conversation *conv = [[Conversation alloc]init];
	conv.conv_id = [dic objectForKey:@"conv_id"];
	conv.conv_type = [[dic objectForKey:@"conv_type"]intValue];
	conv.conv_title = [dic objectForKey:@"conv_title"];
	conv.conv_remark = [dic objectForKey:@"conv_remark"];
    conv.create_time = [dic objectForKey:@"create_time"];
	conv.recv_flag = [[dic objectForKey:@"recv_flag"]intValue];
    conv.last_msg_id=[[dic objectForKey:@"last_msg_id"]intValue];
    conv.groupType = [[dic objectForKey:@"group_type"]intValue];
//    把这个生成一个方法
    [self processAboutGroupMergedLogoWithConversation:conv andDicData:dic];

    int setTopFlag = [[dic objectForKey:@"is_set_top"]intValue];
    conv.isSetTop = NO;
    if (setTopFlag == 1) {
        conv.isSetTop = YES;
    }
    conv.setTopTime = [[dic valueForKey:@"set_top_time"]intValue];
	
    if (conv.conv_type== massType) {
     conv.lastInput_msg=[[MassDAO getDatabase] getLastInputMsgByConvId:conv.conv_id];
    }else
    {
       conv.lastInput_msg=[self getLastInputMsgByConvId:conv.conv_id];
    }
	//	最后一条消息记录
	ConvRecord *record = [[ConvRecord alloc]init];
	record.msg_type = [[dic objectForKey:@"last_msg_type"]intValue];
	record.msg_body = [dic objectForKey:@"last_msg_body"];
	record.msg_time = [dic objectForKey:@"last_msg_time"];
	record.emp_id = [[dic objectForKey:@"last_emp_id"]intValue];
    
//    NSLog(@"111:%@",record.msg_body);
	
//    add by shisp 如果lastmsgid不是-1，那么就获取最后一条消息的send_flag
    record.send_flag = send_success;
    if (conv.conv_type == singleType || conv.conv_type == mutiableType) {
        if (conv.last_msg_id != -1) {
            NSString *sql = [NSString stringWithFormat:@"select send_flag from %@ where id = %d",table_conv_records,conv.last_msg_id];
            NSMutableArray *result = [self querySql:sql];
            if (result.count > 0) {
                record.send_flag = [[[result objectAtIndex:0]valueForKey:@"send_flag"]intValue];
            }
        }
    }
	
	if (conv.conv_type==singleType)
	{//单人会话
        Emp *emp = nil;
        
        if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:conv.conv_id]) {
            emp = [self getEmployeeById:[StringUtil getStringValue:[[MiLiaoUtilArc getUtil]getEmpIdWithMiLiaoConvId:conv.conv_id].intValue]];
        }else{
            emp = [self getEmployeeById:[StringUtil getStringValue:conv.conv_id.intValue]];
        }
		
		if(emp)
		{
			conv.emp=emp;
			if(emp.emp_name && emp.emp_name.length > 0)
			{
				conv.conv_title = emp.emp_name;
			}
			else
			{
				conv.conv_title = emp.empCode;
			}
		}
		else
		{
			//			add by shisp 如果发来消息的员工在本地没有，那么创建一个空的
			Emp *_emp = [[Emp alloc]init];
			_emp.emp_id = conv.conv_id.intValue;
			conv.emp = _emp;
			[_emp release];
		}
    }
	else if(conv.conv_type == mutiableType && record.msg_body && record.msg_body.length > 0)
	{//多人会话，并且最后一条消息不为空
		Emp *emp = [self getEmployeeById:[StringUtil getStringValue:record.emp_id]];
		
		if(emp)
        {//本地包含此员工
            record.emp_code = emp.empCode;
            record.emp_name = emp.emp_name;
            record.emp_name_eng = emp.empNameEng;
            
            //			if(emp.emp_name && emp.emp_name.length > 0)
            //			{
            //				record.emp_name = emp.emp_name;
            //			}
            //			else if(emp.empCode && emp.empCode.length > 0)
            //			{
            //				record.emp_name = emp.empCode;
            //			}
        }
		else
		{//本地不包含此员工
			record.emp_name = [StringUtil getStringValue:record.emp_id];
		}
        conn *_conn = [conn getConn];
        NSString *temp = [NSString stringWithFormat:@"@%@",_conn.userName];
        conv.is_tip_me=[self getStateUnreadTipMe:conv.conv_id andTip:temp];
	}
	else if(conv.conv_type == rcvMassType)
	{//收到的群发消息类型
		NSString *convId = conv.conv_id;
		NSRange range = [convId rangeOfString:@"|"];
		if(range.length > 0)
		{
			NSString *empId = [convId substringFromIndex:range.location + 1];
			Emp *emp = [self getEmployeeById:empId];
			if(emp)
			{
				conv.emp=emp;
				if(emp.emp_name && emp.emp_name.length > 0)
				{
					conv.conv_title = emp.emp_name;
				}
				else
				{
					conv.conv_title = emp.empCode;
				}
			}
			else
			{
				//			add by shisp 如果发来消息的员工在本地没有，那么创建一个空的
				Emp *_emp = [[Emp alloc]init];
				_emp.emp_id = empId.intValue;
				conv.emp = _emp;
				[_emp release];
			}
		}
	}
    
    if (record.msg_type == type_text) {
        [talkSessionUtil preProcessTextMsg:record];
        [talkSessionUtil preProcessRobotMsg:record];
        [talkSessionUtil preProcessredPacketMsg:record];
        [talkSessionUtil preProcessMettingAppMsg:record];
        if ([UIAdapterUtil isTAIHEApp]) {
            // 判断是否为第三方应用推送
            [talkSessionUtil preProcessTextAppMsg:record];
        }
    }
    
    conv.last_record = record;
	
	if (record.msg_time==nil)
	{
		conv.msg_time=conv.create_time;
	}
	else
	{
		conv.msg_time=record.msg_time;
	}
	[record release];

	return [conv autorelease];
}

-(NSArray *)getConvListByResult:(NSArray*)result
{
	NSMutableArray *convs = [[[NSMutableArray alloc]init]autorelease];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		
		Conversation *conv = [self getConversationByDicData:dic];
        
////        update by shisp 如果是收到的一呼万ying消息，那么要检查下是否需要合并
//        if(conv.conv_type == rcvMassType)
//        {
//            MassDAO *massDAO = [MassDAO getDatabase];
//            if([massDAO mergeMassMessageToSingleConv:conv])
//            {
//                NSLog(@"需要合并，不用在会话列表显示");
//                continue;
//            }
//        }
        
        if ([conv.conv_id isEqualToString:MEETING_ID] || [conv.conv_id isEqualToString:MEETING_ID_TEST]) {
            
            [self deleteConvAndConvRecordsBy:conv.conv_id];
            
            continue;
        }
#ifdef _XIANGYUAN_FLAG_
        
        if ([conv.conv_id isEqualToString:@"79340"]) {
            
            continue;
        }
        
#endif
		conv.recordType = normal_conv_type;
		
		//		如果是服务号消息，那么未读记录个数的获取方法不同
		int convType = conv.conv_type;
		if(convType == serviceConvType)
		{
			//			如果还没有一条推送消息，那么不显示在页面
			if(conv.last_msg_id <= 0)
				continue;
			
			int serviceId = conv.conv_id.intValue;
			conv.unread = [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:serviceId];
			ServiceModel *serviceModel = [[PublicServiceDAO getDatabase]getServiceByServiceId:serviceId];
			conv.serviceModel = serviceModel;
            [LogUtil debug:[NSString stringWithFormat:@"%s %@ unread %d",__FUNCTION__,serviceModel.serviceName,conv.unread]];
		}
		else if(convType == serviceNotInConvType)
		{
			if(conv.last_msg_id <= 0)
			{
				continue;
			}
			conv.unread = [[PublicServiceDAO getDatabase]getUnreadMsgCountOfPS:-2];
            [LogUtil debug:[NSString stringWithFormat:@"%s 服务号 unread %d",__FUNCTION__,conv.unread]];
		}
        else if(convType == fltGroupConvType)
        {
            if (![[PublicServiceDAO getDatabase]hasFLTGroup]) {
                continue;
            }
            conv.unread = [[PublicServiceDAO getDatabase]getUnreadMsgCountOfFLT];
            [LogUtil debug:[NSString stringWithFormat:@"%s 机组群 unread %d",__FUNCTION__,conv.unread]];
        }
        else if (convType == appInConvType){
            //显示在主页应用推送记录
            if(conv.last_msg_id <= 0)
				continue;
			
			NSString *appid = conv.conv_id;
			conv.unread = [[APPPlatformDOA getDatabase] getAllNewPushNotiCountWithAppid:appid];
			APPListModel *appModel = [[APPPlatformDOA getDatabase] getAPPModelByAppid:appid];
			conv.appModel = appModel;
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 应用推送记录 unread %d",__FUNCTION__,conv.unread]];
        }
        //增加广播消息类型的未读消息计数
        else if (convType == broadcastConvType)
        {
            conv.unread = [self getAllNoReadBroadcastNum:normal_broadcast];
            [LogUtil debug:[NSString stringWithFormat:@"%s 普通广播 unread %d",__FUNCTION__,conv.unread]];

        }
        else if (convType == imNoticeBroadcastConvType)
        {
            conv.unread = [self getAllNoReadBroadcastNum:imNotice_broadcast];
            [LogUtil debug:[NSString stringWithFormat:@"%s imNotice unread %d",__FUNCTION__,conv.unread]];

        }
        else if (convType == appNoticeBroadcastConvType)
        {
            conv.unread = [self getAllNoReadBroadcastNum:appNotice_broadcast];
            [LogUtil debug:[NSString stringWithFormat:@"%s appNotice unread %d",__FUNCTION__,conv.unread]];
        }
		else
		{
			NSString *sql = [NSString stringWithFormat:@"select count(*) record_count from %@ where conv_id = '%@' and read_flag = 1 and msg_flag = 1",table_conv_records,[dic objectForKey:@"conv_id"]];
			
			int _unread = 0;
			NSMutableArray *result1 = [NSMutableArray array];
			[self operateSql:sql Database:_handle toResult:result1];
			if(result1 && [result1 count] == 1)
			{
				_unread = [[[result1 objectAtIndex:0]objectForKey:@"record_count"]intValue];
			}
			conv.unread = _unread;
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 普通消息 conv_id is %@ unread %d",__FUNCTION__,[dic objectForKey:@"conv_id"],conv.unread]];
		}
		
		[convs addObject:conv];
	}
	[pool release];
	return convs;
}


#pragma mark -----------------虚拟组，常用组，常用联系人，广播相关程序-----------------
#pragma mark 常用群组名称
-(BOOL)getStateUnreadTipMe:(NSString *)convId andTip:(NSString *)tip_name
{
    NSString *sql = [NSString stringWithFormat:@"select msg_body from %@ where conv_id = '%@' and read_flag = 1 and msg_flag = 1 and msg_type = %d ",table_conv_records,convId,type_text];
    //    查找收到的未读文本消息是否包含@消息
    NSMutableArray *result = [self querySql:sql];
    for (NSDictionary *dic in result) {
        NSString *msgBody = dic[@"msg_body"];
        NSRange _range = [msgBody rangeOfString:tip_name];
        if (_range.length > 0)
        {
            return YES;
        }
        BOOL isAtAllMsg = [StringUtil isAtAllMsg:msgBody];
        if (isAtAllMsg)
        {
            return YES;
        }
    }
    return NO;
}

-(NSArray *)getOffenGroup:(NSString *)virgroupid andLevel:(int)level
{
	NSMutableArray *emps = [NSMutableArray array];
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat: @"select * from vir_group_emps where virgroup_id='%@'",virgroupid];
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		OffenGroup *offengroup=[[OffenGroup alloc]init];
		offengroup.group_level=level;
		offengroup.group_id=[dic objectForKey:@"virgroup_emp_id"];
		offengroup.group_title=[dic objectForKey:@"conv_title"];
		[emps addObject:offengroup];
		[offengroup release];
	}
	[pool release];
	
	return emps;
}
//根据虚拟组id，获取有员工信息,并定位级别
-(NSArray *)getEmpFromVirGroup:(NSString *)virgroupid andLevel:(int)level
{
	NSMutableArray *emps = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//	先获取在线和离开的
	NSString *sql = [NSString stringWithFormat: @"select * from employee where emp_id in (select virgroup_emp_id from vir_group_emps where virgroup_id='%@' ) and (emp_status = %d or emp_status = %d) order by emp_code",virgroupid,status_online,status_leave];
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [self getEmpByDicData:dic];
		emp.deptName=virgroupid;
		emp.emp_level=level;
		[emps addObject:emp];
		[emp release];
	}
	//	获取离线的
	sql = [NSString stringWithFormat: @"select * from employee where emp_id in (select virgroup_emp_id from vir_group_emps where virgroup_id='%@' ) and (emp_status = %d or emp_status = %d) order by emp_code",virgroupid,status_offline,status_exit];
	result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [self getEmpByDicData:dic];
		emp.deptName=virgroupid;
		emp.emp_level=level;
		[emps addObject:emp];
		[emp release];
	}
	[pool release];
	
	return emps;
}
//根据虚拟组id，获取有员工信息,并定位级别
-(NSArray *)getEmpsFromVirGroupByVirgroupid:(NSString *)virgroupid
{
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat: @"select * from employee where emp_id in (select virgroup_emp_id from vir_group_emps where virgroup_id='%@' )",virgroupid];
	NSMutableArray * result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
        //		[LogUtil debug:[NSString stringWithFormat:@"deptid is %@ dept_emp is %@",deptId , result]];
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
			Emp *emp = [self getEmpByDicData:dic];
			[emps addObject:emp];
			[emp release];
		}
	}
	[pool release];
	return emps;
}

#pragma mark 虚拟组？？？
-(NSArray *)getVirGroupConvRecordListBy:(NSString*)convId andPage:(int)curPage
{
	NSMutableArray *records = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	int offset = 0;
	if(curPage > 1)
	{
		offset = (curPage - 1)*perpage_conv_detail;
	}
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex from %@ a, %@ b where a.conv_id = '%@' and a.emp_id=b.emp_id  order by a.msg_time limit(%d) offset(%d)",table_conv_records,table_employee, convId,perpage_conv_detail,offset];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [self getVirGroupConvRecordByDicData:dic];
		[records addObject:record];
		[record release];
	}
	[pool release];
	return records;
}

//2.5 虚拟组－根据会话id，查询会话记录，按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getConvRecordByVirGroup:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset
{
	NSMutableArray *records = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex from %@ a, %@ b where a.conv_id = '%@' and a.emp_id=b.emp_id  order by msg_time limit(%d) offset(%d)",table_conv_records,table_employee,convId,_limit,_offset];
    
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(int i=0;i<[result count];i++)
	{
		NSDictionary *dic = [result objectAtIndex:i];
		ConvRecord *record = [self getVirGroupConvRecordByDicData:dic];
		[records addObject:record];
		[record release];
	}
	[pool release];
	return records;
}


-(ConvRecord *)getVirGroupConvRecordByDicData:(NSDictionary *)dic
{
	ConvRecord *record = [[ConvRecord alloc]init];
	record.msgId = [[dic objectForKey:@"id"]intValue];
	record.conv_id = [dic objectForKey:@"conv_id"];
	record.emp_id = [[dic objectForKey:@"emp_id"]intValue];
	record.msg_type = [[dic objectForKey:@"msg_type"]intValue];
	record.msg_body = [dic objectForKey:@"msg_body"];
	record.msg_time = [dic objectForKey:@"msg_time"];
	record.read_flag = [[dic objectForKey:@"read_flag"]intValue];
    record.emp_name=[dic objectForKey:@"emp_name"];
	record.msg_flag = [[dic objectForKey:@"msg_flag"]intValue];
	record.send_flag = [[dic objectForKey:@"send_flag"]intValue];
	record.file_size = [dic objectForKey:@"file_size"];
	record.file_name = [dic objectForKey:@"file_name"];
	record.emp_logo = [dic objectForKey:@"emp_logo"];
	record.conv_type = mutiableType;
    record.emp_sex=[[dic objectForKey:@"emp_sex"] intValue];
	
	record.origin_msg_id = [[dic valueForKey:@"origin_msg_id"] longLongValue];
	
	record.is_set_redstate=([dic objectForKey:@"is_set_redstate"]==nil)?0:[[dic objectForKey:@"is_set_redstate"] intValue];
	return record;
}

//删除常用联系人
-(void)deleteContactPersonFromVirGroup:(int)emp_id
{
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where virgroup_emp_id = %d and virgroup_id='-1'",table_vir_group_emps,emp_id];
	[self operateSql:sql Database:_handle toResult:nil];
}
//删除常用群组
-(void)deleteOffenGroupFromVirGroup:(NSString *)emp_id
{
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where virgroup_emp_id = '%@' and virgroup_id='-2'",table_vir_group_emps,emp_id];
	[self operateSql:sql Database:_handle toResult:nil];
}

//3 获取虚拟组
-(NSArray*)getVirGroups
{
	NSMutableArray *groupObjS = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from vir_group  order by virgroup_updatetime desc"];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            VirGroupObj  *groupObj = [[VirGroupObj alloc]init];
            groupObj.virgroup_id = [dic objectForKey:@"virgroup_id"];
            groupObj.virgroup_name = [dic objectForKey:@"virgroup_name"];
            groupObj.virgroup_updatetime = [dic objectForKey:@"virgroup_updatetime"];
            groupObj.virgroup_usernum = [[dic objectForKey:@"virgroup_usernum"] intValue];
            groupObj.isExtended=false;
            groupObj.virgroup_level=0;
			[groupObjS addObject:groupObj];
			[groupObj release];
		}
	}
	[pool release];
	return groupObjS;
}

- (BOOL)saveBroadcastToDB:(NSDictionary *)dic{
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(sender_id, recver_id, msg_id, sendtime, msglen, asz_titile, asz_message, broadcast_type,read_flag) values(?,?,?,?,?,?,?,?,?)",table_broadcast];
    
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
        [self rollbackTransaction];
        return NO;
    }
    
    //		绑定值
    pthread_mutex_lock(&add_mutex);
    sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"sender_id"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"recver_id"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_id"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"sendtime"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 5, [[dic valueForKey:@"msglen"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"asz_titile"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 7, [[dic valueForKey:@"asz_message"] UTF8String],-1,NULL);
    sqlite3_bind_int(stmt, 8, [[dic valueForKey:@"broadcast_type"] intValue]);//emp_id
    sqlite3_bind_int(stmt, 9, 1);//emp_id
    if (dic[@"read_flag"]) {
        sqlite3_bind_int(stmt, 9, [dic[@"read_flag"]intValue]);//emp_id
    }
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
        [self rollbackTransaction];
        return NO;
    }
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    return YES;
}

//广播---保存
-(void)saveBroadcast:(NSArray *) info
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"sender_id", @"recver_id", @"msg_id", @"sendtime", @"msglen", @"asz_titile", @"asz_message", @"broadcast_type",nil];
    
	NSString    *sql        =   nil;
	for (NSDictionary *dic in info)
	{
        [LogUtil debug:[NSString stringWithFormat:@"%s dic is %@",__FUNCTION__,dic]];

        BOOL result = [self saveBroadcastToDB:dic];
        if (!result) {
            return;
        }
        //创建或更新广播会话记录
        [self createbroadcastConv:dic];
	}
}

//检查该广播是否已经保存
-(BOOL)isBroadcastSaved:(NSString*) msgId
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = %@",table_broadcast,msgId];
    
    [self operateSql:sql Database:_handle toResult:tempArray];

    if (tempArray.count > 0)
        return YES;
    else
        return NO;
}

- (void)createbroadcastConv:(NSDictionary *)dic{
    //创建或更新广播会话记录
    NSString *convId;
    int broadcastType = [[dic valueForKey:@"broadcast_type"] intValue];
    
    BOOL isGOMEMailAppMsg = NO;
    int appId = [dic[@"sender_id"]intValue];
#ifdef _GOME_FLAG_
    if (appId == GOME_EMAIL_APP_ID) {
        isGOMEMailAppMsg = YES;
    }
#endif

    int convType = 0;
    NSMutableString *convTitle = nil;;
    if (broadcastType == imNotice_broadcast) {
        convType = imNoticeBroadcastConvType;
        convTitle = [StringUtil getLocalizableString:@"im_notice"];
    }else if (broadcastType == appNotice_broadcast) {
        convType = appNoticeBroadcastConvType;
        if ([UIAdapterUtil isCsairApp]) {
            convTitle = @"提醒";
        }else{
            convTitle = [StringUtil getAppLocalizableString:@"app_msg"];
        }
    } else{
        convType = broadcastConvType;
        convTitle = [StringUtil getLocalizableString:@"settings_broadcast_message"];
    }
    
    //    最近一条广播消息的时间
    int lastNoticeMsgTime = 0;
    NSString *sql = [NSString stringWithFormat:@"select conv_id,last_msg_time from %@ where conv_type = %d",table_conversation,convType];
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if(result.count > 0){
        //修改最后一条消
        convId = [[result objectAtIndex:0] valueForKey:@"conv_id"];
        lastNoticeMsgTime = [[result[0] valueForKey:@"last_msg_time"] intValue];
    }
    else{
        //增加一个新的会话，显示不在会话列表显示的服务号消息入口，默认的convid为第一条收到的广播消息的id
        //默认屏蔽，收到该服务号的消息后，再设置为打开
        convId = [dic objectForKey:@"msg_id"];
        NSString *recvFlag = [StringUtil getStringValue:open_msg];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             convId,@"conv_id",
                             [StringUtil getStringValue:convType],@"conv_type",
                             convTitle,@"conv_title",
                             recvFlag,@"recv_flag",nil];
    
        [self addConversation:[NSArray arrayWithObject:dic]];
        
        //创建新的会话
        NSDictionary *notiDic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
        [self sendNewConvNotification:notiDic andCmdType:add_new_conversation];
    }
    int thisNoticeMsgTime = [[dic objectForKey:@"sendtime"] intValue];
    if(convId && ((thisNoticeMsgTime >= lastNoticeMsgTime) || isGOMEMailAppMsg))
    {
        //记录last_msg_id,last_msg_body,last_msg_time ，默认是文本消息
        NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? , last_msg_type = %d,display_flag = 0 where conv_id = '%@' and conv_type = %d"
                         ,table_conversation,type_text,convId,convType];
        
        sqlite3_stmt *stmt = nil;
        //编译
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
            //绑定值
            pthread_mutex_lock(&add_mutex);
            
            sqlite3_bind_int(stmt, 1,[[dic objectForKey:@"msg_id"] intValue] );
            sqlite3_bind_text(stmt, 2, [[dic objectForKey:@"asz_titile"] UTF8String],-1,NULL);
            if ([UIAdapterUtil isGOMEApp]) {
//                需要把应用名称附加在应用消息标题前面
                NSString *appId = dic[@"sender_id"];
                APPListModel *appModel = [[APPPlatformDOA getDatabase]getAPPModelByAppid:appId.integerValue];
                if (appModel.appname.length) {
                    sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%@:%@",appModel.appname,[dic objectForKey:@"asz_titile"]] UTF8String],-1,NULL);
                }
            }
            sqlite3_bind_text(stmt, 3, [[dic objectForKey:@"sendtime"] UTF8String],-1,NULL);//last_msg_time
            //执行
            state = sqlite3_step(stmt);
            
            pthread_mutex_unlock(&add_mutex);
            //执行结果
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
        
        //更新会话
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
        [self sendNewConvNotification:dic andCmdType:add_new_conversation];
    }
}


//获取广播消息
-(NSMutableArray*)getBroadcastList:(int)broadcastType
{
	NSMutableArray *broadlist = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from system_broadcast where broadcast_type = %d order by sendtime desc",broadcastType];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	NSDictionary *dic ;
	for(int i=0;i<[result count];i++)
	{
		dic = [result objectAtIndex:i];
		
		[broadlist addObject:dic];
		
	}
	[pool release];
	return broadlist;
}

//获取广播消息 根据appID
-(NSMutableArray*)getBroadcastList:(int)broadcastType withAppID:(NSString *)appID
{
    NSMutableArray *broadlist = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from system_broadcast where broadcast_type = %d and sender_id = %@ order by sendtime desc",broadcastType,appID];
    //  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    NSDictionary *dic ;
    for(int i=0;i<[result count];i++)
    {
        dic = [result objectAtIndex:i];
        
        [broadlist addObject:dic];
        
    }
    [pool release];
    return broadlist;
}

//获取10条广播消息 根据appID和当前条数
-(NSMutableArray*)getBroadcastList:(int)broadcastType withAppID:(NSString *)appID currentCount:(NSInteger)count
{
    NSMutableArray *broadlist = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from system_broadcast where broadcast_type = %d and sender_id = %@ order by sendtime desc limit %ld,%ld",broadcastType,appID,count,count+num_convrecord];
    //  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    NSDictionary *dic ;
    for(int i=0;i<[result count];i++)
    {
        dic = [result objectAtIndex:i];
        
        [broadlist addObject:dic];
        
    }
    [pool release];
    return broadlist;
}

//删除广播消息
-(void)deleteBroadcastByOne:(NSString *)msg_id andConvId:(NSString *)conv_id
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where msg_id = %@ ",table_broadcast,msg_id];
    [self operateSql:sql Database:_handle toResult:nil];
}

//删除所有的广播
-(void)deleteAllBroadcast:(int)broadcastType
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where broadcast_type = %d",table_broadcast,broadcastType];
    [self operateSql:sql Database:_handle toResult:nil];
}

//获取所有未读广播的消息数
-(int)getAllNoReadBroadcastNum:(int)broadcastType;
{
    int _count = 0;
    @autoreleasepool
    {
        NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 1 and broadcast_type = %d",table_broadcast,broadcastType];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:_handle toResult:result];
        if([result count] == 1)
        {
            _count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
        }
    }
    return _count;
}

- (NSString *)getConvIdOfBroadcastConvType:(int)_broadcastConvType
{
    NSString *sql = [NSString stringWithFormat:@"select conv_id from %@ where conv_type = %d",table_conversation,_broadcastConvType];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 1 ) {
        NSString *convId = [result[0] valueForKey:@"conv_id"];
        return convId;
    }
    return nil;
}

//所有未读广播设为已读
-(void)setAllBroadcastToRead:(int)broadcastType
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where read_flag = 1 and broadcast_type = %d",table_broadcast,broadcastType];
    [self operateSql:sql Database:_handle toResult:nil];
    
    
//    未读数为0
    NSNumber *unReadCount = [NSNumber numberWithInt:0];
    
    NSString *convId = [self getConvIdOfBroadcastConvType:[BroadcastUtil getBroadcastConvTypeWithBroadcastType:broadcastType]];
    if (convId) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",unReadCount,@"unread_msg_count",nil];
        [self sendNewConvNotification:dic andCmdType:update_broadcast_read_flag];
    }
}

//判断是否需要更新广播的ReadFlag
-(BOOL)needUpdateBroadcastReadFlag:(NSString *) msg_id
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = %@ and read_flag = 1",table_broadcast,msg_id];
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if (result.count == 1) {
        return YES;
    }
    return NO;
}

//设置该广播消息为已读
-(void)updateBroadcastReadFlagToRead:(NSString *) msg_id andUpdateConvId:(NSString *) conv_id andBroadcastType:(int)broadcastType
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where read_flag = 1 and msg_id = %@ and broadcast_type = %d",table_broadcast,msg_id,broadcastType];
    [self operateSql:sql Database:_handle toResult:nil];
    NSNumber *unReadCount = [NSNumber numberWithInt:[self getAllNoReadBroadcastNum:broadcastType]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:conv_id,@"conv_id",unReadCount,@"unread_msg_count",nil];
    [self sendNewConvNotification:dic andCmdType:update_broadcast_read_flag];
}

//日程助手

//日程助手
-(void)addHelperSchedule:(NSArray *)info
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"helper_id",@"group_id", @"helper_title", @"helper_detail", @"helper_create_emp_id", @"create_time", @"start_time", @"end_time", @"start_date", @"warnning_type", @"warnning_str",@"is_read",nil];
	NSString    *sql        =   nil;
	for (NSDictionary *dic in info)
	{
        sql =   [self replaceIntoTable:table_datehelper newInfo:dic keys:keys];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}
//日程助手  组成员
//日程助手
-(void)addHelperEmp:(NSArray *)info
{
    conn *_conn = [conn getConn];
    int start = [_conn getCurrentTime];
    
	NSArray *keys           =   [NSArray arrayWithObjects:@"helper_id", @"emp_id",nil];
    
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:info.count];
	NSString    *sql        =   nil;
	for (NSDictionary *dic in info)
	{
        sql =   [self replaceIntoTable:table_helper_emp newInfo:dic keys:keys];
        [sqlArray addObject:sql];
    }
    
    if([self beginTransaction])
    {
        pthread_mutex_lock(&add_mutex);
        
        for(int i = 0;i<sqlArray.count;i++)
        {
            sql = [sqlArray objectAtIndex:i];
            
            char *errorMessage;
            sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
            if(errorMessage == nil)
            {
//                NSLog(@"success");
            }
            else
            {
//                [LogUtil debug:[NSString stringWithFormat:@"%@",[NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]]];
            }
        }
        pthread_mutex_unlock(&add_mutex);

        [self commitTransaction];
    }
//    for (NSDictionary *dic in info)
//	{
//        sql =   [self replaceIntoTable:table_helper_emp newInfo:dic keys:keys];
//        [self operateSql:sql Database:_handle toResult:nil];
//    }
    
    int end = [_conn getCurrentTime];
    
    NSLog(@"end - start is %d",end - start);
}
//删除日程成员
-(void)deleteHelperScheduleMember:(NSString *)helper_id
{
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where helper_id = %@ ",table_helper_emp,helper_id];
	[self operateSql:sql Database:_handle toResult:nil];
}
//删除日程
-(void)deleteHelperSchedule:(NSString *)helper_id
{
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where helper_id = %@ ",table_datehelper,helper_id];
	[self operateSql:sql Database:_handle toResult:nil];
}
//3 获取 日程
-(NSArray*)getHelperSchedule
{
	NSMutableArray *groupObjS = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@  order by start_time desc",table_datehelper];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            helperObject  *hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [dic objectForKey:@"helper_create_emp_id"];
            
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
			[groupObjS addObject:hobject];
			[hobject release];
		}
	}
	[pool release];
	return groupObjS;
}
//获取最近时间的日程
-(helperObject*)getNewestHelperSchedule
{
    helperObject *hobject=nil;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from (select * from %@  order by create_time desc) order by is_read desc",table_datehelper];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
			NSDictionary *dic = [result objectAtIndex:0];
            hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [dic objectForKey:@"helper_create_emp_id"];
            
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
	}
    hobject.unread=[self getUnreadHelperNum];
    
	[pool release];
	return hobject;
}
//判断该日期是否有日程
-(BOOL)isTheDateHasSchedule:(NSString *)choosedate
{    BOOL isSchedule=false;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select helper_id from %@ where start_date=%@",table_datehelper,choosedate];
  //  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
     isSchedule=true;
	}
	[pool release];

    return isSchedule;
}
// 查询该日期的日程安排
-(NSArray*)getTheDateSchedule:(NSString *)choosedate
{
	NSMutableArray *groupObjS = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where start_date=%@",table_datehelper,choosedate];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            helperObject  *hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [[dic objectForKey:@"helper_create_emp_id"]intValue];
            hobject.create_emp_name=[self getEmpNameByEmpId:[dic objectForKey:@"helper_create_emp_id"]];
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
            hobject.ring_str = [dic objectForKey:@"warnning_str"];
			[groupObjS addObject:hobject];
			[hobject release];
		}
	}
    [self setHadReaded:choosedate];//置为已读。
	[pool release];
	return groupObjS;
}
// 查询该日期及以后的日程安排
-(NSArray*)getTheDateAndFollowingSchedule:(NSString *)choosedate
{
	NSMutableArray *groupObjS = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where start_date>=%@ order by start_time asc",table_datehelper,choosedate];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{   NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
        NSString *weekstr=@" ";
        NSString *tempweekstr;
        NSDate *now=[NSDate date];
        NSString *nowstr=[fmt stringFromDate:now];
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            helperObject  *hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [[dic objectForKey:@"helper_create_emp_id"]intValue];
            hobject.create_emp_name=[self getEmpNameByEmpId:[dic objectForKey:@"helper_create_emp_id"]];
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
            hobject.ring_str = [dic objectForKey:@"warnning_str"];
            hobject.is_read=[[dic objectForKey:@"is_read"]intValue];
            NSArray *dataarry=[self getEmpByhelperid:hobject.helper_id];
            if ([dataarry count]>1) {
             hobject.is_group=YES;
            }else
            {
             hobject.is_group=NO;
            }
             NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
             tempweekstr=[fmt stringFromDate:tempdate];
            if (![weekstr isEqualToString:tempweekstr]) {
                hobject.show_week=YES;
            }else
            {
                hobject.show_week=NO;
            }
            weekstr=tempweekstr;
            if ([nowstr isEqualToString:tempweekstr]) {
                hobject.is_now=YES;
            }else
            {
                hobject.is_now=NO;
            }
            [groupObjS addObject:hobject];
			[hobject release];
		}
        [fmt release];
	}
   // [self setHadReaded:choosedate];//置为已读。
	[pool release];
	return groupObjS;
}
// 查询新日程最新收到
-(NSArray*)getNewestGetSchedule
{
	NSMutableArray *groupObjS = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where is_read =2 order by start_time asc",table_datehelper];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{   NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy年MM月dd日 EEEE";
        NSString *weekstr=@" ";
        NSString *tempweekstr;
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            helperObject  *hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [[dic objectForKey:@"helper_create_emp_id"]intValue];
            hobject.create_emp_name=[self getEmpNameByEmpId:[dic objectForKey:@"helper_create_emp_id"]];
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
            hobject.ring_str = [dic objectForKey:@"warnning_str"];
            hobject.is_read=[[dic objectForKey:@"is_read"]intValue];
            NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[hobject.start_time intValue]];
            tempweekstr=[fmt stringFromDate:tempdate];
            if (![weekstr isEqualToString:tempweekstr]) {
                hobject.show_week=YES;
            }else
            {
                hobject.show_week=NO;
            }
            weekstr=tempweekstr;
            [groupObjS addObject:hobject];
			[hobject release];
		}
        [fmt release];
	}
    // [self setHadReaded:choosedate];//置为已读。
	[pool release];
	return groupObjS;
}


-(void)setHadReaded:(NSString *)choosedate
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set is_read = 0 where is_read = 1 and start_date=%@",table_datehelper,choosedate];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}

}
//把最新设置为未读
-(void)setNewestBeUnread
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set is_read = 1 where is_read = 2",table_datehelper];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
    
}
//设为已读
-(void)setHadReadedByHelperID:(NSString *)helper_id
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set is_read = 0 where is_read >0 and helper_id=%@",table_datehelper,helper_id];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
    
}

//修改 提醒类型
-(void)updateHelperRingTypeByID:(NSString *)helper_id Type:(NSString *)type TypeName:(NSString *)type_name
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set warnning_type =%@ ,warnning_str='%@' where helper_id=%@",table_datehelper,type,type_name,helper_id];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
    
}

//获取日程详细
-(helperObject *)getTheDateScheduleByID:(NSString *)helper_id
{
    helperObject *hobject=nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where helper_id=%@",table_datehelper,helper_id];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [[dic objectForKey:@"helper_create_emp_id"]intValue];
            hobject.create_emp_name=[self getEmpNameByEmpId:[dic objectForKey:@"helper_create_emp_id"]];
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
            hobject.ring_str = [dic objectForKey:@"warnning_str"];
            hobject.group_id=[dic objectForKey:@"group_id"];
			
		}
	}
	[pool release];
	return hobject;
}

//获取日程详细
-(helperObject *)getTheDateScheduleByGroupID:(NSString *)helper_id
{
    helperObject *hobject=nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where group_id=%@",table_datehelper,helper_id];
	//  [LogUtil debug:[NSString stringWithFormat:@"---------sql---%@",sql]];//emp_pinyin,
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            hobject = [[helperObject alloc]init];
            hobject.helper_id = [dic objectForKey:@"helper_id"];
            hobject.helper_name = [dic objectForKey:@"helper_title"];
            hobject.helper_detail = [dic objectForKey:@"helper_detail"];
            hobject.create_emp_id = [[dic objectForKey:@"helper_create_emp_id"]intValue];
            hobject.create_emp_name=[self getEmpNameByEmpId:[dic objectForKey:@"helper_create_emp_id"]];
            hobject.create_time = [dic objectForKey:@"create_time"];
            hobject.start_time = [dic objectForKey:@"start_time"];
            hobject.end_time = [dic objectForKey:@"end_time"];
            hobject.ring_type=[[dic objectForKey:@"warnning_type"]intValue];
            hobject.ring_str = [dic objectForKey:@"warnning_str"];
            hobject.group_id=[dic objectForKey:@"group_id"];
			
		}
	}
	[pool release];
	return hobject;
}
//获取日程成员
-(NSArray *)getEmpByhelperid:(NSString *)helper_id
{

  	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat: @"select * from employee where emp_id in (select emp_id from %@ where helper_id=%@)",table_helper_emp,helper_id];
	NSMutableArray * result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
        //		[LogUtil debug:[NSString stringWithFormat:@"deptid is %@ dept_emp is %@",deptId , result]];
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
			Emp *emp = [self getEmpByDicData:dic];
			[emps addObject:emp];
			[emp release];
		}
	}
	[pool release];
	return emps;
}
#pragma mark 获取未读日程数
-(int)getUnreadHelperNum
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where is_read>0",table_datehelper];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
#pragma mark 获取某天未读日程数
-(int)getUnreadHelperNumByDate:(NSString *)startdate
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where is_read>0 and start_date=%@",table_datehelper,startdate];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
#pragma mark 获取某天已读日程数
-(int)getHadreadHelperNumByDate:(NSString *)startdate
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where is_read=0 and start_date=%@",table_datehelper,startdate];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
#pragma mark 获取某月未读日程数
-(int)getUnreadHelperNumByYearMonth:(NSString *)yearmonth
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where is_read>0 and start_date like '%%%@%%'",table_datehelper,yearmonth];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
#pragma mark 获取某月已读日程数
-(int)getHadreadHelperNumByYearMonth:(NSString *)yearmonth
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where is_read=0 and start_date like '%%%@%%'",table_datehelper,yearmonth];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
//获取groupid
-(NSString *)getGroupIdByHelperID:(NSString *)helper_id
{
	NSString *groupid=nil;
    NSString *sql = [NSString stringWithFormat:@"select group_id from %@ where helper_id=%@",table_datehelper,helper_id];
  	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count]>0)
	{
        NSDictionary *dic=[result objectAtIndex:0];
        groupid=[dic objectForKey:@"group_id"];
    }
	return  groupid;
}

#pragma mark 修改会话的最后一条消息记录
- (void)updateConvLastRecord:(NSDictionary *)dic
{
    NSString *convId = [dic valueForKey:@"conv_id"];
    [LogUtil debug:[NSString stringWithFormat:@"%s convId is %@",__FUNCTION__,convId]];

//消息id，主要用来判断是否需要更新；比如删除一条消息；如果删除的正是最后一条记录，那么就要重新设置；比如撤回一条消息，如果这条消息正是最后一条记录，那么也需要重新设置；
    NSNumber *msgId = [dic valueForKey:@"msg_id"];
    
    BOOL needUpdatConvLastMsg = YES;
    if (msgId) {
        NSString *sql = [NSString stringWithFormat:@"select last_msg_id from %@ where conv_id = '%@' and last_msg_id = %d ",table_conversation,convId,msgId.intValue];
        NSMutableArray *result = [self querySql:sql];
        if (result.count == 0) {
            needUpdatConvLastMsg = NO;
        }
    }
    
    if (needUpdatConvLastMsg) {
        
        // 取出最近一条消息的消息时间
        NSDictionary *dic = [self getConvMsgTime:convId andType:1];
        
        if (dic != nil) {
            //        不保存新的last_msg_time
            NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_emp_id =?, last_msg_type = ?,display_flag = 0 where conv_id =? "
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
                pthread_mutex_lock(&add_mutex);
                
                sqlite3_bind_int(stmt, 1,[[dic valueForKey:@"id"]intValue]);//last_msg_id
                
                //			如果是长消息那么应该保存消息头，如果是文件消息则保存文件名字
                if([[dic valueForKey:@"msg_type"] intValue] == type_long_msg || [[dic valueForKey:@"msg_type"] intValue] == type_file)
                {
                    sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//last_msg_body
                }
                else
                {
                    sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"msg_body"] UTF8String],-1,NULL);//last_msg_body
                }
                //            sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
                sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"emp_id"] intValue]);//last_emp_id
                sqlite3_bind_int(stmt, 4, [[dic valueForKey:@"msg_type"] intValue]);//last_msg_type
                sqlite3_bind_text(stmt, 5, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
                
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
            NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_body = '',last_msg_type = %d where conv_id = '%@' ",table_conversation,type_text,convId];
            [self operateSql:sql Database:_handle toResult:nil];
        }
        
        dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
        [self sendNewConvNotification:dic andCmdType:delete_one_msg];
    }
}

#pragma mark ===========如果将要新建的群组的人数 和 某个当前已经有的群组成员完全一致，就不需要新建了============
//根据群组id得到群组成员的所有id，并且要按照成员id的升序排列,每个id中间使用,分隔
-(NSString*)getConvEmpBy:(NSString *)convId
{
	NSMutableArray *emps = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select b.emp_id from %@ a,%@ b where b.conv_id = '%@' and b.is_valid = 0 and b.emp_id = a.emp_id order by b.emp_id",table_employee,table_conv_emp,convId];
    
	NSMutableArray *result = [self querySql:sql];
	
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"%d",[[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue]];
	//	查询在线的和离开的
	for(int i=1;i<[result count];i++)
	{
       [mStr appendFormat:@",%d",[[[result objectAtIndex:i]valueForKey:@"emp_id"]intValue]];
    }
//    NSLog(@"%@",mStr);
    return mStr;
}

//讨论组成员数组
//查找有没有用户自己创建的，讨论组成员和参数一致的会话，如果有，那么直接返回这个会话的会话id，如果没有则返回nil
-(Conversation *)searchConvsationByConvEmps:(NSMutableArray *)convEmps
{
    int empCount = convEmps.count;
    convEmps = [convEmps sortedArrayUsingSelector:@selector(compareByEmpId:)];
    NSMutableString *convEmpIdStr =  [NSMutableString stringWithString:[StringUtil getStringValue:((Emp *)[convEmps objectAtIndex:0]).emp_id]];
    
	//	查询在线的和离开的
	for(int i=1;i<[convEmps count];i++)
	{
        [convEmpIdStr appendFormat:@",%@",[StringUtil getStringValue:((Emp *)[convEmps objectAtIndex:i]).emp_id]];
    }
    
//    NSLog(@"%@",convEmpIdStr);

    NSString *tempStr;
    
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"select a.conv_id as _conv_id ,count(a.emp_id) as _count from %@ a,%@ b,%@ c where b.create_emp_id = %@ and b.conv_type = %d and b.conv_id = a.conv_id and a.is_valid = 0 and  a.emp_id = c.emp_id group by _conv_id order by b.last_msg_time desc",table_conv_emp,table_conversation,table_employee,_conn.userId,mutiableType];
    
    NSMutableArray *result = [self querySql:sql];
    
    for (NSDictionary *dic in result)
    {
        if (empCount == [[dic valueForKey:@"_count"]intValue])
        {
            tempStr = [self getConvEmpBy:[dic valueForKey:@"_conv_id"]];
            
            if ([tempStr isEqualToString:convEmpIdStr])
            {
                sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' ",table_conversation,[dic valueForKey:@"_conv_id"]];
                result = [self querySql:sql];
                
                NSDictionary *dic = [result objectAtIndex:0];
                
                Conversation *conv = [self getConversationByDicData:dic];
                
                if ([[dic valueForKey:@"display_flag"]intValue] == 1) {
                    [self updateDisplayFlag:conv.conv_id andFlag:0];
                }

                dic = [NSDictionary dictionaryWithObjectsAndKeys:conv.conv_id,@"conv_id", nil];
                [self sendNewConvNotification:dic andCmdType:reuse_conversation];
 
                return conv;
            }
        }
    }
    return nil;
}


//根据消息ID和emp_ID搜索具体的消息
-(NSArray *)searchConvRecordByMsgId:(NSString *)msgId userId:(int)userId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where origin_msg_id LIKE '%@%%' and emp_id = %d order by msg_time desc",table_conv_records,msgId,userId];
    
    
    NSArray *result = [self querySql:sql];
    
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (NSDictionary *dic in result) {
        ConvRecord *_convRecord = [self getConvRecordByDicData:dic];
        
        [talkSessionUtil preProcessRobotMsg:_convRecord];
        [talkSessionUtil preProcessTextMsg:_convRecord];
        
        [mArray addObject:_convRecord];
    }
    
    return mArray;
}

- (int)getMsgCountFromConvRecord:(ConvRecord *)convRecord
{
    NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.msg_time >= %d and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time",table_conv_records,table_employee,table_conversation,convRecord.conv_id,convRecord.msg_time.intValue];
    
    
    NSArray *result = [self querySql:sql];
    int _count = 0;
    if([result count] > 0)
    {
        _count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
    }
    
    return _count;
}

//根据会话id，得到能够展示在会话列表里的Conversation对象
- (Conversation *)getConversationByConvId:(NSString *)convId
{

    NSString *sql = [NSString stringWithFormat:@"select *,'N' as display_merge_logo from %@ where conv_id = '%@' and display_flag = 0",table_conversation,convId];
    NSMutableArray *result = [self querySql:sql];
    if(result &&[result count]>0)
    {
        return [[self getConvListByResult:result]objectAtIndex:0];
    }
    return nil;
}

- (void)sendNewConvNotification:(NSDictionary *)info andCmdType:(int)cmdType
{
    eCloudNotification *_notification = [[[eCloudNotification alloc]init]autorelease];
    _notification.cmdId = cmdType;
    _notification.info = info;

    [[NotificationUtil getUtil]sendNotificationWithName:NEW_CONVERSATION_NOTIFICATION andObject:_notification andUserInfo:nil];
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NEW_CONVERSATION_NOTIFICATION object:_notification];
//    conn *_conn = [conn getConn];
//    _conn.notificationObject = _notification;
//    _conn.notificationName = NEW_CONVERSATION_NOTIFICATION;
//    [_conn notifyMessage:nil];
    
//    [_notification release];
}

#pragma mark ===========设置置顶或取消置顶=============

//
- (int)SetTopFlag:(int)setTopFlag andConv:(NSString *)convId
{
    conn *_conn = [conn getConn];
    int setTopTime = [_conn getCurrentTime];
    NSString *sql;
    if (setTopFlag == 0) {
        sql = [NSString stringWithFormat:@"update %@ set is_set_top = 0 where conv_id = '%@'",table_conversation,convId];
    }
    else
    {
        sql = [NSString stringWithFormat:@"update %@ set is_set_top = 1,set_top_time = %d where conv_id = '%@'",table_conversation,setTopTime,convId];
    }
    
    [self operateSql:sql Database:_handle toResult:nil];
    
    NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[NSNumber numberWithInt:setTopFlag ],@"setTop_Flag", nil];
    
    [self sendNewConvNotification:_dic andCmdType:update_isSet_top];
    return setTopTime;
}

#pragma mark ============修改群组成员的屏蔽状态和是否管理员=============

- (void)setRcvMsgFlagOfConv:(NSString *)convId andEmp:(int)empId andFlag:(int)rcvMsgFlag
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set rcv_msg_flag = %d where conv_id = '%@' and emp_id = %d",table_conv_emp,rcvMsgFlag,convId,empId];
    [self operateSql:sql Database:_handle toResult:nil];
}

- (void)setAdminFlagOfConv:(NSString *)convId andEmp:(int)empId andFlag:(int)adminFlag
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set is_admin = %d where conv_id = '%@' and emp_id = %d",table_conv_emp,adminFlag,convId,empId];
    [self operateSql:sql Database:_handle toResult:nil];
}

- (int)getAdminFlagOfConv:(NSString *)convId andEmp:(int)empId
{
    NSString *sql = [NSString stringWithFormat:@"select is_admin from %@ where conv_id = '%@' and emp_id = %d",table_conv_emp,convId,empId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return 0;
    }
    return [[[result objectAtIndex:0]valueForKey:@"is_admin"]intValue];
}

#pragma mark ============修改和获取讨论组的类型，可以是普通群组，也可以是固定群组和常用群组=============
- (void)updateGroupTypeOfConv:(NSString *)convId andGroupType:(int)groupType
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set group_type = %d where conv_id = '%@' and conv_type = %d",table_conversation,groupType,convId,mutiableType];
    [self operateSql:sql Database:_handle toResult:nil];
}

- (int)getGroupTypeOfConv:(NSString *)convId
{
    NSString *sql = [NSString stringWithFormat:@"select group_type from %@ where conv_id = '%@'",table_conversation,convId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        return [[[result objectAtIndex:0]valueForKey:@"group_type"]intValue];
    }
    return normal_group_type;
}

//判断群组成员中是否包含某用户，如果包含
-(BOOL)isExistInConvWithEmpId:(NSString *)empId andConvId:(NSString*)convId
{
    //    要判断是否有效
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = '%@' and emp_id = %@ and is_valid = 0 ",table_conv_emp,convId,empId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && result.count > 0)
    {
//        NSLog(@"%s在群组成员中",__FUNCTION__);
        return YES;
    }
	return NO;
}

//删除所以测试数据
- (void)deleteTestData
{
    [self deleteAllConversation];
//    
//    NSString *sql = [NSString stringWithFormat:@"select conv_id from %@ where conv_id like 'test%'",table_conversation];
//    NSMutableArray *result = [self querySql:sql];
//    for (NSDictionary *dic in result) {
//        NSString *convId = [dic valueForKey:@"conv_id"];
//        [self deleteConvAndConvRecordsBy:convId];
//    }
}


-(void)addConvRecord_temp_test:(NSArray *)info
{
	if ([self beginTransaction])
    {
        for (NSDictionary *dic in info) {
            
            //如果前缀是换行，回车或空格字符，则不显示，如果后缀是换行，回车或空格字符，也不显示
            NSString *msgBody = [dic valueForKey:@"msg_body"];
            
            
            //		[LogUtil debug:[NSString stringWithFormat:@"%@",[dic description]]];
            //			如果是发送的消息，那么就需要重新生成msg_id
            //		增加了同步消息功能后，应该是判断如果消息id为空，才生成消息id
            NSString *_sendOriginMsgId = [dic valueForKey:@"origin_msg_id"];
            
            NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,emp_id,msg_type,msg_body,msg_time,read_flag,msg_flag,send_flag,file_size,file_name,origin_msg_id,is_set_redstate,receipt_msg_flag,read_notice_flag) values(?,?,?,?,?,?,?,?,?,?,?,?,?,0)",table_conv_records];
            
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
                [self rollbackTransaction];
                return;
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
            sqlite3_bind_text(stmt,9,[[dic valueForKey:@"file_size"] UTF8String],-1,NULL);//file_size
            sqlite3_bind_text(stmt,10,[[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//file_name
            sqlite3_bind_text(stmt,11,[_sendOriginMsgId UTF8String],-1,NULL);//origin_msg_id
            //		sqlite3_bind_int64(stmt, 11, [_sendOriginMsgId longLongValue]);//origin_msg_id
            sqlite3_bind_int(stmt,12,[[dic valueForKey:@"is_set_redstate"] intValue]);//is_set_redstate
            sqlite3_bind_int(stmt,13,[[dic valueForKey:@"receipt_msg_flag"] intValue]);//is_set_redstate
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
                [self rollbackTransaction];
                return;
            }
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
           
        }
        
        [self commitTransaction];
    }
}

#pragma mark ==========群组合成头像部分的数据库操作============

//处理群组头像的逻辑
- (void)processAboutGroupMergedLogoWithConversation:(Conversation *)conv andDicData:(NSDictionary *)dic
{
    //    如果是群聊,需要确定是否显示合成头像，需要确定合成头像是否存在，是否需要更新
    
    if (conv.conv_type == mutiableType) {
        
        //        合成头像是否存在
        BOOL isMergeLogoExist = NO;
        
        //            检查头像是否存在
        NSString *mergedLogoPath = [StringUtil getMergedGroupLogoPathWithName:[StringUtil getDetailMergedGroupLogoName:conv]];
        if ([[NSFileManager defaultManager]fileExistsAtPath:mergedLogoPath]) {
            isMergeLogoExist = YES;
        }
        
        //        取出是否需要显示合成头像；一般会话列表不需要显示合成头像，但发现如果合成头像不存在或者需要更新，那么需要异步生成合成头像
        //        查询结果通常显示合成头像，如果合成头像不存在，也不能显示合成头像，如果存在，那么显示合成头像，同时异步生成合成头像
        
        NSString *displayMergeLogoStr = [dic valueForKey:@"display_merge_logo"];
        
        BOOL *needCreateMergeLogo = NO;
        
        if (displayMergeLogoStr && [displayMergeLogoStr isEqualToString:@"Y"])
        {
            conv.displayMergeLogo = YES;
            
            if (isMergeLogoExist == NO) {
                conv.displayMergeLogo = NO;
                needCreateMergeLogo = YES;
            }
        }
        else
        {
            conv.displayMergeLogo = NO;
            if (isMergeLogoExist == NO)
            {
                needCreateMergeLogo = YES;
            }
        }
        
        //        如果不显示合成头像
        if (!conv.displayMergeLogo ) {
            conv.groupLogoEmpArray = [self getGroupLogoEmpArrayBy:conv.conv_id];
            
            if (needCreateMergeLogo) {
                dispatch_queue_t _queue = dispatch_queue_create(@"create merge logo", NULL);
                dispatch_async(_queue, ^{
                    Conversation *tempConv = [[Conversation alloc]init];
                    tempConv.conv_id = conv.conv_id;
                    tempConv.conv_title = conv.conv_title;
                    tempConv.groupLogoEmpArray = conv.groupLogoEmpArray;
                    [Conversation mergedImageOfConv:tempConv];
                    [tempConv release];
                });
                dispatch_release(_queue);
            }
        }
    }
}

//如果有一个用户的头像修改了，需要重新合成用户所在的群组的头像
- (void)processWhenLogoChangeWithEmpId:(NSString *)empId
{
    //    查看此用户在哪些群里
    NSString *sql = [NSString stringWithFormat:@"select a.conv_id,b.conv_title from %@ a,%@ b where a.emp_id = %@ and a.is_valid = 0  and a.conv_id = b.conv_id and b.conv_type = %d",table_conv_emp,table_conversation,empId,mutiableType];
    
    NSMutableArray *result = [self querySql:sql];
    
    for (NSDictionary *dic in result)
    {
        NSString *convId = [dic valueForKey:@"conv_id"];
        NSString *convTitle = [dic valueForKey:@"conv_title"];
        
        [self asynCreateMergedLogoWithConvId:convId andConvTitle:convTitle];
    }
}

//根据群组id，群组title生成群组合成头像，群组title是记日志时使用
- (void)asynCreateMergedLogoWithConvId:(NSString *)convId andConvTitle:(NSString *)convTitle
{
    dispatch_queue_t _queue = dispatch_queue_create(@"create merged logo asyn", NULL);
    dispatch_async(_queue, ^{
        Conversation *tempConv = [[Conversation alloc]init];
        tempConv.conv_id = convId;
        tempConv.conv_title = convTitle;
        tempConv.groupLogoEmpArray = [self getGroupLogoEmpArrayBy:convId];
        [Conversation mergedImageOfConv:tempConv];
        [tempConv release];
    });
    dispatch_release(_queue);
}


//增加一个接口 获取某会话是否置顶,如果置顶返回yes，否则返回no
- (BOOL)isSetTopWithConvId:(NSString *)convId
{
    NSString *sql = [NSString stringWithFormat:@"select is_set_top from %@ where conv_id = '%@' ",table_conversation,convId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        int iSetTop = [[[result objectAtIndex:0]valueForKey:@"is_set_top"]intValue];
        if (iSetTop == 0) {
            return NO;
        }
        return YES;
    }
    return NO;
}

#pragma mark ========================文件助手增加的接口==========================
//去除body开始和结尾的空行
- (NSString *)removeBackspaceLineOfMsgBody:(NSString *)msgBody
{
    while ([msgBody hasPrefix:@"\n"])
    {
        msgBody = [msgBody substringFromIndex:1];
    }
    while ([msgBody hasPrefix:@"\r"])
    {
        msgBody = [msgBody substringFromIndex:1];
    }
    while ([msgBody hasSuffix:@"\n"])
    {
        msgBody = [msgBody substringToIndex:([msgBody length] - 1)];
    }
    while ([msgBody hasSuffix:@"\r"])
    {
        msgBody = [msgBody substringToIndex:([msgBody length] - 1)];
    }
    return msgBody;
}

#pragma mark - 获取所有文件消息记录
- (NSArray *)getFileConvRecordsWithLimit:(int)_limit andOffset:(int)_offset{
    NSMutableArray *records = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //    ,id 万达建议不增加id这个排序参数

   NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type ,c.conv_title from %@ a, %@ b,%@ c where a.msg_type = '%d' and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time desc limit(%d) offset(%d)",table_conv_records,table_employee,table_conversation,type_file,_limit,_offset];
    
//     NSString *sql = [NSString stringWithFormat:@"select a.*,b.conv_type,b.conv_title from %@ a, %@ b where a.msg_type = '%d'  and a.conv_id=b.conv_id  order by a.msg_time desc limit(%d) offset(%d)",table_conv_records,table_conversation,type_file,_limit,_offset];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
//    NSLog(@"result-----%@",result);
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [self getConvRecordByDicData:dic];
        [records addObject:record];
    }
    [pool release];
    return records;
}
//获取某个聊天的所有文件消息记录
-(NSArray *)getFileConvRecordsWithConvId:(NSString *)convId WithLimit:(int)_limit andOffset:(int)_offset
{
    NSMutableArray *records = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type ,c.conv_title from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.msg_type = '%d' and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time desc limit(%d) offset(%d)",table_conv_records,table_employee,table_conversation,convId,type_file,_limit,_offset];
    
    NSMutableArray *result = [self querySql:sql];
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [self getConvRecordByDicData:dic];
        [records addObject:record];
    }
    return records;
}


#pragma mark - 查询文件消息总的记录个数
-(int)getFileConvRecordsCount{
    int _count = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a where a.msg_type = '%d' and a.send_flag >= 0  ",table_conv_records,type_file];
    // [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if(result && [result count] == 1)
    {
        _count = [[[result objectAtIndex:0] objectForKey:@"_count"] intValue];
    }
    [pool release];
    return _count;
}

-(int)getFileConvRecordsCountWithConvId:(NSString *)convId
{
    int _count = 0;
    NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ a where a.conv_id = '%@' and a.msg_type = '%d' and a.send_flag >= 0  ",table_conv_records,convId,type_file];
    // [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
    NSMutableArray *result = [self querySql:sql];
    if(result && [result count] == 1)
    {
        _count = [[[result objectAtIndex:0] objectForKey:@"_count"] intValue];
    }
    return _count;
}


#pragma mark - 搜索文件消息
- (NSArray *)searchConvRecordsWithStr:(NSString *)searchStr{
    NSMutableArray *records = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //文件助手数据库
    NSString *tableName;
#ifdef _XIANGYUAN_FLAG_
    tableName = table_file_assistant;
#else
    tableName = table_conv_records;
#endif
    //按照文件名和会话名称查询
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.conv_type,b.conv_title from %@ a,%@ b where a.msg_type = '%d' and a.conv_id = b.conv_id and (trim(a.file_name)||trim(b.conv_title) like ?) order by msg_time desc",tableName,table_conversation,type_file];
    
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
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);

//    NSLog(@"result-----%@",result);
    for(int i=0;i<[result count];i++){
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [self getConvRecordByDicData:dic];
        [records addObject:record];
    }
    [pool release];
    return records;
}

/** 按照搜索条件 搜索文件名字 */
- (NSArray *)searchFileConvRecords:(NSString *)searchStr{
    NSMutableArray *records = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //按照文件名和会话名称查询
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.conv_type,b.conv_title,c.emp_name from %@ a,%@ b,%@ c where a.msg_type = '%d' and a.conv_id = b.conv_id and a.emp_id = c.emp_id and (trim(a.file_name) like ?) order by msg_time desc",table_conv_records,table_conversation,table_employee,type_file];
    
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
    sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%%%@%%",searchStr] UTF8String],-1,NULL);//search string
    
    NSMutableArray *result = [NSMutableArray array];
    [self packageStatement:stmt toArray:result];
    
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
    //    NSLog(@"result-----%@",result);
    for(int i=0;i<[result count];i++){
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [self getConvRecordByDicData:dic];
        [records addObject:record];
    }
    [pool release];
    return records;
}


#pragma mark - 服务器文件已过期,本地未下载改文件，此时标记该文件的所有记录为过期
- (void)setConvRecordsHasExpiredWithUrl:(NSString *)url{
    NSString *sql = [NSString stringWithFormat:@"update %@ set send_flag = '%d' where msg_body = '%@' and  msg_type = '%d'",table_conv_records,send_upload_nonexistent,url,type_file];
    [self operateSql:sql Database:_handle toResult:nil];
}


#pragma mark - 同一文件上传后，修改相应文件消息url
-(void)updateConvFileRecordWithOLdMSG:(NSString *)old_msg_body andMSG:(NSString*)msg_body andConvRecord:(ConvRecord *)_convRecord{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //根据url获取文件
    //    update by shisp 不再根据类型来查询，而是根据id和msg_body来查询
    NSString *sql = [NSString stringWithFormat:@"select id as msg_id from %@  where id = %d and msg_body = '%@' ",table_conv_records,_convRecord.msgId, old_msg_body];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    for(int i=0;i<[result count];i++){
        NSDictionary *dic = [result objectAtIndex:i];
        NSString *msgId = [dic objectForKey:@"msg_id"];
        
        //修改url
        NSString *sql = [NSString stringWithFormat:@"update %@ set msg_body = '%@' where id = '%@'",table_conv_records,msg_body,msgId];
        [self operateSql:sql Database:_handle toResult:nil];
    }
    [pool release];
}

//增加接口 保存离线消息
- (void)saveOfflineMsgs:(NSArray *)offlineMsgArray
{
    int startTime = [[StringUtil currentTime]intValue];
    
    NSMutableArray *originMsgIdArray = [NSMutableArray array];
    NSMutableDictionary *convIdMsgTimeDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *convIdMsgIdDic = [NSMutableDictionary dictionary];
    //    把离线的回执消息保存起来单独处理
    NSMutableArray *receiptMsgArray = [NSMutableArray array];

//    保存消息
    if ([self beginTransaction]) {
        
        for (NSDictionary *dic in offlineMsgArray) {
            NSString *msgBody = [dic valueForKey:@"msg_body"];
            msgBody = [self removeBackspaceLineOfMsgBody:msgBody];
            if (msgBody.length == 0) {
                continue;
            }
            
#ifdef _HUAXIA_FLAG_
            //    如果是华夏幸福，那么有几个账号的消息不用收，直接发送消息已收到即可
            NSString *sendId = [dic objectForKey:@"emp_id"];
            
            for (NSNumber *empId in not_save_msg_user_array) {
                if (sendId.intValue == empId.intValue) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s emp id is %d 不用保存此消息",__FUNCTION__,empId.intValue]];

                    continue;
                }
            }
#endif

            
#ifdef _LANGUANG_FLAG_
            
            /** 如果离线消息为红包信息，判断当前用户是否和红包消息相关的，如果不相关，就不保存这条消息，并不显示。适用于群组红包 */
            NSData* jsonData = [msgBody dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [jsonData objectFromJSONData];
            
            if ([resultDict[@"type"] isEqualToString:@"redPacketAction"]) {
                
                if ([[conn getConn].userId isEqualToString:resultDict[@"guestId"]] || [[conn getConn].userId isEqualToString:resultDict[@"hostId"]]) {
                    
                }else{
                    continue;
                }
            }
            
            /** 如果是待办消息，也不需要显示 */
            if ([resultDict[@"type"]isEqualToString:KEY_LANGUANG_DAIBAN_TYPE] || [resultDict[@"type"]isEqualToString:KEY_LANGUANG_MEETING_TYPE]) {
                
//                [[conn getConn] performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:resultDict waitUntilDone:YES];
                continue;
            }
            
            /** 如果是pc远程协助消息，不需要显示 */
            if ([resultDict[@"type"]isEqualToString:@"RDP"]) {
                
                continue;
            }
#endif
            
#ifdef _XIANGYUAN_FLAG_
            
            /** 祥源待办消息不显示在会话列表 */
            NSData* jsonData = [msgBody dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *_dic = [jsonData objectFromJSONData];
            
            NSString *type = [NSString stringWithFormat:@"%@",_dic[@"msgType"]];
            
            if ([type isEqualToString:KEY_XY_DAIBAN_MSG_TYPE] || [type isEqualToString:KEY_XY_TONGGAO_MSG_TYPE]) {
                
                if ([ApplicationManager getManager].startAppByClickAppNotificatin) {
                    
                    [LogUtil debug:[NSString stringWithFormat:@"%s 用户是点击应用通知进入应用的，不弹出离线通知",__FUNCTION__]];
                    
                }else{
                    [[conn getConn] performSelectorOnMainThread:@selector(presentNotificationWhenAppActive:) withObject:_dic waitUntilDone:YES];
                }
                
                [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_REFRESH_COUNT andObject:nil andUserInfo:_dic];
                continue;
                
            }else if ([type isEqualToString:KEY_XY_DAIBAN_UNREAD_TYPE]) {
                
                [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_REFRESH_COUNT andObject:nil andUserInfo:_dic];
                continue;
            }
            
            
            
#endif
            NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,emp_id,msg_type,msg_body,msg_time,read_flag,msg_flag,send_flag,file_size,file_name,origin_msg_id,is_set_redstate,receipt_msg_flag,read_notice_flag) values(?,?,?,?,?,?,?,?,?,?,?,?,?,0)",table_conv_records];
            
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
                continue;
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
            sqlite3_bind_text(stmt,9,[[dic valueForKey:@"file_size"] UTF8String],-1,NULL);//file_size
            sqlite3_bind_text(stmt,10,[[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//file_name
            sqlite3_bind_text(stmt,11,[[dic valueForKey:@"origin_msg_id"] UTF8String],-1,NULL);//origin_msg_id
            //		sqlite3_bind_int64(stmt, 11, [_sendOriginMsgId longLongValue]);//origin_msg_id
            sqlite3_bind_int(stmt,12,[[dic valueForKey:@"is_set_redstate"] intValue]);//is_set_redstate
            sqlite3_bind_int(stmt,13,[[dic valueForKey:@"receipt_msg_flag"] intValue]);//is_set_redstate
            //	执行
            state = sqlite3_step(stmt);
            
            pthread_mutex_unlock(&add_mutex);
            //	执行结果
            if(state != SQLITE_DONE &&  state != SQLITE_OK)
            {
                //			执行错误
//                [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
                //释放资源
                pthread_mutex_lock(&add_mutex);
                sqlite3_finalize(stmt);
                pthread_mutex_unlock(&add_mutex);
                continue;
            }
            //释放资源
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(stmt);
            pthread_mutex_unlock(&add_mutex);
            
            //            判断如果是回执消息那么保存到数组
            int receiptMsgFlag = [[dic valueForKey:@"receipt_msg_flag"] intValue];
            if (receiptMsgFlag == conv_status_receipt || receiptMsgFlag == conv_status_huizhi) {
                [receiptMsgArray addObject:dic];
            }

            NSString *convId = [dic valueForKey:@"conv_id"];
            NSString *originMsgId = [dic valueForKey:@"origin_msg_id"];
            NSString *msgTime = [dic valueForKey:@"msg_time"];
            
//            NSLog(@"convId %@, origin msg id %@,msgTime %@",convId,originMsgId,msgTime);
            
//            没有报错的情况下，记录origin_msg_id 这些原始的msgid
            [originMsgIdArray addObject:originMsgId];
            
//           保存会话的最后一条消息的时间，和对应的msgId
            
            BOOL needSaveTimeAndId = NO;
            
            NSString *timeStr = [convIdMsgTimeDic valueForKey:convId];
            
            if (timeStr.length > 0) {
//                    和这次的time比较
                if ([timeStr compare:msgTime] == NSOrderedAscending) {
                    needSaveTimeAndId = YES;
                }
            }
            else
            {
                needSaveTimeAndId = YES;
            }
            
            if (needSaveTimeAndId) {
                [convIdMsgTimeDic setValue:msgTime forKey:convId];
                [convIdMsgIdDic setValue:originMsgId forKey:convId];
            }
//            文件助手数据库
#ifdef _XIANGYUAN_FLAG_
            
            if ([[dic objectForKey:@"msg_type"] integerValue] == type_file) {
                [[FileAssistantRecordDOA getFileDatabase]addOneFileRecord:dic];
                
            }
#endif

        }
        [self commitTransaction];
    }
    
//    NSLog(@"%@,%@",[convIdMsgTimeDic description],[convIdMsgIdDic description]);
    
//修改会话的最后一条消息
    {
        NSMutableString *mStr = [NSMutableString string];
        for (NSString *convId in convIdMsgIdDic.allKeys)
        {
            NSString *originMsgId = [convIdMsgIdDic valueForKey:convId];
            [mStr appendString:[NSString stringWithFormat:@"'%@',",originMsgId]];
        }
        if (mStr.length > 0) {
            mStr = [mStr substringToIndex:mStr.length - 1];
            NSString *sql = [NSString stringWithFormat:@"select * from %@ where origin_msg_id in (%@)",table_conv_records,mStr];
            NSMutableArray *result = [self querySql:sql];
            if (result.count > 0) {
                if ([self beginTransaction]) {
                    for (NSDictionary *dic in result) {
                        //        不保存新的last_msg_time
                        NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_emp_id =?, last_msg_type = ?,display_flag = 0,last_msg_time = ? where conv_id =? ",table_conversation];
                        
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
                            pthread_mutex_lock(&add_mutex);
                            
                            sqlite3_bind_int(stmt, 1,[[dic valueForKey:@"id"]intValue]);//last_msg_id
                            
                            //			如果是长消息那么应该保存消息头，如果是文件消息则保存文件名字
                            if([[dic valueForKey:@"msg_type"] intValue] == type_long_msg || [[dic valueForKey:@"msg_type"] intValue] == type_file)
                            {
                                sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//last_msg_body
                            }
                            else
                            {
                                sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"msg_body"] UTF8String],-1,NULL);//last_msg_body
                            }
                            //            sqlite3_bind_text(stmt, 3, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//last_msg_time
                            sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"emp_id"] intValue]);//last_emp_id
                            sqlite3_bind_int(stmt, 4, [[dic valueForKey:@"msg_type"] intValue]);//last_msg_type
                            sqlite3_bind_text(stmt, 5, [[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//conv_id
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
                    [self commitTransaction];
                }
            }
        }
    }

//    把离线消息保存起来
    {
        NSMutableString *mStr = [NSMutableString string];
        for (NSString *originMsgId in originMsgIdArray) {
            [mStr appendString:[NSString stringWithFormat:@"'%@',",originMsgId]];
        }
        
        if (mStr.length > 0) {
            mStr = [mStr substringToIndex:mStr.length - 1];
#ifdef _LANGUANG_FLAG_
//            需要判断处理离线的密聊消息
            NSString *sql = [NSString stringWithFormat:@"select conv_id,id as msg_id,msg_flag from %@ where origin_msg_id in (%@)",table_conv_records,mStr];
            NSMutableArray *result = [self querySql:sql];
            conn *_conn = [conn getConn];
            _conn.offLineMsgs = [NSMutableArray arrayWithArray:result];
            
            for (NSDictionary *dic in result) {
                if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:dic[@"conv_id"]]) {
                    
                    //            保存在密聊消息表
                    if ([dic[@"msg_flag"] intValue] == rcv_msg ) {
                        [self saveMiLiaoMsg:[dic[@"msg_id"]intValue]];
                    }
                    
                    ConvRecord *convRecord = [self getConvRecordByMsgId:dic[@"msg_id"]];
                    
                    [[MiLiaoUtilArc getUtil]addToMiLiaoMsgArray:convRecord];
                }

            }
            
#else
            NSString *sql = [NSString stringWithFormat:@"select conv_id,id as msg_id from %@ where origin_msg_id in (%@)",table_conv_records,mStr];
            NSMutableArray *result = [self querySql:sql];
            conn *_conn = [conn getConn];
            _conn.offLineMsgs = [NSMutableArray arrayWithArray:result];
            
#endif
//            NSLog(@"%@",_conn.offLineMsgs);
        }
    }
    
//
    {
        MsgConn *msgConn = [MsgConn getConn];
        if (msgConn.msgReadArray.count > 0) {
            [self updateMsgReadFlag:msgConn.msgReadArray];
        }
    }
    
    [self processReceiptMsgArray:receiptMsgArray];

    
    //    从pc同步过来的离线的钉消息，有可能还没有保存就收到了已读，处理这种情况
    conn *_conn = [conn getConn];
    if (_conn.noProcessMsgReadNotice.count)
    {
        for (NSDictionary *dic in _conn.noProcessMsgReadNotice) {
            NSString *originMsgId = dic[@"origin_msg_id"];
            int empId = [dic[@"emp_id"]intValue];
            int readTime = [dic[@"read_time"]intValue];
            int receiverEmpId = [dic[@"receiver_emp_id"]intValue];
            
            //查询数据库，取出对应的id
            NSArray *msgIdArray = [self getMsgIdArrayByOriginMsgId:originMsgId andSenderId:receiverEmpId];
            
            if (msgIdArray.count == 0) {
                [LogUtil debug:@"离线消息已经保存完毕，但还是没能找到已读通知对应的消息"];
                continue;
            }
            
            for (NSString *msgId in msgIdArray) {
                [[ReceiptDAO getDataBase]updateMsgReadState:msgId.intValue andEmpId:empId andReadTime:readTime];
                
                //	发送通知
                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                _notificationObject.cmdId = msg_read_notice;
                _notificationObject.info = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"MSG_ID", nil];
                
                [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            }
            
        }
    }

    [LogUtil debug:[NSString stringWithFormat:@"保存离线消息需要时间:%d",[[StringUtil currentTime]intValue] - startTime]];
}


// 处理同步过来的离线的回执消息
- (void)processReceiptMsgArray:(NSArray *)receiptMsgArray
{
    for (NSDictionary *dic in receiptMsgArray) {
        NSString *originMsgId = [dic valueForKey:@"origin_msg_id"];
        int msgFlag = [[dic valueForKey:@"msg_flag"]intValue];
        
        if (msgFlag == send_msg) {
            NSString *sql = [NSString stringWithFormat:@"select id from %@ where origin_msg_id = '%@' and emp_id = %@ ",table_conv_records,originMsgId,[conn getConn].userId];
            NSMutableArray *result = [self querySql:sql];;
            if (result.count > 0) {
                int msgId = [[result[0] valueForKey:@"id"]intValue];
                [self processReceiptMsg:dic andMsgId:msgId];
            }
        }
    }
}

//修改未读为已读 add by shisp
- (void)updateMsgReadFlag:(NSArray *)msgReadArray
{
    for (NSDictionary *dic in msgReadArray) {
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0 where conv_id = '%@' and read_flag = 1 and msg_time <= %d",table_conv_records,[dic valueForKey:@"conv_id"],[[dic valueForKey:@"msg_timestamp"]intValue]];

        pthread_mutex_lock(&add_mutex);
        
        char *errorMessage;
        int resultCode = sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        [LogUtil debug:[NSString stringWithFormat:@"%s result is %d",__FUNCTION__,resultCode]];
        
        pthread_mutex_unlock(&add_mutex);
        
    }
}

//查看每个群组现在的未读消息数
- (NSArray *)getUnreadMsgCountOfMsgReadArray:(NSArray *)array
{
//    先默认
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (NSDictionary *_dic in array) {
        NSString *convId = [_dic valueForKey:@"conv_id"];
        if (convId) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            [mDic setValue:convId forKey:@"conv_id"];
            
            NSString *sql = [NSString stringWithFormat:@"select count(*) as unread_msg_count from %@ where conv_id = '%@' and read_flag = 1 ",table_conv_records,convId];
            NSMutableArray *result = [self querySql:sql];
            int unreadMsgCount = 0;
            if (result.count > 0) {
                unreadMsgCount = [[[result objectAtIndex:0]valueForKey:@"unread_msg_count"]intValue];
            }
            [mDic setValue:[NSNumber numberWithInt:unreadMsgCount] forKey:@"unread_msg_count"];
            [mArray addObject:mDic];
        }
    }
    
    return mArray;
}

//增加一个方法，根据原始的msgid,得到对应的会话id 和 本地的消息id
-(NSDictionary *)getMsgInfoByOriginMsgId:(NSString *)_originMsgId
{
    NSString *msgId = nil;
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"select id as MSG_ID,conv_id from %@ where emp_id = %@ and origin_msg_id = %@",table_conv_records,_conn.userId,_originMsgId];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    if(result && result.count == 1)
    {
        return [result objectAtIndex:0];
    }
    return nil;
}

//消息撤回成功后，把这条消息修改为一条群组通知消息，并且删除对应的资源
- (BOOL)recallMsgWithMsgId:(NSString *)msgId
{
    [LogUtil debug:[NSString stringWithFormat:@"%s msgId is %@",__FUNCTION__,msgId]];
    conn *_conn = [conn getConn];
    
    NSString *convId = nil;
    
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code from %@ a ,%@ b where id = %@  and a.emp_id = b.emp_id ",table_conv_records,table_employee,msgId];
    NSMutableArray *result = [self querySql:sql];

//    删除对应的文件
    if (result.count) {
        NSDictionary *dic = [result objectAtIndex:0];

        [dic setValue:[NSNumber numberWithInt:delete_type_one_msg] forKey:KEY_DELETE_TYPE];
        [self deleteMsgFile:dic];
        convId = [dic valueForKey:@"conv_id"];
        
        NSString *msgBody = nil;
        if ([[dic valueForKey:@"emp_id"]intValue] == _conn.userId.intValue) {
            msgBody = [StringUtil getLocalizableString:@"you_have_recall_a_message"];
        }else
        {
            Emp *emp = [[[Emp alloc]init]autorelease];
            emp.emp_name = [dic valueForKey:@"emp_name"];
            emp.empNameEng = [dic valueForKey:@"emp_name_eng"];
            msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"xxx_has_recalled_a_message"],emp.emp_name];
        }
        
        sql = [NSString stringWithFormat:@"update %@ set msg_type = %d,msg_body = '%@',read_flag = 0,receipt_msg_flag = %d where id = %@ ",table_conv_records,type_group_info,msgBody,conv_status_normal,msgId];
        BOOL result = [self operateSql:sql Database:_handle toResult:nil];
        
        if ([[dic valueForKey:@"read_flag"]intValue] == 1) {
//            如果撤回的是未读消息，那么需要发送通知，这样会话列表的未读数才能刷新
            [self sendNewConvNotification:dic andCmdType:read_one_msg];
        }
        
//        看下是否是本会话的最后一条消息，如果是也要进行相应的修改
        [self updateConvLastRecord:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[NSNumber numberWithInt:msgId.intValue],@"msg_id", nil]];

        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = recall_msg_success;
        _notificationObject.info = [NSDictionary dictionaryWithObject:msgId forKey:KEY_RECALL_MSG_ID];
        
        [[NotificationUtil getUtil]sendNotificationWithName:RECALL_MSG_RESULT_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

        return result;
    }
    return NO;
}

#pragma mark 获取某个会话的所有新消息的数量 还有未读的@消息和回执消息
-(NSDictionary *)getNewPinMsgs:(NSString *)convId
{
    //    查询收到的消息 未读的消息 本会话的消息
    NSMutableArray *records = [NSMutableArray array];
    
//    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id = '%@' and read_flag = 1 and msg_flag = 1 and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time",table_conv_records,table_employee,table_conversation,convId];

//    首先取出第一条未读的收到的消息，然后再取出这条消息以后的消息
    NSString *sql = [NSString stringWithFormat:@"select msg_time from %@ a, %@ b,%@ c where a.conv_id = '%@' and read_flag = 1 and msg_flag = 1 and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time limit (1)",table_conv_records,table_employee,table_conversation,convId];
    
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count) {
//        有未读消息
        int msgTime = [[result[0] valueForKey:@"msg_time"]intValue];
        sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.emp_id=b.emp_id and a.conv_id=c.conv_id and msg_time >= '%d' order by msg_time",table_conv_records,table_employee,table_conversation,convId,msgTime];
        result = [self querySql:sql];
    }
    
    BOOL includeSystemGroupAdminMsg = NO;
    NSDictionary *allAdminDic = nil;
    BOOL *isSystemGroup = NO;
    
    if ([UIAdapterUtil isCsairApp]) {
        includeSystemGroupAdminMsg = YES;
        isSystemGroup = [[UserDataDAO getDatabase]isSystemGroup:convId];
        if (isSystemGroup) {
            allAdminDic = [[UserDataDAO getDatabase]getAllAdminOfSystemGroup:convId];
        }
    }
    
//    NSMutableArray *result = [self querySql:sql];
    
    NSString *tipStr = [NSString stringWithFormat:@"@%@",[conn getConn].userName];
    
//    最后一条消息
    NSDictionary *firstDic = result.firstObject;
    
    for (NSDictionary *dic in result) {
        BOOL needSave = NO;
        int receiptMsgFlag = [[dic valueForKey:@"receipt_msg_flag"]intValue];
//        如果是南航版本，那么一呼百应消息也要特别显示
        if (receiptMsgFlag == conv_status_huizhi || (receiptMsgFlag == conv_status_receipt)) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 回执消息 或者 南航的一呼百应消息",__FUNCTION__]];

            needSave = YES;
        }else{
            int msgType = [[dic objectForKey:@"msg_type"]intValue];
            if (msgType == type_text ) {
                NSString *msgBody = [dic objectForKey:@"msg_body"];
                if ([msgBody rangeOfString:tipStr options:NSCaseInsensitiveSearch].length > 0) {
                    [LogUtil debug:[NSString stringWithFormat:@"%s 是@消息",__FUNCTION__]];
                    needSave = YES;
                }else{
                    if ([StringUtil isAtAllMsg:msgBody]) {
                        [LogUtil debug:[NSString stringWithFormat:@"%s 是@All消息",__FUNCTION__]];
                        needSave = YES;
                    }
                }
            }
        }
        
//        南航版本 固定群管理员发送的消息 也要特别显示
        if (!needSave && includeSystemGroupAdminMsg && isSystemGroup) {
            
            NSNumber *senderId = [dic valueForKey:@"emp_id"];
            if (allAdminDic[senderId]) {
                needSave = YES;
                [LogUtil debug:[NSString stringWithFormat:@"%s 是管理员发出的消息",__FUNCTION__]];
            }
        }
        
        if (!needSave) {
            if ([dic[@"id"]intValue] == [firstDic[@"id"]intValue]) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 第一条消息，也需要保存 ",__FUNCTION__]];
//                修改消息的内容和类型
                NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                mDic[@"msg_type"] = [NSNumber numberWithInt:type_text];
                mDic[@"msg_body"] = FIRST_NEW_MSG_TIPS;
                dic = [NSDictionary dictionaryWithDictionary:mDic];
                needSave = YES;
            }
        }
        
        if (needSave) {
            ConvRecord *record = [self getConvRecordByDicData:dic];
            [records addObject:record];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 未读消息数是:%d",__FUNCTION__,(int)result.count]];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:records,@"pin_msgs",[NSNumber numberWithInt:result.count],@"unread_msg_count", nil];
    return dic;
}

#pragma mark 发送未读消息数通知 给SDK调用程序接收
//发送未读消息数通知
- (void)sendUnreadMsgNumNotification
{
    //                    update by shisp 收到消息后，发出未读消息数变化通知，移动app接收通知，显示在会话tab
    int count = [self getAllNumNotReadedMessge];
    
    //    发出未读消息数通知
    [[NotificationUtil getUtil]sendNotificationWithName:IM_UNREAD_NOTIFICATION andObject:[NSNumber numberWithInt:count] andUserInfo:nil];
    
}

#pragma mark 南航要求保存 轻应用的提醒 ，现在获取轻应用提醒的总数 已经分页获取轻应用数据

- (int)getAppRemindTotalCount
{
    int count = 0;
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where broadcast_type = %d",table_broadcast,appNotice_broadcast];
    NSMutableArray *result = [self querySql:sql];
    if (result.count) {
        count = [[result[0] valueForKey:@"_count"]intValue];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s count is %d",__FUNCTION__,count]];
    return count;
}

//分页查询 应用提醒消息
-(NSArray *)getAppRemindsWithLimit:(int)_limit andOffset:(int)_offset
{
    NSMutableArray *records = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where broadcast_type = %d order by sendtime desc limit (%d) offset (%d)",table_broadcast,appNotice_broadcast,_limit,_offset];
    
    NSMutableArray *result = [self querySql:sql];
    
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        RemindModel *_model = [[[RemindModel alloc]init]autorelease];
        [self putDicData:dic toRemindModel:_model];
        [records addObject:_model];
    }
    return records;
}

- (void)putDicData:(NSDictionary *)dic toRemindModel:(RemindModel *)remindModel
{
//    提醒消息id
    NSString *remindMsgId = dic[@"msg_id"];
    remindModel.remindMsgId = remindMsgId;
    
//    发送系统 id
    NSString *senderId = dic[@"sender_id"];
    remindModel.fromSystem = senderId;
    
//    发送时间
    int sendTime = [dic[@"sendtime"]intValue];
    remindModel.remindTime = sendTime;
    
//    提醒标题
    NSString *title = dic[@"asz_titile"];
    remindModel.remindTitle = title;
    
    NSString *msgBody = dic[@"asz_message"];
    
    if ([UIAdapterUtil isCsairApp]) {
//        南航应用才需要这样处理 因为其它应用通知的内容是其它公司确定的
        NSDictionary *_dic = [msgBody objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        
//        一定要是字典类型
        if (_dic && [_dic isKindOfClass:[NSDictionary class]]) {
            //        推送类型
            NSNumber *appPushType = [_dic valueForKey:APP_PUSH_TYPE];
            if (appPushType) {
                remindModel.remindType = [appPushType intValue];
            }
            // 提醒详情
            NSString *detail = [_dic valueForKey:APP_PUSH_DETAIL];
            remindModel.remindDetail = detail;
            
            //        提醒URL
            NSString *url = [_dic valueForKey:APP_PUSH_URL];
            remindModel.remindURL = url;
        }
    }
}

#pragma mark 只删除会话
-(void)deleteConvOnly:(NSString*)convId
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where  conv_id='%@'",table_conversation,convId];
    [self operateSql:sql Database:_handle toResult:nil];

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
    [self sendNewConvNotification:dic andCmdType:delete_conversation];
    
}

#pragma mark 根据msgid找到提醒对应的model
- (RemindModel *)getRemindByMsgId:(NSString *)msgId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = %@",table_broadcast,msgId];
    
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count > 0) {
        RemindModel *_model = [[[RemindModel alloc]init]autorelease];
        [self putDicData:result[0] toRemindModel:_model];
        return _model;
    }
    return nil;
}

#pragma mark 根据msgid找到提醒对应的RemindDic
- (NSDictionary *)getRemindDicByMsgId:(NSString *)msgId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where msg_id = %@",table_broadcast,msgId];
    
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count > 0) {
        return [result firstObject];
    }
    
    return nil;
}

#pragma mark - 根据消息id删除提醒
- (void)deleteRemindWithMsgId:(NSString *)remindMsgId
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE msg_id = %@;",table_broadcast,remindMsgId];
    
    [self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark - 删除所有提醒
- (void)deleteAllRemaid
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE broadcast_type = %d;",table_broadcast,appNotice_broadcast];
    
    [self operateSql:sql Database:_handle toResult:nil];
}

- (void)updateLastConvRecordOfBroadcastConvType:(int)_broadcastConvType{
//根据类型找到会话id
    NSString *convId = [self getConvIdOfBroadcastConvType:_broadcastConvType];
    
    if (convId) {
//        取出最后一条消息
        Conversation *conv = [self getConversationByConvId:convId];
        
        int broadcastType = [BroadcastUtil getBroadcastTypeWithBroadcastConvType:_broadcastConvType];
        
        NSString *sql = [NSString stringWithFormat:@"select msg_id,asz_titile,sendtime,sender_id from %@ where broadcast_type = %d order by sendtime desc limit(1) ",table_broadcast,broadcastType];
        
        NSMutableArray *result = [self querySql:sql];
        
        NSString *lastMsgId;
        NSString *lastMessage;
        NSString *lastMessageTime;
        NSString *lastAppId;
        
        BOOL needUpdateLastConvMsg = NO;
        
        if (result.count) {
            NSDictionary *dic = result[0];
            lastMsgId = dic[@"msg_id"];
            lastMessage = dic[@"asz_titile"];
            lastMessageTime = dic[@"sendtime"];
            lastAppId = dic[@"sender_id"];
            
            if ([conv.last_record.msg_body rangeOfString:lastMessage].length && [conv.last_record.msg_time isEqualToString:lastMessageTime]) {
//                如果目前的最后一条已经是最新的，那么什么都不做，否则需要更新最后一条
            }else{
//                更新会话的最后一条消息的内容
                needUpdateLastConvMsg = YES;
            }
        }else{
//            如果所有消息都删除了，这时会话的最后一条消息也应该是空，但时间就保持不变
            if (conv.last_record.msg_body.length) {
//                需要修改会话最后一条消息为空
                needUpdateLastConvMsg = YES;
                lastMsgId = [StringUtil getStringValue:conv.last_record.msgId];
                lastMessageTime = conv.last_record.msg_time;
                lastMessage = @"";
            }
        }
        
        if (needUpdateLastConvMsg) {
            sql = [NSString stringWithFormat:@"update %@ set last_msg_id=? , last_msg_body = ?, last_msg_time=? , last_msg_type = %d,display_flag = 0 where conv_id = '%@'"
                   ,table_conversation,type_text,convId];
            
            sqlite3_stmt *stmt = nil;
            //编译
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
                //绑定值
                pthread_mutex_lock(&add_mutex);
                
                sqlite3_bind_int(stmt, 1,[lastMsgId intValue] );
                sqlite3_bind_text(stmt, 2, [lastMessage UTF8String],-1,NULL);
                
//                如果是国美app，并且最后一条消息不为空，那么在消息前面加上应用的名字
                if ([UIAdapterUtil isGOMEApp] && lastMessage.length) {
                    //                需要把应用名称附加在应用消息标题前面
                    APPListModel *appModel = [[APPPlatformDOA getDatabase]getAPPModelByAppid:lastAppId.integerValue];
                    if (appModel.appname.length) {
                        sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%@:%@",appModel.appname,lastMessage] UTF8String],-1,NULL);
                    }
                }

                sqlite3_bind_text(stmt, 3, [lastMessageTime UTF8String],-1,NULL);//last_msg_time
                //执行
                state = sqlite3_step(stmt);
                
                pthread_mutex_unlock(&add_mutex);
                //执行结果
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
        
        //更新会话 之所以发这个通知，是因为会话列表里处理这个通知时，会重新获取这条会话，显示在界面上
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
        [self sendNewConvNotification:dic andCmdType:add_new_conversation];

    }
}

- (NSString *)getConvTitleByConvId:(NSString *)convId
{
    NSString *sql = [NSString stringWithFormat:@"select conv_title from %@ where conv_id = '%@'",table_conversation,convId];
    
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count) {
        NSString *convTitle = [result[0] valueForKey:@"conv_title"];
        return convTitle;
    }
    return @"";
}

/** 查找某一个会话的群组通知类型的消息，如果通知里包含了用户id，那么替换为名字 */
- (void)searchAndReplaceGroupInfoInConv:(NSString *)convId andEmp:(Emp *)_emp{
    NSString *sql = [NSString stringWithFormat:@"select id,msg_body from %@ where conv_id = '%@' and msg_type = %d and msg_body like '%%%d%%'",table_conv_records,convId,type_group_info,_emp.emp_id];
    [LogUtil debug:[NSString stringWithFormat:@"%s sql is %@",__FUNCTION__,sql]];

    NSArray *result = [self querySql:sql];
    
    for (NSDictionary *_dic in result) {
        NSString *msgBody = _dic[@"msg_body"];
        msgBody = [msgBody stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\'%d\'",_emp.emp_id] withString:_emp.emp_name];
        
        int msgId = [_dic[@"id"]intValue];
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set msg_body = ? where id = %d",table_conv_records,msgId];
        
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
        sqlite3_bind_text(stmt, 1, [msgBody UTF8String],-1,NULL);//msgbody

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
            return;
        }
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        
        [LogUtil debug:[NSString stringWithFormat:@"%s sql is %@",__FUNCTION__,sql]];
    }
}

/** 查找所有的密聊消息 */
- (NSArray *)getAllMiLiaoMsgs
{
    NSMutableArray *records = [NSMutableArray array];
    //    ,id 万达建议不增加id这个排序参数
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_code,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type from %@ a, %@ b,%@ c where a.conv_id like '%@%%' and a.emp_id=b.emp_id and a.conv_id=c.conv_id",table_conv_records,table_employee,table_conversation,MILIAO_PRE];
    
    NSArray *result = [self querySql:sql];
    
    //    [LogUtil debug:[NSString stringWithFormat:@"%s result is %@",__FUNCTION__,result]];
    
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        NSLog(@"%@",dic);
        ConvRecord *record = [self getConvRecordByDicData:dic];
        
        if (record.msg_type == type_group_info) {
            continue;
        }
        if (record.msg_flag == send_msg && record.isHuiZhiMsgRead) {
            
//            已读的发送消息可以删除
            [self deleteOneMsg:[StringUtil getStringValue:record.msgId]];
            continue;
        }
        if (record.msg_flag == rcv_msg && record.readNoticeFlag == 1){
//        已经发送了已读通知的消息
            [self deleteOneMsg:[StringUtil getStringValue:record.msgId]];
            continue;
        }
        
        [records addObject:record];
    }
    //    NSLog(@"%s,需要时间:%d",__FUNCTION__,[StringUtil currentMillionSecond] - start);
    return records;

    
}

/** 获取所有密聊消息的未读数 */
- (int)getNewMiLiaoMsgNum{
    
    //获取所有的密聊会话
    NSString *convSql = [NSString stringWithFormat:@"select conv_id,conv_type from %@ where conv_type = %d and conv_id like '%@%%' and display_flag = 0 ",table_conversation,singleType,MILIAO_PRE];
    
    NSString *sql = [NSString stringWithFormat:@"select count(*) record_count from %@ a,(%@) b where read_flag = 1 and msg_flag = 1 and a.conv_id = b.conv_id",table_conv_records,convSql];

    NSArray *result = [self querySql:sql];
    
    if (result.count == 1) {
        return [[result[0] valueForKey:@"record_count"]intValue];
    }
    
    return 0;
}

/** 搜索收到过哪些人发的消息 */
- (NSDictionary *)getAllChatEmps{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    NSString *sql = [NSString stringWithFormat:@"select distinct(emp_id) from %@ where msg_flag = %d",table_conv_records,rcv_msg];
    NSArray *result = [self querySql:sql];
    
    for (NSDictionary *_dic in result) {
        [mDic setValue:@"1" forKey:[StringUtil getStringValue:[_dic[@"emp_id"]intValue]]];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 发来过消息的有这些用户:%@",__FUNCTION__,mDic]];

    return mDic;
}

#ifdef _LANGUANG_FLAG_
/** 查询某消息是否存在于密聊消息表 */
- (BOOL)isMiLiaoMsgExist:(int)_id{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where encrypt_msg_id = %d",table_encrypt_msg,_id];
    NSArray *result = [self querySql:sql];
    [LogUtil debug:[NSString stringWithFormat:@"%s 密聊消息是否存在%lu",__FUNCTION__,(unsigned long)result.count]];
    if (result.count) {
        return YES;
    }
    return NO;
}

/** 在密聊消息表里增加一条消息 _id是消息id */
- (void)saveMiLiaoMsg:(int)_id{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(encrypt_msg_id) values(%d)",table_encrypt_msg,_id];
    BOOL result = [self operateSql:sql Database:_handle toResult:nil];
    if (!result) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 保存密聊消息失败",__FUNCTION__]];
    }
}

/** 从密聊消息表里删除一条消息 */
- (void)deleteMiLiaoMsg:(int)_id{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where encrypt_msg_id = %d",table_encrypt_msg,_id];
    BOOL result = [self operateSql:sql Database:_handle toResult:nil];
    if (!result) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 删除密聊消息失败",__FUNCTION__]];
    }
}

/** 有没有他人还未读的密聊消息 */
- (BOOL)hasUnreadEncryptMsg:(NSString *)convId{
    NSString *sql = [NSString stringWithFormat:@"select id as msg_id from %@ where conv_id = '%@' and msg_flag = %d ",table_conv_records,convId,send_msg];
    NSArray *result = [self querySql:sql];
    for (NSDictionary *dic in result){
        int msgId = [dic[@"msg_id"]intValue];
        /** 搜索此消息是否收到了已读通知 */
        
        int totalCount = [[ReceiptDAO getDataBase] getTotalUserCountOfMsg:msgId];
        int readCount = [[ReceiptDAO getDataBase] getReadUserCountOfMsg:msgId];
        if (totalCount == readCount) {
            continue;
        }else{
            return YES;
        }
    }
    return NO;
}
#endif

//文件助手我的
//获取文件助手数据库所有数据
- (NSArray *)getFileAssistantConvRecordsWithLimit:(int)_limit andOffset:(int)_offset{
    NSMutableArray *records = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    //    ,id 万达建议不增加id这个排序参数
    
    
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type ,c.conv_title from %@ a, %@ b,%@ c where a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time desc limit(%d) offset(%d)",table_file_assistant,table_employee,table_conversation,_limit,_offset];
    
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    
    for(int i=0;i<[result count];i++)
    {
        NSDictionary *dic = [result objectAtIndex:i];
        ConvRecord *record = [self getConvRecordByDicData:dic];
        [records addObject:record];
    }
    [pool release];
    return records;
}


@end
