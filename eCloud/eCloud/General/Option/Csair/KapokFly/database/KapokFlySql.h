//
//  KapokFlySql.h
//  eCloud
//
//  Created by  lyong on 14-5-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#ifndef eCloud_KapokFlySql_h
#define eCloud_KapokFlySql_h

//木棉童飞－照片上传
#define table_kapok_upload @"kapok_upload"
/*
 上传id：
 选择日期：
 上传时间：
 航班号
 起飞机场
 登机号
 工号 
 上传状态：0 成功 1 等待 2 正在进行 3 失败
 */
#define create_table_kapok_upload @"create table if not exists kapok_upload(upload_id TEXT PRIMARY KEY ,selected_date TEXT,create_time TEXT,flight_num TEXT,start_airport TEXT,boarding_num TEXT,emp_code TEXT,upload_state INTEGER)"

//会话人员表
//可能是部门，也可能是普通的员工，所以增加了一个member_type列
#define table_kapok_imagelist @"kapok_imagelist"
#define create_table_kapok_imagelist @"create table if not exists kapok_imagelist(upload_id TEXT,image_name TEXT,image_code TEXT,image_token TEXT,upload_state INTEGER,upload_start_index INTEGER,PRIMARY KEY(upload_id,image_code))"

#endif
