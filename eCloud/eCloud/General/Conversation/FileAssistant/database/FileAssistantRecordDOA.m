//
//  FileAssistantRecordDOA.m
//  eCloud
//
//  Created by Dave William on 2017/7/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "FileAssistantRecordDOA.h"
#import "eCloudDefine.h"
#import "FileAssistantRecordSql.h"
#import "FileAssistantDOA.h"

static FileAssistantRecordDOA *FileAssistantRecord;

@implementation FileAssistantRecordDOA

+(id)getFileDatabase
{
    if (!FileAssistantRecord) {
        FileAssistantRecord = [[FileAssistantRecordDOA alloc]init];
    }
    return FileAssistantRecord;
}

//增加一条文件消息记录
-(void)addOneFileRecord:(NSDictionary *)dic
{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(conv_id,origin_msg_id,emp_id,msg_time,file_name,file_size,msg_body,file_ext,msg_type) values(?,?,?,?,?,?,?,?,?)",table_file_assistant];
    
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
//        return nil;
    }
    
    //		绑定值
    pthread_mutex_lock(&add_mutex);
    sqlite3_bind_text(stmt, 1, [[dic valueForKey:@"conv_id"] UTF8String],-1,NULL);//conv_id
    sqlite3_bind_int(stmt, 2, [[dic valueForKey:@"origin_msg_id"] intValue]);//emp_id
    sqlite3_bind_int(stmt,3,[[dic valueForKey:@"emp_id"] intValue]);//msg_type
    //    sqlite3_bind_text(stmt,4,[msgBody UTF8String],-1,NULL);//msg_body
    sqlite3_bind_text(stmt,4,[[dic valueForKey:@"msg_time"] UTF8String],-1,NULL);//msg_time
    sqlite3_bind_text(stmt,5,[[dic valueForKey:@"file_name"] UTF8String],-1,NULL);//read_flag
    //    sqlite3_bind_int(stmt,7,[[dic valueForKey:@"msg_flag"] intValue]);//msg_flag
    //    sqlite3_bind_int(stmt,8,[[dic valueForKey:@"send_flag"] intValue]);//send_flag
    sqlite3_bind_text(stmt,6,[[dic valueForKey:@"file_size"] UTF8String],-1,NULL);//file_size
    sqlite3_bind_text(stmt,7,[[dic valueForKey:@"msg_body"]  UTF8String],-1,NULL);//file_name
    sqlite3_bind_text(stmt, 8, [[[dic valueForKey:@"file_name"] pathExtension] UTF8String], -1, NULL);
    sqlite3_bind_int(stmt,9,[[dic valueForKey:@"msg_type"] intValue]);//msg_type
    
    //    sqlite3_bind_text(stmt, 9, [[dic valueForKey:@"file_ext"] UTF8String], -1, NULL);
    
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
//        return nil;
    }
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
    

}

-(void)deleteFileRecordOneMsg:(NSString *)msgid
{
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id='%@'",table_file_assistant,msgid];
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    [[FileAssistantDOA getDatabase] deleteOneUpload:msgid];
    [[FileAssistantDOA getDatabase] deleteOneDownloadRecord:msgid];
}


//更新
-(void)updateTheFileRecordMsgID:(NSString *)msgBody withOldMsgBody:(NSString *)oldMsg
{
    
    NSString *sql = [NSString stringWithFormat:@" update %@ set msg_body = '%@' where msg_body = '%@'",table_file_assistant,msgBody,oldMsg];
    [self operateSql:sql Database:_handle toResult:nil];
}



@end
