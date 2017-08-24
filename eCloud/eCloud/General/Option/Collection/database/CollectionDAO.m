//
//  CollectionDAO.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "CollectionDAO.h"
#import "QueryDAO.h"
#import "MyCollectionModel.h"
#import "Emp.h"
#import "ImageUtil.h"
#import "LogUtil.h"
#import "StringUtil.h"
#import "eCloudUser.h"
#import "talkSessionUtil.h"
#import "CollectionUtil.h"
#import "talkSessionUtil.h"
#import "EncryptFileManege.h"
#import "CollectionConn.h"
#import "RobotDAO.h"
#import "RobotResponseXmlParser.h"
#import "talkSessionViewController.h"
#import "conn.h"


#define collection_table_name @"collection"

#define CollectionNum 20

#define ALL_TYPE 2000

//add by shisp
//增加 conv_title 会话标题
//增加 conv_id 会话id
//增加 conv_type 单聊还是群聊
//收藏的真正的类型 collect_real_type  小万的回复本来是文本类型，但是要根据解析出来的类型 去搜索，所以要再保存一个真正的类型
#define create_collection_table @"create table if not exists collection(collection_origin_msg_id text primary key,collection_type integer,collection_user text,collection_body text,collection_time text,msg_time text,conv_id text,conv_title text,conv_type integer,collect_real_type integer)"

static CollectionDAO *collectionDAO;

@interface CollectionDAO ()
{
    NSInteger _timeNow;
}

@end

@implementation CollectionDAO

+ (CollectionDAO *)shareDatabase
{
    if (collectionDAO == nil)
    {
        collectionDAO = [[super alloc] init];
    }
    return collectionDAO;
}

//创建收藏表
- (void)createTable
{
    NSString  *sql = nil;
    
    [self operateSql:create_collection_table Database:_handle toResult:nil];
    
    //        判断表是否包含msg_time
    sql = [NSString stringWithFormat:@"alter table %@ add msg_time text",collection_table_name];
    BOOL success = [self operateSql:sql Database:_handle toResult:nil];
    
    if (success) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 收藏表已经存在 并且没有包含 msg_time 列，这时需要删除旧表，并且重新创建 收藏表",__FUNCTION__]];
        //            证明 表里没有msg_time这个列，所以是旧的表结构
        //        首先删除旧表
        sql = [NSString stringWithFormat:@"drop table %@",collection_table_name];
        [self operateSql:sql Database:_handle toResult:nil];
        //        再创建新表
        [self operateSql:create_collection_table Database:_handle toResult:nil];
    }
}

//    sql = [NSString stringWithFormat:@"alter table %@ add msg_time text",collection_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
//
//    sql = [NSString stringWithFormat:@"alter table %@ add conv_id text",collection_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
//
//    sql = [NSString stringWithFormat:@"alter table %@ add conv_title text",collection_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
//
//    sql = [NSString stringWithFormat:@"alter table %@ add conv_type integer",collection_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];
//
//    sql = [NSString stringWithFormat:@"alter table %@ add collect_real_type integer",collection_table_name];
//    [self operateSql:sql Database:_handle toResult:nil];


