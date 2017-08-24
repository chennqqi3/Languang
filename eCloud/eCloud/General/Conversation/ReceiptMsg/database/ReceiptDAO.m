//
//  ReceiptDAO.m
//  eCloud
//
//  Created by Richard on 13-12-12.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ReceiptDAO.h"
#import "Emp.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"


static ReceiptDAO *receiptDAO;


@implementation ReceiptDAO

//用户发送一条重要消息，需要记录消息和每个的群组成员的已读状态记录
+(id)getDataBase
{
	if(receiptDAO == nil)
	{
		receiptDAO = [[ReceiptDAO alloc]init];
	}
	return receiptDAO;
}
//增加并初始化消息状态为未读
-(BOOL)addMsgReadState:(int)msgId andUserList:(NSArray*)userList
{
    int count = userList.count;
    if(count < 0)
        return NO;
    
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:count];
    NSString *sql;
    for(NSString *empId in userList)
    {
        conn *_conn = [conn getConn];
        if(empId.intValue == _conn.userId.intValue)
        {
            continue;
        }
        //		首先查询对应的emp_id是否已经存在，如果已经存在就不再插入
        sql = [NSString stringWithFormat:@"select emp_id from %@ where msg_id = %d and emp_id = %@",table_msg_read_state,msgId,empId];
        NSMutableArray *result = [self querySql:sql];
        if (result.count > 0) {
            continue;
        }
        sql = [NSString stringWithFormat:@"insert into %@(msg_id,emp_id,read_flag) values(%d,%@,0)",table_msg_read_state,msgId,empId];
        [sqlArray addObject:sql];
    }
    
    if([self beginTransaction])
    {
        char *errorMessage;
        
        for(NSString *_sql in sqlArray)
        {
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [_sql UTF8String], NULL, NULL, &errorMessage);
            pthread_mutex_unlock(&add_mutex);
            
            if(errorMessage)
                [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        }
        [self commitTransaction];
        return YES;
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s 增加回执消息对应人员时开启事务失败，单个执行",__FUNCTION__]];

        for(NSString *_sql in sqlArray)
        {
            [self operateSql:_sql Database:_handle toResult:nil];
        }
        return YES;
    }
    return NO;
}

//修改消息状态为已读
-(void)updateMsgReadState:(int)msgId andEmpId:(int)empId andReadTime:(int)readTime
{
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(msg_id,emp_id,read_flag,read_time) values (%d,%d,1,%d)",table_msg_read_state,msgId,empId,readTime];
    [self operateSql:sql Database:_handle toResult:nil];
}

