//
//  AudioTxtDAO.m
//  eCloud
//
//  Created by yanlei on 15/11/17.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "AudioTxtDAO.h"

#import "conn.h"
#import "StringUtil.h"
#import "eCloudDAO.h"

#import "talkSessionUtil2.h"

static AudioTxtDAO *audioDAO;

#define table_audio_txt @"audio_txt"

#define create_audio_txt_table @"create table if not exists audio_txt(audio_txt_id integer primary key,conv_id text,msg_id integer,user_id  integer,msg_time text,message text)"

@implementation AudioTxtDAO

+ (AudioTxtDAO *)getDatabase
{
    if (!audioDAO) {
        audioDAO = [[super alloc]init];
    }
    return audioDAO;
}

#pragma mark - 创建表
- (void)createTable
{
    [self operateSql:create_audio_txt_table Database:_handle toResult:nil];
    
    // 后续增加字段要用到
//    NSString *sql = [NSString stringWithFormat:@"alter table %@ add ts text",audio_txt_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark - 表记录的基本操作
//  保存 记录
- (void)saveAudioTxtInfo:(NSDictionary *)info
{
    int audioTxtId = [self getAllAudioTxtCount]+1;
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(audio_txt_id,conv_id,msg_id,user_id,msg_time,message) values(?,?,?,?,?,?)",table_audio_txt];
    
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
    sqlite3_bind_int(stmt, 1, audioTxtId);
    sqlite3_bind_text(stmt, 2, [[info valueForKey:@"conv_id"] UTF8String],-1,NULL);
    sqlite3_bind_int(stmt, 3, [[info valueForKey:@"msg_id"] intValue]);
    sqlite3_bind_int(stmt, 4, [[info valueForKey:@"user_id"] intValue]);
    sqlite3_bind_text(stmt, 5, [[info valueForKey:@"msg_time"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 6, [[info valueForKey:@"message"] UTF8String],-1,NULL);
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

//  查询是否转换过的语音文本
- (BOOL)isExistAudioTxt:(NSString *)conv_id andMsgId:(NSInteger)msg_id
{
    NSString *menuString = nil;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where conv_id = %@ and msg_id = %d",table_audio_txt,conv_id,msg_id];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
//            menuString = [result[0] valueForKey:@"message"];
        return YES;
    }
    return NO;
}
// 从数据库中取出转换后的语音文本
- (NSString *)getMessage:(NSString *)conv_id andMsgId:(NSInteger)msg_id
{
    NSString *message = nil;
    NSString *sql = [NSString stringWithFormat:@"select message from %@ where conv_id = %@ and msg_id = %d",table_audio_txt,conv_id,msg_id];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        message = [result[0] valueForKey:@"message"];
    }
    return message;
}

#pragma mark 查询所有语音文本记录的个数
-(int)getAllAudioTxtCount
{
    int _count = 0;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@",table_audio_txt];
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if([result count] == 1)
    {
        _count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
    }
    [pool release];
    return _count;
}
@end