//添加收藏
- (void)addCollection:(NSDictionary *)dic
{
    ConvRecord *convRecord = dic[@"editRecord"];
    
    NSString * sql = [NSString stringWithFormat:@"insert into %@(collection_origin_msg_id ,collection_type ,collection_user ,collection_body, collection_time, msg_time,conv_id,conv_title,conv_type,collect_real_type) values(?,?,?,?,?,?,?,?,?,?)",collection_table_name];
    
    sqlite3_stmt *stmt = nil;
    
    //编译
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        //编译错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        
        //        [self rollbackTransaction];
        return;
    }
    
    // 如果是小万消息就更新为相应的realType
    if([self isXiaoWanMsg:convRecord.msg_body])
    {
        RobotResponseXmlParser *robotParser = [[RobotResponseXmlParser alloc] init];
        bool result = [robotParser parse:convRecord.msg_body andIsParseAgent:NO];
        
        if (!result)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s 解析小万消息出错",__FUNCTION__]];
            return;
        }
            
        convRecord.robotModel = robotParser.robotModel;
        
        if (convRecord.robotModel.msgType == type_video)
        {
            convRecord.realMsgType = type_video;
        }
        else if (convRecord.robotModel.msgType == type_imgtxt)
        {
            convRecord.realMsgType = type_imgtxt;
        }
        else if (convRecord.robotModel.msgType == type_record)
        {
            convRecord.realMsgType = type_record;
        }
        else if (convRecord.robotModel.msgType == type_wiki)
        {
//            图文消息
            convRecord.realMsgType = type_imgtxt;
        }
        else if (convRecord.robotModel.msgType == type_pic)
        {
//            图片类型消息
            convRecord.realMsgType = type_pic;
        }
        else
        {
            convRecord.msg_body = robotParser.robotModel.content;
            convRecord.msg_body = [StringUtil formatXiaoWanMsg:convRecord.msg_body];
        }
    }
    
    // 判断是不是文件类型
    NSMutableString *_msg_body = [NSMutableString stringWithString:convRecord.msg_body];
    if (convRecord.msg_type == type_file)
    {
        [_msg_body appendString:[NSString stringWithFormat:@"(~_<)%@",convRecord.file_name]];
        [_msg_body appendString:[NSString stringWithFormat:@"(~_<)%@",convRecord.file_size]];
    }
    else if (convRecord.msg_type == type_record)  //判断是不是录音类型
    {
        [_msg_body appendString:[NSString stringWithFormat:@"(~_<)%@",convRecord.file_size]];
    }else if (convRecord.msg_type == type_video){
        [_msg_body appendString:[NSString stringWithFormat:@"(~_<)%@",convRecord.file_size]];
    }
    if (convRecord.locationModel) {
        convRecord.realMsgType = type_location;
        
    }
    if (convRecord.newsModel) {
        convRecord.realMsgType = type_news;
    }
    
    // 测试用的  lyalyan