//统计消息的已读情况
-(NSString *)getReadStateOfMsg:(ConvRecord*)convRecord
{
	NSString *retStr = @"";

	int msgFlag = convRecord.msg_flag;
	if(msgFlag == rcv_msg)
	{
        if (convRecord.isReceiptMsg) {
            retStr = [StringUtil getLocalizableString:@"receipt_msg_tips_0"];
        }
        else if (convRecord.isHuizhiMsg)
        {
            //        如果回执已经发送，那么显示回执已发送
            //        否则显示发送回执
            //        1 表示已经发送了回执

            if (convRecord.readNoticeFlag == 1) {
                if ([UIAdapterUtil isTAIHEApp]) {
                    
                    retStr = [StringUtil getAppLocalizableString:@"TAI_HE_receipt_msg_receipt_is_send"];
                }else{
                    
                    retStr = [StringUtil getAppLocalizableString:@"receipt_msg_receipt_is_send"];
                }
                
            }
            else
            {
                retStr = [StringUtil getAppLocalizableString:@"receipt_msg_send_receipt"];
            }
        }
	}
	else
	{
		int msgId = convRecord.msgId;
		int totalCount = [self getTotalUserCountOfMsg:msgId];
		int readCount = [self getReadUserCountOfMsg:msgId];
		
		if(totalCount == 1)
		{
			//		单聊
			if(readCount == 0)
			{
                if (convRecord.isReceiptMsg) {
                    
                    NSString *tempStr1 = [StringUtil getLocalizableString:@"receipt_msg_tips_0"];
                    NSString *tempStr2 = [StringUtil getLocalizableString:@"receipt_msg_unread"];
                    
                    retStr = [NSString stringWithFormat:@"%@ %@",tempStr1,tempStr2];
                }
                else if (convRecord.isHuizhiMsg)
                {
                    if ([UIAdapterUtil isTAIHEApp]) {
                        
                        retStr = [StringUtil getLocalizableString:@"TAI_HE_receipt_msg_unread"];
                        
                    }else{
                       
                        retStr = [StringUtil getLocalizableString:@"receipt_msg_unread"];
                    }
                }
			}
			else
			{
                if (convRecord.isReceiptMsg) {
                    
                    NSString *tempStr1 = [StringUtil getLocalizableString:@"receipt_msg_tips_0"];
                    NSString *tempStr2 = [StringUtil getLocalizableString:@"receipt_msg_read"];
                    
                    retStr = [NSString stringWithFormat:@"%@ %@",tempStr1,tempStr2];
                }
                else if (convRecord.isHuizhiMsg)
                {
                    if ([UIAdapterUtil isTAIHEApp]) {
                        
                        retStr = [StringUtil getLocalizableString:@"TAI_HE_receipt_msg_read"];
                        
                    }else{
                        
                        retStr = [StringUtil getLocalizableString:@"receipt_msg_read"];
                    }
                    
                }
//                设置为单聊消息已读
                convRecord.isHuiZhiMsgRead = YES;
			}
		}
		else
		{
            if (convRecord.isReceiptMsg) {
                NSString *tempStr = [StringUtil getLocalizableString:@"receipt_msg_tips_0"];
                retStr = [NSString stringWithFormat:@"%@  %d/%d",tempStr,readCount,totalCount];
            }
            else if (convRecord.isHuizhiMsg)
            {
                if (readCount == totalCount) {
                    if ([UIAdapterUtil isTAIHEApp]) {
                        
                        retStr = [StringUtil getLocalizableString:@"TAI_HE_receipt_msg_read"];
                        
                    }else{
                        
                        
                        retStr = [StringUtil getLocalizableString:@"receipt_msg_group_msg_all_read"];
                        
//                        retStr = [StringUtil getLocalizableString:@"receipt_msg_read"];
                    }
                    /** 设置群聊回执消息已读 */
                    convRecord.isHuiZhiMsgRead = YES;
                }
                else
                {
                    if ([UIAdapterUtil isTAIHEApp]) {
                        
                        retStr = [NSString stringWithFormat:[StringUtil getLocalizableString:@"TAI_HE_receipt_msg_tips_xx_unread"],readCount,totalCount];
                        
                    }else{
                        
                        retStr = [NSString stringWithFormat:[StringUtil getLocalizableString:@"receipt_msg_tips_xx_unread"],(totalCount - readCount)];
                    }
                    
                }
            }
		}
	}

	return retStr;
}

//获得一呼百应消息对应的总人数
-(int)getTotalUserCountOfMsg:(int)msgId
{
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where msg_id = %d",table_msg_read_state,msgId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int totalCount = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
	return totalCount;
}
//获得一呼百应消息对应的已读的人数
-(int)getReadUserCountOfMsg:(int)msgId
{
	NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where msg_id = %d and read_flag = 1",table_msg_read_state,msgId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	int readCount = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
	return readCount;
}

//根据msgId删除对应的记录
-(void)deleteReadStateOfMsg:(int)msgId
{
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where msg_id = %d",table_msg_read_state,msgId];
	[self operateSql:sql Database:_handle toResult:nil];
}

