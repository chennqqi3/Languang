//
//  MassSql.h
//  eCloud
//
//  Created by Richard on 14-1-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MassSql : NSObject

//会话表
#define table_mass_conversation @"mass_conversation"
/*
 会话id：和普通群聊的生成规则相同
 会话主题：创建人有权利修改会话状态
 创建人
 创建时间
 最后一条消息id
 最后一条消息内容
 最后一条消息时间
 最后一条消息发送人，
 最后一条消息类型
 增加一个会话的总人数，会话列表中要显示
 */
#define create_table_mass_conversation @"create table if not exists mass_conversation(conv_id TEXT PRIMARY KEY , conv_title TEXT,create_emp_id INTEGER,create_time TEXT,last_msg_id INTEGER,lastmsg_body TEXT,last_msg_body TEXT,last_msg_time TEXT, last_emp_id INTEGER,last_msg_type INTEGER,emp_count integer)"

//会话人员表
//可能是部门，也可能是普通的员工，所以增加了一个member_type列
#define table_mass_conv_member @"mass_conv_member"
#define create_table_mass_conv_member @"create table if not exists mass_conv_member(conv_id TEXT,member_type integer,member_id INTEGER,PRIMARY KEY(conv_id,member_type,member_id))"

//会话记录表
#define table_mass_conv_records @"mass_conv_records"

/*
 会话id
 发言人id
 发言类型: 0为文本类型 1为图片类型 2 其它类型
 发言内容
 // 增加文件大小和文件名称
 发言时间
 未读标志：0为已读 1为未读
 发送/接收标志：0：发送 1：接收
 发送状态标识：0为正在发送，1为发送成功，-1为发送失败，如果是收到的消息，那么-1代表图片或录音已经超过了有效期
 原始消息id
 消息已读通知是否发送成功：read_notice_flag，0是成功，1是失败
 
 如果是收到的消息，那么需要增加一列标明此回复针对哪条发出去的消息id
 
 */
#define create_table_mass_conv_records @"create table if not exists mass_conv_records (id INTEGER PRIMARY KEY,conv_id TEXT,emp_id INTEGER,msg_type INTEGER,msg_body TEXT,file_name TEXT,file_size TEXT,msg_time TEXT ,read_flag INTEGER,msg_flag INTEGER,send_flag INTEGER,origin_msg_id TEXT, read_notice_flag INTEGER, is_set_redstate INTEGER,send_msg_id integer)"

//在会话记录表上创建索引
#define create_mass_conv_records_index @"create index if not exists mass_conv_records_index on mass_conv_records(conv_id)"
//创建一个唯一索引，就是发送人和消息id，如果是发送消息，那么消息id是按照一定规则生成的
#define create_mass_conv_records_index_2 @"create unique index if not exists mass_conv_records_index_2 on mass_conv_records(emp_id,origin_msg_id)"

@end