//    else if (convRecord.msg_type == type_text){
//        convRecord.msg_type = type_filecloud;
//    }
    
    pthread_mutex_lock(&add_mutex);
    
    NSString *originID = [NSString stringWithFormat:@"%lld",convRecord.origin_msg_id];
    sqlite3_bind_text(stmt, 1, [originID UTF8String],-1,NULL);
    sqlite3_bind_int(stmt, 2, convRecord.msg_type);
    sqlite3_bind_text(stmt, 3, [[StringUtil getStringValue:convRecord.emp_id]UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 4, [_msg_body UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 5, [dic[@"time"] UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 6, [convRecord.msg_time UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 7, [convRecord.conv_id UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 8, [convRecord.conv_title UTF8String],-1,NULL);
    sqlite3_bind_int(stmt, 9, convRecord.conv_type);
    sqlite3_bind_int(stmt, 10, convRecord.realMsgType);
    
    
    state = sqlite3_step(stmt);
    
    pthread_mutex_unlock(&add_mutex);
    
    //	执行结果
    if(state != SQLITE_DONE &&  state != SQLITE_OK)
    {
        //执行错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        
        //        [self rollbackTransaction];
        return;
    }
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
    //    使用conn里定义的方法 下载 收藏的图文、文件等
    [[CollectionConn getConn]downloadFile:convRecord];

//    [self commitTransaction];
}

//删除收藏
- (void)deleteCollection:(NSArray *)arr
{
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSDictionary *dic in arr)
    {
        NSLog(@"%s dic is %@",__FUNCTION__,[dic description]);
        [mArr addObject:dic[@"origin_id"]];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:mArr forKey:@"delete"];
    // 删除服务器资源
    dic[@"operationType"] = @(3);
    [[CollectionConn getConn] sendModiRequestWithMsg:dic];
}

//收到服务器的删除通知后 删除本地数据
- (void)deleteLocalCollection:(NSArray *)arr
{
    for (NSString *originID in arr)
    {
        NSString *selectSql = [NSString stringWithFormat:@"select * from %@ WHERE collection_origin_msg_id = %@",collection_table_name,originID];
        NSMutableArray *array = [self querySql:selectSql];
        
        for (NSDictionary *dic in array)
        {
            NSInteger msgType = [[dic objectForKey:@"collection_type"] integerValue];
            NSString *fileName = [dic objectForKey:@"collection_body"];
            
            //删除选中的数据
            NSString *sql = [NSString stringWithFormat:@"delete from %@ WHERE collection_origin_msg_id = %@;",collection_table_name,originID];
            [self operateSql:sql Database:_handle toResult:nil];
            
            // 删除本地资源
            // 判断是不是长文本或图片
            if ([@(msgType) isEqual:@(type_pic)])
            {
                NSString *messageStr = fileName;
                
                NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
                NSString *picpath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:picname];
                
                NSData *data = [EncryptFileManege getDataWithPath:picpath];
                
                NSString *collectPath = [NSString stringWithFormat:@"%@/%@.png", [CollectionUtil newCollectFilePath],messageStr];
                [[NSFileManager defaultManager] removeItemAtPath:collectPath error:nil];
            }
            else if ([@(msgType) isEqual:@(type_long_msg)])
            {
                NSString *messageStr = fileName;
                
                NSString *longTxtName=[NSString stringWithFormat:@"%@.txt",messageStr];
                NSString *longTxtPath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:longTxtName];
                
                NSData *stringData = [EncryptFileManege getDataWithPath:longTxtPath];
                
                NSString *collectPath = [NSString stringWithFormat:@"%@/%@.txt", [CollectionUtil newCollectFilePath],messageStr];
                [[NSFileManager defaultManager] removeItemAtPath:collectPath error:nil];
            }
        }
    }
}

// 根据类型获取收藏内容
- (NSMutableArray *)getCollectionByType:(NSInteger)type
{
    NSString *sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a, %@ b where a.collection_user = b.emp_id and collect_real_type = %d order by collection_time desc",collection_table_name,table_employee,type];
    if (type == type_imgtxt)
    {
        sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a, %@ b where a.collection_user = b.emp_id and (collect_real_type = %d or collect_real_type = %d) order by collection_time desc",collection_table_name,table_employee,type,type_normal_imgtxt];
    }
    else if (type == type_file)
    {
        sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a, %@ b where a.collection_user = b.emp_id and (collect_real_type = %d or collect_real_type = %d) order by collection_time desc",collection_table_name,table_employee,type,type_video];
    }
    NSMutableArray *array = [self querySql:sql];
    
    return [self getModelDataByArray:array];
}

// 根据关键字获取收藏内容
- (NSMutableArray *)searchByType:(NSInteger)type withWord:(NSString *)word withCount:(NSInteger)count
{
    NSString *matchEmpIds = [[QueryDAO getDatabase]getMatchEmpIdBySearchStr:word];
    
    NSMutableArray *mArr = [NSMutableArray array];
    if (type == ALL_TYPE)
    {
        NSString *sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where a.collection_body like '%%%@%%' COLLATE NOCASE and a.collection_user = b.emp_id order by collection_time desc",collection_table_name,table_employee,word];
        
        if (matchEmpIds.length) {
            sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collection_body like '%%%@%%' COLLATE NOCASE or (a.collection_user in (%@))) and a.collection_user = b.emp_id order by collection_time desc",collection_table_name,table_employee,word,matchEmpIds];
            NSLog(sql1);
        }
        
        
        NSMutableArray *array1 = [self querySql:sql1];
        [mArr addObjectsFromArray:[self getModelDataByArray:array1]];
    }
    else
    {
        NSString *sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where a.collect_real_type = %d and a.collection_body like '%%%@%%' COLLATE NOCASE and a.collection_user = b.emp_id order by collection_time desc",collection_table_name,table_employee,type,word];
        if (type == type_imgtxt)
        {
            sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collect_real_type = %d or a.collect_real_type = %d) and a.collection_body like '%%%@%%' COLLATE NOCASE and a.collection_user = b.emp_id order by collection_time desc",collection_table_name,table_employee,type,type_normal_imgtxt,word];
        }
        else if (type == type_file)
        {
            sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collect_real_type = %d or a.collect_real_type = %d) and a.collection_body like '%%%@%%' COLLATE NOCASE and a.collection_user = b.emp_id order by collection_time desc",collection_table_name,table_employee,type,type_video,word];
        }
        
        if (matchEmpIds.length) {
            sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collection_body like '%%%@%%' COLLATE NOCASE or (a.collection_user in (%@))) and a.collection_user = b.emp_id and a.collect_real_type = %d order by collection_time desc",collection_table_name,table_employee,word,matchEmpIds,type];
            if (type == type_imgtxt)
            {
                sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collection_body like '%%%@%%' COLLATE NOCASE or (a.collection_user in (%@))) and a.collection_user = b.emp_id and (a.collect_real_type = %d or a.collect_real_type = %d) order by collection_time desc",collection_table_name,table_employee,word,matchEmpIds,type,type_normal_imgtxt];
            }
            else if (type == type_file)
            {
                sql1 = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a,%@ b where (a.collection_body like '%%%@%%' COLLATE NOCASE or (a.collection_user in (%@))) and a.collection_user = b.emp_id and (a.collect_real_type = %d or a.collect_real_type = %d) order by collection_time desc",collection_table_name,table_employee,word,matchEmpIds,type,type_video];
            }
            NSLog(sql1);
        }
        
        NSMutableArray *array1 = [self querySql:sql1];
        [mArr addObjectsFromArray:[self getModelDataByArray:array1]];
    }
    
    return mArr;
}