//查询已读或未读人员
-(NSArray *)getReceiptUser:(int)msgId andReadFlag:(int)readFlag
{
	NSMutableArray *receiptUser = [[[NSMutableArray alloc]init]autorelease];
	
	@autoreleasepool
	{
		NSMutableArray *result = [NSMutableArray array];
        
		conn *_conn = [conn getConn];
		if(_conn.userStatus == status_online)
		{
			//		先查询在线的
			NSString *sql = [NSString stringWithFormat:@"select a.read_time,b.emp_id,b.emp_name,b.emp_logo,b.emp_status,b.emp_sex,b.emp_login_type,b.emp_code,b.emp_name_eng from %@ a,%@ b where a.msg_id = %d and a.read_flag = %d and a.emp_id = b.emp_id and (b.emp_status = %d or b.emp_status = %d) order by b.emp_code",table_msg_read_state,table_employee,msgId,readFlag,status_online,status_leave];
			
			NSMutableArray *resultOnline = [NSMutableArray array];
			[self operateSql:sql Database:_handle toResult:resultOnline];
			
			[result addObjectsFromArray:resultOnline];
			
			sql = [NSString stringWithFormat:@"select a.read_time,b.emp_id,b.emp_name,b.emp_logo,b.emp_status,b.emp_sex,b.emp_login_type,b.emp_code,b.emp_name_eng from %@ a,%@ b where a.msg_id = %d and a.read_flag = %d and a.emp_id = b.emp_id and b.emp_status = %d order by b.emp_code",table_msg_read_state,table_employee,msgId,readFlag,status_offline];
			
			NSMutableArray *resultOffline = [NSMutableArray array];
			[self operateSql:sql Database:_handle toResult:resultOffline];
			
			[result addObjectsFromArray:resultOffline];
		}
		else
		{
			NSString *sql = [NSString stringWithFormat:@"select a.read_time,b.emp_id,b.emp_name,b.emp_logo,b.emp_status,b.emp_sex,b.emp_login_type,b.emp_code,b.emp_name_eng from %@ a,%@ b where a.msg_id = %d and a.read_flag = %d and a.emp_id = b.emp_id order by b.emp_code",table_msg_read_state,table_employee,msgId,readFlag];
			
			[self operateSql:sql Database:_handle toResult:result];
		}
		
		for(NSDictionary *dic in result)
		{
			Emp *_emp = [[Emp alloc]init];
			_emp.emp_id = [[dic valueForKey:@"emp_id"]intValue];
			_emp.emp_name = [dic valueForKey:@"emp_name"];
			_emp.emp_status = [[dic valueForKey:@"emp_status"]intValue];
			_emp.emp_logo = [dic valueForKey:@"emp_logo"];
			_emp.emp_sex = [[dic valueForKey:@"emp_sex"]intValue];
			_emp.msgReadTime = [[dic valueForKey:@"read_time"]intValue];
			_emp.loginType = [[dic valueForKey:@"emp_login_type"]intValue];
            _emp.empCode = [dic valueForKey:@"emp_code"];
            _emp.empNameEng = [dic valueForKey:@"emp_name_eng"];
			[receiptUser addObject:_emp];
			[_emp release];
		}
	}
	return receiptUser;
}

//根据会话id，查询会话的状态
-(int)getConvStatus:(NSString*)convId
{
	NSString *sql = [NSString stringWithFormat:@"select conv_status from %@ where conv_id = '%@' ",table_conv_status,convId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	if(result.count == 0)
	{
		sql = [NSString stringWithFormat:@"insert into %@(conv_id,conv_status) values('%@',0)",table_conv_status,convId];
		[self operateSql:sql Database:_handle toResult:nil];
		return conv_status_normal;
	}
	else
	{
		return [[[result objectAtIndex:0]valueForKey:@"conv_status"]intValue];
	}
}

//设置会话的状态
-(void)setConvStatus:(NSString*)convId andStatus:(int)convStatus
{
	NSString *sql = [NSString stringWithFormat:@"select conv_status from %@ where conv_id = '%@' ",table_conv_status,convId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	if(result.count == 0)
	{
		sql = [NSString stringWithFormat:@"insert into %@(conv_id,conv_status) values('%@',%d)",table_conv_status,convId,convStatus];
		[self operateSql:sql Database:_handle toResult:nil];
	}
	else
	{
		NSString *sql = [NSString stringWithFormat:@"update %@ set conv_status = %d where conv_id = '%@' ",table_conv_status,convStatus,convId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

//修改数据库，设置一呼百应消息已发送已读
-(void)updateMsgReadNoticeFlag:(NSArray*)msgIdArray
{
    for(NSString *msgId in msgIdArray)
    {
       	NSString *sql = [NSString stringWithFormat:@"update %@ set read_notice_flag = 1 where id = %@",table_conv_records,msgId];
        [self operateSql:sql Database:_handle toResult:nil]; 
    }
}

//获取所有已发送的回执消息
- (NSArray *)getReceiptMsgByconvID:(NSString *)convId
{
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_logo,b.emp_sex,b.emp_status,b.emp_login_type,c.conv_type ,c.conv_title from %@ a, %@ b,%@ c where a.conv_id = '%@' and a.receipt_msg_flag = %d and msg_flag = %d and a.emp_id=b.emp_id and a.conv_id=c.conv_id  order by msg_time desc",table_conv_records,table_employee,table_conversation,convId,conv_status_huizhi,send_msg];
    
    NSMutableArray *result = [self querySql:sql];
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:result.count];
    eCloudDAO *db = [eCloudDAO getDatabase];
    for(NSDictionary *dic in result)
    {
        ConvRecord *record = [db getConvRecordByDicData:dic];
        [mArr addObject:record];
    }
    return mArr;
}

@end
