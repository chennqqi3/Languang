//
//  FileAssistantRecordSql.h
//  eCloud
//
//  Created by Dave William on 2017/7/15.
//  Copyright © 2017年 网信. All rights reserved.
//

#ifndef FileAssistantRecordSql_h
#define FileAssistantRecordSql_h

//文件助手数据库表
#define table_file_assistant @"file_record"


/*
 @param id 自增长id
 @param conv_id 会话id
 @param msg_id 文件消息id
 @param emp_id 发送人id
 @param send_time 发送时间
 @param file_name 文件消息名字
 @param file_size 文件消息大小
 @param file_url 文件url
 @param file_ext 文件后缀名
 */

#define create_table_file_assistant @"create table if not exists file_record(id INTEGER PRIMARY KEY,conv_id TEXT,origin_msg_id TEXT,emp_id INTEGER,msg_time TEXT,file_name TEXT,file_size TEXT,msg_body TEXT,file_ext TEXT,msg_type INTEGER)"



#endif /* FileAssistantRecordSql_h */
