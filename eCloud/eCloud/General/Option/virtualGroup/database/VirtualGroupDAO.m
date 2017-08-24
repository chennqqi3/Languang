//
//  VirtualGroupDAO.m
//  eCloud
//
//  Created by yanlei on 15/12/3.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "VirtualGroupDAO.h"
#import "talkSessionUtil2.h"
#import "eCloudDAO.h"
#import "eCloudDefine.h"
#import "conn.h"

static VirtualGroupDAO *virtualGroupDAO;

#define virtual_groupinfo_table_name @"virtual_groupinfo"
#define virtual_groupmember_table_name @"virtual_groupmember"

/* 虚拟组信息表
 `main_userid` int(4) NOT NULL COMMENT '虚拟组主账号',
 `groupid` varchar(20) COLLATE utf8_unicode_ci NOT NULL COMMENT '虚拟组ID',
 `member_num` int(2) NOT NULL DEFAULT '1' COMMENT '虚拟组成员个数',
 `single_svc_num` int(2) NOT NULL DEFAULT '1' COMMENT '单个成员支持人员上限',
 `timeout_minute` int(2) NOT NULL DEFAULT '3' COMMENT '服务过期时间，单位分钟',
 `waiting_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '等待提示语',
 `hangup_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '挂断提示语',
 `oncall_prompt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '接通提示语',
 `real_code` int(1) NOT NULL DEFAULT '0' COMMENT '是否显示真是账号 0不显示，非0显示',
 `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
 `update_type` int(1) NOT NULL DEFAULT '1',
 */

#define create_virtual_groupinfo_table @"create table if not exists virtual_groupinfo(main_userid integer,groupid text primary key,member_num integer default 1,single_svc_num integer default 1,timeout_minute integer default 3,waiting_prompt text,hangup_prompt text,oncall_prompt text,real_code integer default 0,update_time text,update_type integer default 1)"

/* 虚拟组成员表
 `groupid` varchar(20) COLLATE utf8_unicode_ci NOT NULL COMMENT '虚拟组ID',
 `userid` int(4) NOT NULL COMMENT '虚拟组成员ID',
 `svc_status` int(4) NOT NULL DEFAULT '1' COMMENT '虚拟组成员状态1 正常提供服务，2暂停服务',
 `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
 `update_type` int(1) NOT NULL DEFAULT '1',
 */
#define create_virtual_groupmember_table @"create table if not exists virtual_groupmember(groupid text,userid integer,svc_status integer default 1,update_time text,update_type integer default 1,constraint pk_groupmember primary key (groupid,userid))"

@implementation VirtualGroupDAO

#pragma mark - 创建虚拟组表的单例
+ (VirtualGroupDAO *)getDatabase
{
    if (!virtualGroupDAO) {
        virtualGroupDAO = [[super alloc]init];
    }
    return virtualGroupDAO;
}

#pragma mark - 创建虚拟组相关的表
- (void)createTable
{
    [self operateSql:create_virtual_groupmember_table Database:_handle toResult:nil];
    [self operateSql:create_virtual_groupinfo_table Database:_handle toResult:nil];
}

//- (void)saveVGroupInfo:(NSArray *)info