//获取收藏内容
- (NSMutableArray *)getCollectionData:(NSInteger)count
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as collect_count from %@",collection_table_name];
    NSMutableArray *result = [self querySql:sql];
    NSInteger _count;
    if (result.count) {
        _count = [[result[0] valueForKey:@"collect_count"] integerValue];
    }
    
    NSInteger count1 = count + CollectionNum;
    NSInteger number = CollectionNum;
    if (count1 > _count)
    {
        number = _count - count;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"noMoreData"];
    }
    
    sql = [NSString stringWithFormat:@"select a.*,b.emp_name,b.emp_name_eng,b.emp_sex,b.emp_code from %@ a, %@ b where a.collection_user = b.emp_id order by collection_time desc limit %d,%d ",collection_table_name,table_employee,count,number];
    
    NSMutableArray *array = [self querySql:sql];
    
    return [self getModelDataByArray:array];
}

- (NSMutableArray *)getModelDataByArray:(NSMutableArray *)array
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    _timeNow = [[NSDate date] timeIntervalSince1970];
    
    for (NSDictionary *dic in array)
    {
        BOOL needDownloadFile = NO;
        //                    如果文件不存在，那么启动下载
        ConvRecord *downloadRecord = [[ConvRecord alloc]init];

        
        MyCollectionModel *model = [[MyCollectionModel alloc] init];
        
        Emp *_emp = [[Emp alloc]init];
        _emp.emp_name = [dic valueForKey:@"emp_name"];
        _emp.empNameEng = [dic valueForKey:@"emp_name_eng"];
        _emp.empCode = [dic valueForKey:@"emp_code"];
        _emp.emp_id = [[dic objectForKey:@"collection_user"]intValue];
        _emp.emp_sex = [[dic objectForKey:@"emp_sex"] intValue];
        
        model.emp = _emp;
        model.userName = _emp.emp_name;
        model.icon = [ImageUtil getEmpLogo:_emp];
        
        model.originID = [dic objectForKey:@"collection_origin_msg_id"];
        downloadRecord.origin_msg_id = [model.originID longLongValue];
        
        model.type = [[dic objectForKey:@"collection_type"] integerValue];
        downloadRecord.msg_type = model.type;
        
        model.realType = [[dic objectForKey:@"collect_real_type"] integerValue];
        downloadRecord.realMsgType = model.realType;
        
        model.body = [dic objectForKey:@"collection_body"];
        model.groupName = [dic objectForKey:@"conv_title"];
        model.time = [dic objectForKey:@"collection_time"];
        model.msgTime = [self getDate:[dic objectForKey:@"msg_time"]];
        model.timeText = [self getTime:model.time];
        
        NSString *message = [NSString stringWithString:model.body];
        if (model.realType == type_record)
        {
            NSArray *arr5 = [model.body componentsSeparatedByString:@"(~_<)"];
            message = arr5[0];
        }
        if([self isXiaoWanMsg:message])
        {
            RobotResponseXmlParser *robotParser = [[RobotResponseXmlParser alloc] init];
            bool result = [robotParser parse:model.body andIsParseAgent:NO];
            if (!result) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 解析小万消息出错",__FUNCTION__]];
                continue;
            }
            downloadRecord.robotModel = robotParser.robotModel;
            
//            把解析小万的结果 也 保存 在collectModel中
            model.robotModel = robotParser.robotModel;

            if (model.realType == type_record)
            {
                model.title = robotParser.robotModel.msgFileName;
                model.fileSize = robotParser.robotModel.msgFileSize;
                
                model.fileName = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:model.title];
                
                if (![fileManager fileExistsAtPath:model.fileName]) {
//                    需要下载 小万语音
                    needDownloadFile = YES;
                }
                
            }
            else if (model.realType == type_video)
            {
                model.title = robotParser.robotModel.msgFileName;
                model.fileSize = robotParser.robotModel.msgFileSize;
            }
            else if (model.realType == type_pic)
            {
//                小万的图片消息
                model.title = robotParser.robotModel.msgFileName;
                model.picture = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[CollectionUtil newRcvFilePath],model.title]];
                if (!(model.picture)) {
//                    需要下载 小万图片
                    needDownloadFile = YES;
                }
            }
            else if (model.realType == type_imgtxt)
            {
                if ([robotParser.robotModel.nameString isEqualToString:@"imgtxtmsg"]) {
                    //                图文消息
                    NSArray *argsArray = robotParser.robotModel.imgtxtArray;
                    
                    if (argsArray.count) {
                        NSDictionary *dic = argsArray[0];
//                        NSLog(@"%@",[dic description]);
                        
//                        主标题
                        model.title = dic[@"Title"];
//                        点击打开的URL
                        model.imgtextURL = dic[@"Url"];
//                        副标题
                        model.fileName = dic[@"Description"];
                        model.picture = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/robot_%@.jpg",[CollectionUtil newRcvFilePath],model.title]];
                        if (!(model.picture)) {
//                            需要下载图片 图文
                            needDownloadFile = YES;
                        }
                    }

                }else{
                    if (robotParser.robotModel.argsArray.count >= 4) {
                        model.title = robotParser.robotModel.argsArray[0];
                        model.imgtextURL = robotParser.robotModel.argsArray[1];
                        model.fileName = robotParser.robotModel.argsArray[3];
                        model.picture = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/robot_%@.jpg",[CollectionUtil newRcvFilePath],model.title]];
                        if (!(model.picture)) {
                            //                        需要下载图片 百科
                            needDownloadFile = YES;
                        }                        
                    }
                }
            }
        }
        
        
        switch (model.realType) {
            case type_pic:
            {
//                如果收到的图片 url 是 [#xxxx.png] 那么就需要截取，否则可以直接使用
             
                if (![self isXiaoWanMsg:message]) {
//                    普通的图片消息
                    NSString *picUrl = [StringUtil getPicMsgUrlByMsgBody:model.body];
                    model.fileName = [StringUtil getPicNameByPicUrl:picUrl];
                    
                    NSString *picpath = [[CollectionUtil newCollectFilePath] stringByAppendingPathComponent:model.fileName];
                    UIImage *originImg = [UIImage imageWithContentsOfFile:picpath];
                    
                    model.picture = originImg;
                    if (!(model.picture)) {
//                        需要下载 普通图片
                        needDownloadFile = YES;
                        downloadRecord.msg_body = picUrl;
                    }
                }
            }
                break;
                
            case type_file:
            {
                NSArray *arr = [model.body componentsSeparatedByString:@"(~_<)"];
                
                model.fileName = arr[1];
                model.body = [arr firstObject];
                CGFloat size = [[arr lastObject] doubleValue];
                
                model.fileSize = [NSString stringWithFormat:@"%@",[arr lastObject]];
                
                
                ConvRecord *_convRecord = [[ConvRecord alloc]init];
                _convRecord.file_name = model.fileName;
                _convRecord.msg_body = model.body;
                
                NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[talkSessionUtil getFileName:_convRecord]];
                
                if (![fileManager fileExistsAtPath:filePath]) {
                    needDownloadFile = YES;
                    downloadRecord.file_name = model.fileName;
                    downloadRecord.msg_body = model.body;
                }
            }
                break;
            
            case type_record:
            {
                if (model.title)
                {
                    // 什么也不需要做
                }
                else
                {
                    NSArray *arr = [model.body componentsSeparatedByString:@"(~_<)"];
                    
                    model.body = [arr firstObject];
                    model.fileSize = [arr lastObject];
                    model.fileName = model.body;
                    
                    NSString *messageStr = model.body;
                    
                    NSString *audioName =[NSString stringWithFormat:@"%@.amr",messageStr];
                    NSString *audioPath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:audioName];
                    
                    model.body = audioPath;
                    
//                    查看普通语音是否需要下载
                    if (![fileManager fileExistsAtPath:audioPath]) {
                        needDownloadFile = YES;
                        downloadRecord.msg_body = messageStr;
                    }
                }
            }
                break;
                
            case type_video:
            {
                if (model.title)
                {
                    model.fileName = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:model.title];
                    UIImage *PreViewImage = [talkSessionUtil getVideoPreViewImage:[NSURL fileURLWithPath:model.fileName]];
                    model.picture = PreViewImage;
                    if (!([fileManager fileExistsAtPath:model.fileName])) {
//                        小万视频 需要下载
                        needDownloadFile = YES;
                    }
                }
                else
                {
                    NSArray *arr = [model.body componentsSeparatedByString:@"(~_<)"];
                    
                    NSString *fileUrl = [arr firstObject];
                    model.fileName = fileUrl;
                    model.body = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:[StringUtil getVideoNameByVideoUrl:fileUrl]];
                    model.fileSize = [arr lastObject];
                    
                    UIImage *PreViewImage = [talkSessionUtil getVideoPreViewImage:[NSURL fileURLWithPath:model.body]];
                                        model.picture = PreViewImage;
                    if (!((model.picture))) {
//                        普通视频 需要下载
                        needDownloadFile = YES;
                        
                        model.picture = [StringUtil getImageByResName:@"default_video.png"];

                        downloadRecord.msg_body = fileUrl;
                    }
                }
            }
                break;
                
            case type_long_msg:
            {
                NSString *messageStr = model.body;
                
                model.fileName = model.body;
                
                NSString *longTxtName=[NSString stringWithFormat:@"%@.txt",messageStr];
                NSString *longTxtPath = [[CollectionUtil newCollectFilePath] stringByAppendingPathComponent:longTxtName];
                
                //                if ([eCloudConfig getConfig].needFixSecurityGap)
                //                {
                //                    NSData *stringData = [EncryptFileManege getDataWithPath:longTxtPath];
                //                    NSString *long_text = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
                //                    model.body = long_text;
                //                }
                //                else
                //                {
                //                    model.body = [NSString stringWithContentsOfFile:longTxtPath encoding:NSUTF8StringEncoding error:nil];
                //                }
                NSData *stringData = [EncryptFileManege getDataWithPath:longTxtPath];
                NSString *long_text = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
                model.body = long_text;
                if (long_text.length == 0) {
                    needDownloadFile = YES;
                    downloadRecord.msg_body = messageStr;
                }
            }
                break;
                
            default:
                break;
        }
        
        if (needDownloadFile) {
            
            [[CollectionConn getConn]downloadFile:downloadRecord];
        }
        [mArr addObject:model];
    }
    
    // 把最新的排在最前面
    //    [mArr sortUsingComparator:^NSComparisonResult(MyCollectionModel *model1,MyCollectionModel *model2){
    //        NSComparisonResult reslut = [model2.time compare:model1.time];
    //
    //        return reslut;
    //    }];
    
    return mArr;
}

