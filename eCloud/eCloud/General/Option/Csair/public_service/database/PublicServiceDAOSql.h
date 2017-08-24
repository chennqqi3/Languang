//
//  PublicServiceDAOSql.h
//  1244
//
//  Created by Pain on 14-8-25.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#ifndef _244_PublicServiceDAOSql_h
#define _244_PublicServiceDAOSql_h
//公众平台菜单表
#define table_public_service_menu_list @"public_service_menu_list"
//#define create_table_public_service_menu_list @"create table if not exists public_service_menu_list(platformid integer primary key,createtime text,button integer,subbutton integer,type text,name text,key text,url text)"

#define create_table_public_service_menu_list @"create table if not exists public_service_menu_list(platformid integer primary key,button text,createtime text)"

#endif