#pragma mark - 处理同步下来的虚拟组信息
- (void)saveSynVirtualGroupInfo:(NSArray *)info
{
    for (VirtualGroupInfoModel *groupInfoModel in info)
    {
        //    首先删除之前的数据
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where groupid=%@",virtual_groupinfo_table_name,groupInfoModel.groupid];
        [self operateSql:sql Database:_handle toResult:nil];
        
        sql = [NSString stringWithFormat:@"delete from %@ where groupid=%@",virtual_groupmember_table_name,groupInfoModel.groupid];
        [self operateSql:sql Database:_handle toResult:nil];
        
        sql = [NSString stringWithFormat:@"insert into %@(main_userid,groupid,member_num,single_svc_num,timeout_minute,waiting_prompt,hangup_prompt,oncall_prompt,real_code,update_time,update_type) values(?,?,?,?,?,?,?,?,?,?,?)",virtual_groupinfo_table_name];
        
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
        sqlite3_bind_int(stmt, 1, groupInfoModel.main_userid);
        sqlite3_bind_text(stmt, 2, [groupInfoModel.groupid UTF8String],-1,NULL);
        sqlite3_bind_int(stmt, 3, groupInfoModel.member_num);
        sqlite3_bind_int(stmt, 4, groupInfoModel.single_svc_num);
        sqlite3_bind_int(stmt, 5, groupInfoModel.timeout_minute);
        sqlite3_bind_text(stmt, 6, [groupInfoModel.waiting_prompt UTF8String],-1,NULL);
        sqlite3_bind_text(stmt, 7, [groupInfoModel.hangup_prompt UTF8String],-1,NULL);
        sqlite3_bind_text(stmt, 8, [groupInfoModel.oncall_prompt UTF8String],-1,NULL);
        sqlite3_bind_int(stmt, 9, groupInfoModel.real_code);
        sqlite3_bind_text(stmt, 10, [groupInfoModel.update_time UTF8String],-1,NULL);
        sqlite3_bind_int(stmt, 11, groupInfoModel.update_type);
        //    sqlite3_bind_text(stmt, 6, [[info valueForKey:@"message"] UTF8String],-1,NULL);
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
        for (VirtualGroupMemberModel *groupMemberModel in groupInfoModel.virtualMemberArray)
        {
            sql = [NSString stringWithFormat:@"insert into %@(groupid,userid,svc_status,update_time,update_type) values(?,?,?,?,?)",virtual_groupmember_table_name];
            
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
            sqlite3_bind_text(stmt, 1, [groupMemberModel.groupid UTF8String],-1,NULL);
            sqlite3_bind_int(stmt, 2, groupMemberModel.userid);
            sqlite3_bind_int(stmt, 3, groupMemberModel.svc_status);
            sqlite3_bind_text(stmt, 4, [groupMemberModel.update_time UTF8String],-1,NULL);
            sqlite3_bind_int(stmt, 5, groupMemberModel.update_type);
            //    sqlite3_bind_text(stmt, 6, [[info valueForKey:@"message"] UTF8String],-1,NULL);
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
//{
//    //    保存同步到的数据
//    if ([self beginTransaction])
//    {
//        [self saveVGroupInfo:info];
//        [self commitTransaction];
//    }else{
//        [self saveVGroupInfo:info];
//    }
//    
//}

#pragma mark - 查询虚拟组
- (BOOL)isVirtualGroupUser:(int)userId
{
    NSString *sql = [NSString stringWithFormat:@"select main_userid from %@ where main_userid = %d",virtual_groupinfo_table_name,userId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - 插入提示语或修改提示语的时间为最近的时间
- (void)initGreetingsWithUserId:(int)userId andTitle:(NSString *)title
{
    conn *_conn = [conn getConn];
    //    查询是否有问候语
    NSString *sql = [NSString stringWithFormat:@"select waiting_prompt from %@ where main_userid = %d",virtual_groupinfo_table_name,userId];
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count > 0) {
        NSString *greetings = [[result objectAtIndex:0]valueForKey:@"waiting_prompt"];
        if (greetings.length > 0) {
            //            查询下是否已经有这样的记录，如果有则修改时间，否则插入
            sql = [NSString stringWithFormat:@"select id from %@ where conv_id = '%d' and msg_type = %d and msg_body = '%@' ",table_conv_records,userId,type_text,greetings];
            
            result = [self querySql:sql];
            if (result.count > 0)
            {
                //             修改时间
                sql = [NSString stringWithFormat:@"update %@ set msg_time = %d where id = %d",table_conv_records,[_conn getCurrentTime],[[[result objectAtIndex:0]valueForKey:@"id"]intValue]];
                [self operateSql:sql Database:_handle toResult:nil];
            }
            else
            {
                NSString *convId = [StringUtil getStringValue:userId];
                
                [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:convId andTitle:title];
                
                //            添加
                NSString *senderId = [StringUtil getStringValue:userId];
                NSString *msgType = [StringUtil getStringValue:type_text];
                NSString *msgBody = [NSString stringWithString:greetings];
                NSString *now = [_conn getSCurrentTime];
                
                NSString *originMsgId =  [NSString stringWithFormat:@"%lld",[_conn getNewMsgId]];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",
                                     senderId,@"emp_id",
                                     msgType,@"msg_type",
                                     msgBody,@"msg_body",
                                     now,@"msg_time",
                                     @"0",@"read_flag",
                                     [StringUtil getStringValue:rcv_msg],@"msg_flag",
                                     [StringUtil getStringValue:send_success],@"send_flag",
                                     @"",@"file_name",
                                     @"0",@"file_size",
                                     originMsgId,@"origin_msg_id",
                                     @"0",@"msg_group_time",
                                     @"0",@"receipt_msg_flag",
                                     nil];
                
                [[eCloudDAO getDatabase]addConvRecord:[NSArray arrayWithObject:dic]];
                
            }
        }
    }
}

#pragma mark - 获取虚拟组时间戳
- (NSString *)getUpdate_time
{
    NSString *updateTimeString = nil;
    NSString *sql = [NSString stringWithFormat:@"select update_time from %@ order by update_time desc",virtual_groupinfo_table_name];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        updateTimeString = [result[0] valueForKey:@"update_time"];
    }
    return updateTimeString;
}
@end