- (NSString *)getDate:(NSString *)time
{
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[time integerValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSString *date = [dateFormatter stringFromDate:detaildate];
    
    return date;
}

- (NSString *)getTime:(NSString *)collectedTime
{
    // 计算什么时候收藏的
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger zoneTime = [zone secondsFromGMT];
    NSInteger timeFromYesterday = (([collectedTime integerValue] + zoneTime)/ 3600) % 24;
    
    NSInteger time = _timeNow - [collectedTime integerValue];
    NSInteger hours = time/(60*60) + timeFromYesterday;
    NSInteger days = hours / 24;
    
    if (days == 0)
    {
        NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[collectedTime integerValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *date = [dateFormatter stringFromDate:detaildate];
        
        return date;
    }
    
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:[collectedTime integerValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yy/MM/dd"];
    NSString *date = [dateFormatter stringFromDate:detaildate];
    
    return date;
}

//增加一个方法，查询已经保存的收藏，找到最新的时间戳，找不到则使用当前最新时间
- (int)getLastCollectTime
{
    int collectTime = 0;
    NSString *sql = [NSString stringWithFormat:@"select collection_time from %@ order by collection_time desc limit (1) ",collection_table_name];
    NSMutableArray *result = [self querySql:sql];
    if (result.count) {
         collectTime = [[result[0] valueForKey:@"collection_time"]intValue];
    }else {
        collectTime = [[conn getConn]getCurrentTime];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 最近一条收藏的收藏时间 %d",__FUNCTION__,collectTime]];
    return collectTime;
}

- (BOOL)isXiaoWanMsg:(NSString *)msgBody
{
    return [StringUtil isXiaoWanMsg:msgBody];
}

-(void)deleteAllData
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",collection_table_name];
    [self operateSql:sql Database:_handle toResult:nil];
    
}


@end
