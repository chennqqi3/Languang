//
//  FileAssistantSql.h
//  eCloud
//
//  Created by Pain on 14-11-20.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#ifndef eCloud_FileAssistantSql_h
#define eCloud_FileAssistantSql_h

//文件上传数据表
#define table_file_upload @"file_upload"
/*
@property (nonatomic,retain) NSString *upload_id; //消息记录id
@property (nonatomic,retain) NSString *userid; //用户id
@property (nonatomic,retain) NSString *filemd5; //待发文件内容的MD5
@property (nonatomic,retain) NSString *filename; //文件名字
@property(assign) int filesize;//文件大小,字节
@property(assign) int type;//类型,1发送的为图片;2发送的为文件
@property(nonatomic,retain) NSString *token; //服务端返回的token
@property(assign) int upload_start_index;//该文件服务器已有大小
@property(assign) int upload_state;//上传状态
 */

#define create_table_file_upload @"create table if not exists file_upload(upload_id TEXT PRIMARY KEY ,userid TEXT,filemd5 TEXT,filename TEXT,filesize INTEGER,type INTEGER,token TEXT,upload_start_index INTEGER,upload_state INTEGER)"


//文件下载数据表
#define table_file_download @"file_download"
/*
 @property (nonatomic,retain) NSString *download_id; //消息记录id
 @property(assign) int download_state;//下载状态
 */

#define create_table_file_download @"create table if not exists file_download(download_id TEXT PRIMARY KEY ,download_state INTEGER)"


#endif
