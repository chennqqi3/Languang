//
//  APPPlatformDOA.m
//  eCloud
//
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPPlatformDOA.h"
#import "NotificationUtil.h"

#import "ConvNotification.h"
#import "ConvRecord.h"

#import "Conversation.h"
#import "APPPlatformSql.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "PSMsgUtil.h"
#import "APPUtil.h"
#import "UIAdapterUtil.h"

#import "APPListModel.h"
#import "APPPushNotification.h"
#import "APPStateRecord.h"
#import "APPToken.h"
#import "JSONKit.h"

#ifdef _GOME_FLAG_
#import "GOMEMailDefine.h"
#endif


static APPPlatformDOA *appPlatformDAO;

@implementation APPPlatformDOA
+(id)getDatabase
{
	if(appPlatformDAO == nil)
	{
		appPlatformDAO = [[APPPlatformDOA alloc]init];
	}
	return appPlatformDAO;
}

#pragma mark --------------------------应用列表信息--------------------------

#pragma mark - 保存应用列表信息
-(bool)saveAPPListInfo:(NSArray *)info{
    bool success = true;
    
    for (APPListModel *appModel in info)
    {
        if ( 1 == appModel.updatetype) {
            //新增
            APPListModel *updateAppModel = [self getAPPModelByAppid:appModel.appid];
            if (updateAppModel.appid) {
                //数据库存在，更新数据库
                [self updateAPPInfo:updateAppModel withNewAppModel:appModel];
            }
            else{
                //不存在，创建新的记录
                appModel.isnew = 1;//新应用
                appModel.appShowFlag = 0;//没有添加到我的页面
                appModel.downloadFlag = 0; //默认是未下载
                [self addOneAPPInfo:appModel];
                
                //标识有新应用
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APP_NEW_DEFAULT];
            }
        }
        else if (2 == appModel.updatetype){
            APPListModel *updateAppModel = [self getAPPModelByAppid:appModel.appid];
            if (updateAppModel.appid) {
                //数据库存在，更新数据库
                [self updateAPPInfo:updateAppModel withNewAppModel:appModel];
            }
            else{
                //不存在，创建新的记录
                appModel.isnew = 1;//新应用
                appModel.appShowFlag = 0;//没有添加到我的页面
                appModel.downloadFlag = 0; //默认是未下载
                [self addOneAPPInfo:appModel];
                
                //标识有新应用
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APP_NEW_DEFAULT];
            }
        }
        else if (3 == appModel.updatetype){
            //删除
            APPListModel *deleteAppModel = [self getAPPModelByAppid:appModel.appid];
            //                [self deleteAPPModel:deleteAppModel];
            [self deleteAPPModelUpdatetype:deleteAppModel];
        }
    }
    
    return success;
}

-(bool)updateAPPInfo:(APPListModel*)oldAppModel withNewAppModel:(APPListModel*)appModel
{
//    [LogUtil debug:[NSString stringWithFormat:@"%s oldappid is %d oldappname is %@ appid is %d appname is %@",__FUNCTION__,oldAppModel.appid,oldAppModel.appname,appModel.appid,appModel.appname]];

	bool success = false;
//	NSString *sql = [NSString stringWithFormat:@"update %@ set apptype = ?,appname = ?,appicon = ?,appvers = ?,uptime = ?,serverurl = ?,permission = ?,cacheurl = ?,showflag = ?,appdesc = ? ,apppics = ? where appid = '%@'", table_apps_list,appModel.appid];
    NSString *sql = [NSString stringWithFormat:@"update %@ set appname = ?,apphomepage = ?,apppage1 = ?,logopath = ?,sort = ?,uptime = ?,updatetype = ?,groupId = ? where appid = %d", table_apps_list,appModel.appid];
    
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		pthread_mutex_lock(&add_mutex);
//        sqlite3_bind_int(stmt, 1, appModel.apptype);
//		sqlite3_bind_text(stmt, 2, [appModel.appname UTF8String], -1, NULL);
//		sqlite3_bind_text(stmt, 3, [appModel.appicon UTF8String], -1, NULL);
//		sqlite3_bind_text(stmt, 4, [appModel.appvers UTF8String], -1, NULL);
//        sqlite3_bind_text(stmt, 5, [appModel.uptime UTF8String], -1, NULL);
//        sqlite3_bind_text(stmt, 6, [appModel.serverurl UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 7, appModel.permission);
//        sqlite3_bind_text(stmt, 8, [[appModel.cacheurl JSONString] UTF8String], -1, NULL);
//        sqlite3_bind_int(stmt, 9, appModel.showflag);
//        sqlite3_bind_text(stmt, 10, [appModel.appdesc UTF8String], -1, NULL);
//        sqlite3_bind_text(stmt, 11, [[appModel.apppics JSONString] UTF8String], -1, NULL);
        
        //appname = ?,apphomepage = ?,apppage1 = ?,logopath = ?,sort = ?,uptime = ?,updatetype = ?
        sqlite3_bind_text(stmt, 1, [appModel.appname UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [appModel.apphomepage UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [appModel.apppage1 UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [appModel.logopath UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 5, appModel.sort);
        sqlite3_bind_text(stmt, 6, [appModel.uptime UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 7, appModel.updatetype);
        sqlite3_bind_int(stmt, 8, appModel.groupId);
        
        //执行
		state = sqlite3_step(stmt);
		
		pthread_mutex_unlock(&add_mutex);
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
        
        
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		
        /*
		// 如果是需要显示在会话列表里的应用，还要往会话表里增加一条记录
		if(oldAppModel.showflag == 0 && appModel.showflag == 1)
		{
			eCloudDAO *db = [eCloudDAO getDatabase];
			NSString *convId = appModel.appid;
			
			if([db searchConversationBy:convId] == nil)
			{
				NSString *convType = [StringUtil getStringValue:appInConvType];
				//				默认屏蔽，收到该服务号的消息后，再设置为打开
				NSString *recvFlag = [StringUtil getStringValue:open_msg];
				
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
									 convId,@"conv_id",
									 convType,@"conv_type",
									 appModel.appname,@"conv_title",
									 recvFlag,@"recv_flag", nil];
				
				[[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
			}
		}
        else if (oldAppModel.showflag == 1 && appModel.showflag == 0){
            //应用推送消息由显示在会话列表改为不显示时，需要删除该应用的会话记录
            [[eCloudDAO getDatabase] deleteConvAndConvRecordsBy:appModel.appid];
        }
         */
	}
	return success;
}

-(bool)addOneAPPInfo:(APPListModel*)appModel
{
	/*bool success = false;
	NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(appid,apptype,appname,appicon,appvers,uptime,serverurl,permission,cacheurl,isnew,appShowflag,showflag,downloadFlag,appdesc,apppics) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", table_apps_list];
	sqlite3_stmt *stmt = nil;
	
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
	}
	else
	{
		pthread_mutex_lock(&add_mutex);
		sqlite3_bind_text(stmt, 1, [appModel.appid UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, appModel.apptype);
		sqlite3_bind_text(stmt, 3, [appModel.appname UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 4, [appModel.appicon UTF8String], -1, NULL);
		sqlite3_bind_text(stmt, 5, [appModel.appvers UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [appModel.uptime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [appModel.serverurl UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 8, appModel.permission);
        sqlite3_bind_text(stmt, 9, [[appModel.cacheurl JSONString] UTF8String], -1, NULL);

		sqlite3_bind_int(stmt, 10, appModel.isnew);
		sqlite3_bind_int(stmt, 11, appModel.appShowFlag);
        sqlite3_bind_int(stmt, 12, appModel.showflag);
        sqlite3_bind_int(stmt, 13, appModel.downloadFlag);
        sqlite3_bind_text(stmt, 14, [appModel.appdesc UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 15, [[appModel.apppics JSONString] UTF8String], -1, NULL);
        
        //	执行
		state = sqlite3_step(stmt);
		
		pthread_mutex_unlock(&add_mutex);
		//	执行结果
		if(state != SQLITE_DONE &&  state != SQLITE_OK)
		{
			//			执行错误
			NSLog(@"%s,exe state is %d",__FUNCTION__,state);
		}
		else
		{
			success = true;
		}
        
        
		//释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		
        
		// 如果是需要显示在会话列表里的应用，还要往会话表里增加一条记录
		if(appModel.showflag == 1 && success)
		{
			eCloudDAO *db = [eCloudDAO getDatabase];
			NSString *convId = appModel.appid;
			
			if([db searchConversationBy:convId] == nil)
			{
				NSString *convType = [StringUtil getStringValue:appInConvType];
				//				默认屏蔽，收到该服务号的消息后，再设置为打开
				NSString *recvFlag = [StringUtil getStringValue:open_msg];
				
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
									 convId,@"conv_id",
									 convType,@"conv_type",
									 appModel.appname,@"conv_title",
									 recvFlag,@"recv_flag", nil];
				
				[[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
			}
		}
        
	}
	return success;
     */
    bool success = false;
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(appid,apptype,appname,appicon,appvers,uptime,serverurl,permission,cacheurl,isnew,appShowflag,showflag,downloadFlag,appdesc,apppics,appauthname,appauthpwd,appauthtype,apphomepage,apppage1,apppage2,logopath,sort,update_time,updatetype,groupId) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", table_apps_list];
    sqlite3_stmt *stmt = nil;
    
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
    }
    else
    {
        pthread_mutex_lock(&add_mutex);
        sqlite3_bind_int(stmt, 1, appModel.appid);
        sqlite3_bind_int(stmt, 2, appModel.apptype);
        sqlite3_bind_text(stmt, 3, [appModel.appname UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [appModel.appicon UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [appModel.appvers UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [appModel.uptime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [appModel.serverurl UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 8, appModel.permission);
        sqlite3_bind_text(stmt, 9, [[appModel.cacheurl JSONString] UTF8String], -1, NULL);
        
        sqlite3_bind_int(stmt, 10, appModel.isnew);
        
//        新增app时，如果是国美版本，则增加此判断 有些默认要显示 有些不显示
        if ([UIAdapterUtil isGOMEApp]) {
            //            如果是默认要显示在界面上的app，那么设置为显示，否则隐藏
            if ([APPUtil isDefaultApp:appModel]) {
                appModel.appShowFlag = app_show_flag_show;
                [LogUtil debug:[NSString stringWithFormat:@"%s %@ 是默认app，显示",__FUNCTION__,appModel.appname]];
            }else{
                [LogUtil debug:[NSString stringWithFormat:@"%s %@ 不是默认app，不显示",__FUNCTION__,appModel.appname]];
                appModel.appShowFlag = app_show_flag_hide;
            }
        }
        
        sqlite3_bind_int(stmt, 11, appModel.appShowFlag);
        sqlite3_bind_int(stmt, 12, appModel.showflag);
        sqlite3_bind_int(stmt, 13, appModel.downloadFlag);
        sqlite3_bind_text(stmt, 14, [appModel.appdesc UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 15, [[appModel.apppics JSONString] UTF8String], -1, NULL);
        
        sqlite3_bind_text(stmt, 16, [appModel.appauthname UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 17, [appModel.appauthpwd UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 18, appModel.appauthtype);
        sqlite3_bind_text(stmt, 19, [appModel.apphomepage UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 20, [appModel.apppage1 UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 21, [appModel.apppage2 UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 22, [appModel.logopath UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 23, appModel.sort);
//        增加一个新的应用时，把update_time保存为当前的时间
        appModel.update_time = [[conn getConn]getCurrentTime];
        sqlite3_bind_int(stmt, 24, appModel.update_time);
        sqlite3_bind_int(stmt, 25, appModel.updatetype);
        sqlite3_bind_int(stmt, 26, appModel.groupId);
        
        //	执行
        state = sqlite3_step(stmt);
        
        pthread_mutex_unlock(&add_mutex);
        //	执行结果
        if(state != SQLITE_DONE &&  state != SQLITE_OK)
        {
            //			执行错误
            NSLog(@"%s,exe state is %d",__FUNCTION__,state);
        }
        else
        {
            success = true;
        }
        
        
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        
        
        // 如果是需要显示在会话列表里的应用，还要往会话表里增加一条记录
        if(appModel.showflag == 1 && success)
        {
            eCloudDAO *db = [eCloudDAO getDatabase];
            NSString *convId = appModel.appid;
            
            if([db searchConversationBy:convId] == nil)
            {
                NSString *convType = [StringUtil getStringValue:appInConvType];
                //				默认屏蔽，收到该服务号的消息后，再设置为打开
                NSString *recvFlag = [StringUtil getStringValue:open_msg];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     convId,@"conv_id",
                                     convType,@"conv_type",
                                     appModel.appname,@"conv_title",
                                     recvFlag,@"recv_flag", nil];
                
                [[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
            }
        }
        
    }
    return success;
}

#pragma mark - 获取所有应用的列表:0:未添加到我的页面 1:已添加到我的页面
-(NSMutableArray*)getAPPListWithAppShowflag:(int)appShowFlag{
    NSMutableArray *appsList = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where updatetype!=3 order by sort",table_apps_list];
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [self operateSql:sql Database:_handle toResult:result];
    
    //    NSLog(@"result-------%@",result);
    NSMutableArray *appArray = [[NSMutableArray alloc]init];
    // yanlei 判断是否有102和104的权限
    BOOL is2Sort = NO,is4Sort = NO;
    for(NSDictionary *dic in result)
    {
        if ([[dic valueForKey:@"sort"] intValue] == 2) {
            is2Sort = YES;
        }else if ([[dic valueForKey:@"sort"] intValue] == 4){
            is4Sort = YES;
        }
    }
    for(NSDictionary *dic in result)
    {
        // 数组中都是存放的单个轻应用
        //		APPListModel *appModel = [[APPListModel alloc]init];
        //		[self saveResult:dic toAPPModel:appModel];
        //		[appsList addObject:appModel];
        //		[appModel release];
        
        // yanlei 将轻应用分为三个组，前两个组分别是101/102与103/104，从105开始后面的为第三个组
        APPListModel *appModel = [[APPListModel alloc]init];
        
        [self saveResult:dic toAPPModel:appModel];
        
#ifdef _TAIHE_FLAG_
        [appArray addObject:appModel];
        [appModel release];
        if ([[dic valueForKey:@"appid"] intValue] == [[result[result.count-1] valueForKey:@"appid"] intValue]) {
            [appsList addObject:appArray];
            [appArray release];
        }
#else
     switch (appModel.sort) {
            case 1:
            case 2:
                [appArray addObject:appModel];
                [appModel release];
                if (appModel.sort == 1 && !is2Sort) {
                    [appsList addObject:appArray];
                    [appArray release];
                    appArray = [[NSMutableArray alloc]init];
                }else if (appModel.sort == 2 && is2Sort) {
                    [appsList addObject:appArray];
                    [appArray release];
                    appArray = [[NSMutableArray alloc]init];
                }
                break;
            case 3:
            case 4:
                [appArray addObject:appModel];
                [appModel release];
             
#ifdef _XIANGYUAN_FLAG_
             
             if (appModel.sort == 3 && is4Sort) {
                 [appsList addObject:appArray];
                 [appArray release];
                 appArray = [[NSMutableArray alloc]init];
             }
             break;
#else
             
             if (appModel.sort == 3 && !is4Sort) {
                 [appsList addObject:appArray];
                 [appArray release];
                 appArray = [[NSMutableArray alloc]init];
             }else if (appModel.sort == 4 && is4Sort) {
                 [appsList addObject:appArray];
                 [appArray release];
                 appArray = [[NSMutableArray alloc]init];
             }
             break;
             
#endif

            default:
                [appArray addObject:appModel];
                [appModel release];
                if ([[dic valueForKey:@"appid"] intValue] == [[result[result.count-1] valueForKey:@"appid"] intValue]) {
                    [appsList addObject:appArray];
                    [appArray release];
                }
                break;
        }
#endif
    }
    [result release];
    [pool release];
    
    return appsList;
}

#pragma mark - 查询数据库中apps_list中是否有101轻应用
-(BOOL)isExistAppByAppId:(int)appid{
    BOOL isExist = YES;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where updatetype!=3 and appid=%d",table_apps_list,appid];
    NSMutableArray *result = [[NSMutableArray alloc]init];
    [self operateSql:sql Database:_handle toResult:result];
    
    if (result.count == 0) {
        isExist = NO;
    }
    [result release];
    [pool release];
    
    return isExist;
}

#pragma mark - 获取所有应用
-(NSMutableArray *)getAPPList{
    NSMutableArray *appsList = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where updatetype!=3",table_apps_list];
	NSMutableArray *result = [[NSMutableArray alloc]init];
	[self operateSql:sql Database:_handle toResult:result];
    NSLog(@"%s result-------%@",__FUNCTION__,result);

	for(NSDictionary *dic in result)
	{
		APPListModel *appModel = [[APPListModel alloc]init];
		[self saveResult:dic toAPPModel:appModel];
		[appsList addObject:appModel];
		[appModel release];
	}

	[result release];
	[pool release];
	return appsList;
}


-(void)saveResult:(NSDictionary*)dic toAPPModel:(APPListModel *)appModel
{
	appModel.appid = [[dic valueForKey:@"appid"] intValue];
	appModel.apptype = [[dic valueForKey:@"apptype"] intValue];
	appModel.appname = [dic valueForKey:@"appname"];
    
    appModel.appauthname = [dic valueForKey:@"appauthname"];
    appModel.appauthpwd = [dic valueForKey:@"appauthpwd"];
    appModel.apphomepage = [dic valueForKey:@"apphomepage"];
    appModel.apppage1 = [dic valueForKey:@"apppage1"];
    appModel.apppage2 = [dic valueForKey:@"apppage2"];
    appModel.logopath = [dic valueForKey:@"logopath"];
    appModel.appauthtype = [[dic valueForKey:@"appauthtype"] intValue];
    appModel.sort = [[dic valueForKey:@"sort"] intValue];
    appModel.update_time = [[dic valueForKey:@"update_time"] intValue];
    appModel.updatetype = [[dic valueForKey:@"updatetype"] intValue];
    
	appModel.appicon = [dic valueForKey:@"appicon"];
	appModel.appvers = [dic valueForKey:@"appvers"];
	appModel.uptime = [dic valueForKey:@"uptime"];
	appModel.serverurl = [dic valueForKey:@"serverurl"];
    appModel.permission = [[dic valueForKey:@"permission"] intValue];
    appModel.cacheurl = [[dic valueForKey:@"cacheurl"] objectFromJSONString];
    
	appModel.isnew = [[dic valueForKey:@"isnew"] intValue];
	appModel.appShowFlag = [[dic valueForKey:@"appShowFlag"] intValue];
    appModel.showflag = [[dic valueForKey:@"showflag"] intValue];
    appModel.downloadFlag = [[dic valueForKey:@"downloadFlag"] intValue];
    appModel.appdesc = [dic valueForKey:@"appdesc"];
    appModel.apppics = [[dic valueForKey:@"apppics"] objectFromJSONString];
    appModel.groupId = [[dic valueForKey:@"groupId"]intValue];
}

#pragma mark - 更新应用是否被添加状态
-(void)updateHasAddedOfAPPModel:(NSString *)appId withAppShowflag:(int)appShowflag{
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set appShowFlag = %d where appid = '%@'",table_apps_list,appShowflag,appId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

#pragma mark - 设置应用已点击
-(void)setAPPModelRead:(NSString *)appId{
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set isnew = 0 where appid = '%@'",table_apps_list,appId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

#pragma mark - 标记应用已下载
-(void)setAPPModelDownLoadFlag:(NSString *)appId{
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set downloadFlag = 1 where appid = '%@'",table_apps_list,appId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}
#pragma mark - 图标下载完成
-(void)updateDownLoadFlag:(APPListModel *)appModel{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"update %@ set downloadFlag = 1 where appid = %d",table_apps_list,appModel.appid];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark - 获取所有新应用的数目
-(NSInteger)getAllNewAppsCount{
    NSInteger _count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where isnew = 1",table_apps_list];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}

#pragma mark - 根据appid获取应用信息
-(APPListModel*)getAPPModelByAppid:(NSInteger)appId{
    APPListModel *appModel = [[APPListModel alloc]init];
    
#ifdef _GOME_FLAG_
    if (appId == GOME_EMAIL_APP_ID) {
        appModel.appid = GOME_EMAIL_APP_ID;
        appModel.appname = GOME_EAMIL_APP_NAME;
        return [appModel autorelease];
    }
#endif
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where appid = %d",table_apps_list,appId];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if(result.count == 1)
		{
			[self saveResult:[result objectAtIndex:0] toAPPModel:appModel];
		}
	}
	
	return [appModel autorelease];
}

#pragma mark - 删除某一个应用(添加删除标示)
-(void)deleteAPPModelUpdatetype:(APPListModel *)appModel{
    NSInteger appid = appModel.appid;
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set updatetype = 3 where appid = %d",table_apps_list,appid];
    [self operateSql:sql Database:_handle toResult:nil];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s appid is %d appname is %@",__FUNCTION__,appModel.appid,appModel.appname]];

}

#pragma mark - 删除某一个应用
-(void)deleteAPPModel:(APPListModel *)appModel{
	NSString *appid = appModel.appid;
    
    if (![appid length]) {
        return;
    }

    //删除应用图标
    [StringUtil deleteFile:[APPUtil getAPPResPath:appModel]];
    
    //删除该应用对应推送消息
    [self deleteAPPPushByAppid:appid];
    
    //删除该应用对应的会话记录
    [[eCloudDAO getDatabase] deleteConvAndConvRecordsBy:appid];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where appid = '%@'",table_apps_list,appid];
	[self operateSql:sql Database:_handle toResult:nil];
}


#pragma mark --------------------------应用推送信息--------------------------

#pragma mark - 保存应用推送信息
-(bool)saveAPPPushNotification:(APPPushNotification*)appPushNoti{
    
    //同步应用列表
    conn *_conn = [conn getConn];
    
	APPListModel *appModel = [self getAPPModelByAppid:appPushNoti.appid];
    if(![appModel.appid length])
    {
        [_conn syncAppList];
        return false;
    }
    
    int msgid = [self getMaxMsgId] + 1;
    NSLog(@"msgid---------%i",msgid);
    
	[appPushNoti setMsgId:msgid];
    
	bool success = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	if([self beginTransaction])
	{
		NSString *sql = [NSString stringWithFormat:@"insert into %@(msgId,read_flag,appid,notinum,pri,title,summary,pushurl,notitime,src) values(?,?,?,?,?,?,?,?,?,?)",table_app_msg];
		
		sqlite3_stmt *stmt = nil;
		
		pthread_mutex_lock(&add_mutex);
		int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
		pthread_mutex_unlock(&add_mutex);
		
		if(state != SQLITE_OK)
		{
			NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
			pthread_mutex_lock(&add_mutex);
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
		}
		else
		{
			pthread_mutex_lock(&add_mutex);
			sqlite3_bind_int(stmt, 1, appPushNoti.msgId);
			sqlite3_bind_int(stmt, 2, appPushNoti.read_flag);
			sqlite3_bind_text(stmt, 3, [appPushNoti.appid UTF8String], -1, NULL);
			sqlite3_bind_int(stmt, 4, appPushNoti.notinum );
			sqlite3_bind_int(stmt, 5,appPushNoti.pri);
			sqlite3_bind_text(stmt, 6, [appPushNoti.title UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 7, [appPushNoti.summary UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 8, [appPushNoti.pushurl UTF8String], -1, NULL);
            sqlite3_bind_int(stmt, 9, appPushNoti.notitime);
            sqlite3_bind_text(stmt, 10, [appPushNoti.src UTF8String], -1, NULL);
            
			//	执行
			state = sqlite3_step(stmt);
			
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
			
			//	执行结果
			if(state != SQLITE_DONE &&  state != SQLITE_OK)
			{
				//			执行错误
				NSLog(@"%s,exe state is %d",__FUNCTION__,state);
			}
			else
			{
                success = true;
                
                //如果该推送消息对应的应用需要在会话列表显示，那么需要在会话表里进行相应的修改，对于显示在会话列表里的应用，会话id就是应用id
                APPListModel *_appModel = [self getAPPModelByAppid:appPushNoti.appid];
                if(_appModel.showflag == 1)
                {
                    //先判断会话记录有没有
                    eCloudDAO *db = [eCloudDAO getDatabase];
                    NSString *convId = _appModel.appid;
                    
                    if([db searchConversationBy:convId] == nil)
                    {
                        NSString *convType = [StringUtil getStringValue:appInConvType];
                        //默认屏蔽，收到该服务号的消息后，再设置为打开
                        NSString *recvFlag = [StringUtil getStringValue:open_msg];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             convId,@"conv_id",
                                             convType,@"conv_type",
                                             _appModel.appname,@"conv_title",
                                             recvFlag,@"recv_flag", nil];
                        
                        [[eCloudDAO getDatabase] addConversation:[NSArray arrayWithObject:dic]];
                    }
                    
                    //---------------------------------------------
                    //更新应用会话记录
                    
                    //记录last_msg_id,last_msg_body,last_msg_time ，默认是文本消息
                    NSString *sql = [NSString stringWithFormat:@"update %@ set last_msg_id=?,last_msg_body = ?, last_msg_time=? , last_msg_type = %d,display_flag = 0 where conv_id = '%@' and conv_type = %d"
                                     ,table_conversation,type_text,convId,appInConvType];
                    
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
                    else
                    {
                        //		绑定值
                        pthread_mutex_lock(&add_mutex);
                        
                        sqlite3_bind_int(stmt, 1,appPushNoti.msgId );
                        sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%@: %@",appPushNoti.title,appPushNoti.summary] UTF8String],-1,NULL);
                        sqlite3_bind_text(stmt, 3, [[StringUtil getStringValue:appPushNoti.notitime] UTF8String],-1,NULL);//last_msg_time
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
        }
        
		[self commitTransaction];
	}
	[pool release];
	return success;
}

-(int)getMaxMsgId
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select max(msgId) as max_msg_id from %@",table_app_msg];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int maxMsgId = [[[result objectAtIndex:0]valueForKey:@"max_msg_id"]intValue];
	[pool release];
	return maxMsgId;
}

#pragma mark - 获取某一应用的所有推送消息
-(NSMutableArray *)getAPPPushNotificationWithAppid:(NSString *)appId{
    NSMutableArray *appsList = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where appid = '%@'",table_app_msg,appId];
	NSMutableArray *result = [[NSMutableArray alloc]init];
	[self operateSql:sql Database:_handle toResult:result];
    
    NSLog(@"result-------%@",result);
    
	for(NSDictionary *dic in result)
	{
		APPPushNotification  *appNoti = [[APPPushNotification alloc]init];
		[self saveResult:dic toAPPNotification:appNoti];
		[appsList addObject:appNoti];
		[appNoti release];
	}
	[result release];
	[pool release];
    
	return appsList;
}

#pragma mark - 某个应用收到的消息的条数
- (int)getMsgCountByAppId:(NSString *)appId
{
    NSString *sql = [NSString stringWithFormat:@"select count(msgId) as _count from %@ where appid = '%@'",table_app_msg,appId];
    NSMutableArray *result = [self querySql:sql];
    if(result.count > 0)
    {
        return [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    }
    return 0;
}

#pragma mark - 分页获取指定应用消息
-(NSArray*)getAPPPushNotificationWithAppid:(NSString *)appId andLimit:(int)_limit andOffset:(int)_offset{
    
    NSMutableArray *appsList = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where appid = '%@' order by notitime limit(%d) offset(%d)",table_app_msg,appId, _limit,_offset];
    
	NSMutableArray *result = [[NSMutableArray alloc]init];
	[self operateSql:sql Database:_handle toResult:result];
    
    NSLog(@"result-------%@",result);
    
	for(NSDictionary *dic in result)
	{
		APPPushNotification  *appNoti = [[APPPushNotification alloc]init];
		[self saveResult:dic toAPPNotification:appNoti];
		[appsList addObject:appNoti];
		[appNoti release];
	}
	[result release];
	[pool release];
    
	return appsList;
}


-(void)saveResult:(NSDictionary*)dic toAPPNotification:(APPPushNotification *)appNoti
{
    appNoti.msgId = [[dic valueForKey:@"msgId"] intValue];
    appNoti.read_flag = [[dic valueForKey:@"read_flag"] intValue];
	appNoti.appid = [dic valueForKey:@"appid"];
	appNoti.notinum = [[dic valueForKey:@"notinum"] intValue];
	appNoti.pri = [[dic valueForKey:@"pri"] intValue];
	appNoti.title = [dic valueForKey:@"title"];
	appNoti.summary = [dic valueForKey:@"summary"];
	appNoti.pushurl = [dic valueForKey:@"pushurl"];
	appNoti.notitime = [[dic valueForKey:@"notitime"] intValue];
    appNoti.src = [dic valueForKey:@"src"];
    appNoti.notiTimeDisplay = [StringUtil getDisplayTime:[dic valueForKey:@"notitime"]];
}

#pragma mark - 获取某应用新消息数目
-(NSInteger)getAllNewPushNotiCountWithAppid:(NSString *)appId{
    NSInteger _count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 0 and appid = '%@'",table_app_msg,appId];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}

#pragma mark - 获取所有未读消息数目
-(NSInteger)getAllNewPushNotiCount{
    NSInteger _count = 0;
	@autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 0",table_app_msg];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}

#pragma mark - 获取所有不在我的页面应用未读消息数目
-(NSInteger)getAllNewPushNotiCountOutOfMine{
    NSInteger _count = 0;
	@autoreleasepool {
        /*
        NSMutableArray *temArr = [self getAPPListWithAppShowflag:0];
        
        if ([temArr count]) {
            for (APPListModel *appModel in temArr) {
                NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 0 and appid = %@",table_app_msg,appModel.appid];
                NSMutableArray *result = [NSMutableArray array];
                [self operateSql:sql Database:_handle toResult:result];
                if([result count]>0)
                {
                    _count += [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
                }
            }
        }
         */
        
        NSString *sql1 = [NSString stringWithFormat:@"(select appid from %@ where appShowFlag = 0)",table_apps_list];
        NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 0 and appid in %@",table_app_msg,sql1];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:_handle toResult:result];
//        NSLog(@"result--------%@",result);
        if([result count]>0)
        {
            _count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
        }
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}

#pragma mark - 获取所有显示在会话列表中应用的未读消息总数
-(NSInteger)getAllNewPushCountOfAPPInContactList{
    NSInteger _count = 0;
	@autoreleasepool {
        /*
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where showflag = 1",table_apps_list];
        NSMutableArray *result = [[NSMutableArray alloc]init];
        [self operateSql:sql Database:_handle toResult:result];
        
        //NSLog(@"result-------%@",result);
        
        for(NSDictionary *dic in result)
        {
            NSString *appid = [dic valueForKey:@"appid"];
            if ([appid length]) {
                _count += [self getAllNewPushNotiCountWithAppid:appid];
            }
        }
        [result release];
         */
        
        NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where read_flag = 0 and appid in (select appid from %@ where showflag = 1)",table_app_msg,table_apps_list];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
        //NSLog(@"result-------%@",result);
		if([result count]>0)
		{
			_count = [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
		}
        
	}
    //	[LogUtil debug:[NSString stringWithFormat:@"%s,%d",__FUNCTION__,_count]];
	return _count;
}

#pragma mark - 把某一个应用的所有的未读消息修改为已读
-(void)updateReadFlagOfAPPNoti:(NSString *)appId{
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 1 where appid = '%@'",table_app_msg,appId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
    //更新Tabar提示
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_PUSH_REFRESH_NOTIFICATION object:nil];
}

#pragma mark - 把某一个应用的一条未读消息修改为已读
-(void)updateReadFlagOfAPPPushNotification:(APPPushNotification*)appPushNotif{
     NSString *msgId = appPushNotif.msgId;
    @autoreleasepool {
		NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 1 where msgId = %d",table_app_msg,msgId];
		[self operateSql:sql Database:_handle toResult:nil];
	}
}

#pragma mark - 设置会话列表里面的所有应用消息为已读
-(void)setAllAppMsgInContactListToRead{
    
    @autoreleasepool {
        /*
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where showflag = 1",table_apps_list];
        NSMutableArray *result = [[NSMutableArray alloc]init];
        [self operateSql:sql Database:_handle toResult:result];
        
        //NSLog(@"result-------%@",result);
        
        for(NSDictionary *dic in result)
        {
            NSString *appid = [dic valueForKey:@"appid"];
            if ([appid length]) {
                [self updateReadFlagOfAPPNoti:appid];
            }
        }
        [result release];
         */
        //NSString *sql1 = [NSString stringWithFormat:@"select appId from %@ where showflag = 1)",table_apps_list];
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 1 where appid in (select appid from %@ where showflag = 1)",table_app_msg,table_apps_list];
        
        [self operateSql:sql Database:_handle toResult:nil];
	}
    //更新Tabar提示
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_PUSH_REFRESH_NOTIFICATION object:nil];
}


#pragma mark - 删除一条推送消息
-(void)deleteAPPPushNotification:(APPPushNotification*)appPushNotif{
    NSString *msgId = appPushNotif.msgId;
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where msgId = %d",table_app_msg,msgId];
        [self operateSql:sql Database:_handle toResult:nil];

    }
}

#pragma mark - 根据appid删除某一个应用所有的推送消息
-(void)deleteAPPPushByAppid:(NSString *)appId{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where appid = '%@'",table_app_msg,appId];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark --------------------------统计数据上报--------------------------

#pragma mark - 保存一条统计数据上报
-(bool)saveOneAPPStateRecord:(APPStateRecord*)appStateRecord{
    int msgid = [self getMaxStateRecord] + 1;
    NSLog(@"msgid---------%i",msgid);
    
	[appStateRecord setRecordid:msgid];
    
	bool success = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	if([self beginTransaction]){
		NSString *sql = [NSString stringWithFormat:@"insert into %@(recordid,appid,optype,optime) values(?,?,?,?)",table_app_state_record];
		
		sqlite3_stmt *stmt = nil;
		
		pthread_mutex_lock(&add_mutex);
		int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
		pthread_mutex_unlock(&add_mutex);
		
		if(state != SQLITE_OK)
		{
			NSLog(@"%s,prepare state is %d",__FUNCTION__,state);
			pthread_mutex_lock(&add_mutex);
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
		}
		else
		{
			pthread_mutex_lock(&add_mutex);
			sqlite3_bind_int(stmt, 1, appStateRecord.recordid);
            sqlite3_bind_text(stmt,2, [appStateRecord.appid UTF8String], -1, NULL);
			sqlite3_bind_int(stmt, 3,appStateRecord.optype);
			sqlite3_bind_text(stmt, 4, [appStateRecord.optime UTF8String], -1, NULL);
            
			//	执行
			state = sqlite3_step(stmt);
			
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
			
			//	执行结果
			if(state != SQLITE_DONE &&  state != SQLITE_OK){
				//			执行错误
				NSLog(@"%s,exe state is %d",__FUNCTION__,state);
			}
			else{
                success = true;
            }
        }
        
        [self commitTransaction];
    }
    [pool release];
	return success;
}

-(int)getMaxStateRecord
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select max(recordid) as max_record_id from %@",table_app_state_record];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	int maxMsgId = [[[result objectAtIndex:0]valueForKey:@"max_record_id"]intValue];
	[pool release];
	return maxMsgId;
}


#pragma mark - 获取某一应用最近一条统计记录

-(APPStateRecord *)getLatestAPPStateRecordOfApp:(NSString *)appid{
    
    APPStateRecord *appStateRec = [[APPStateRecord alloc]init];
	@autoreleasepool {
//		NSString *sql = [NSString stringWithFormat:@"select * from %@ where appid = %@ and optime in (select max(optime) from %@ where appid = %@)",table_app_state_record,appid,table_app_state_record,appid];
//        update by shisp
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where appid = '%@' order by optime desc limit(1)",table_app_state_record,appid];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
//        NSLog(@"result---------%@",result);
		if(result.count == 1)
		{
            [self saveResult:[result objectAtIndex:0] toAPPStateRecord:appStateRec];
        }
	}
	
	return [appStateRec autorelease];
}

-(void)saveResult:(NSDictionary*)dic toAPPStateRecord:(APPStateRecord *)appStateRec
{
    appStateRec.recordid = [[dic valueForKey:@"recordid"] intValue];
	appStateRec.appid = [dic valueForKey:@"appid"];
	appStateRec.optype = [[dic valueForKey:@"optype"] intValue];
	appStateRec.optime = [dic valueForKey:@"optime"];
}
#pragma mark - 初始化应用数据
- (void)initAppData{
    //    NSArray *appModelArray = @[@{@"appId":101;},@{@"appId":102;},@{@"appId":103;}];
    
    NSMutableArray *appsArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        APPListModel *appListModel = [[APPListModel alloc]init];
        if (i == 0) {
            appListModel.appid = LONGHU_DAIBAN_APP_ID;
            appListModel.appname = @"待办审批";
            appListModel.appicon = @"agent_icon.png";
            appListModel.apphomepage = @"http://moapproval.longfor.com:8080/moapproval/list.html";
            appListModel.appauthtype = 0;
            appListModel.sort = 1;
        }else if (i == 1){
            appListModel.appid = LONGHU_MAIL_APP_ID;
            appListModel.appname = @"邮件";
            appListModel.appicon = @"mail_icon.png";
            appListModel.apphomepage = @"http://pcc.263.net/PCC/263mail.do?";
            appListModel.appauthtype = 0;
            appListModel.sort = 2;
        }else if (i == 2){
            appListModel.appid = 103;
            appListModel.appname = [StringUtil getLocalizableString:@"contact_FileTransfer"];
            appListModel.appicon = @"file_icon.png";
            appListModel.appauthtype = 1;
            appListModel.sort = 3;
        }
        appListModel.updatetype = 1;
        [appsArray addObject:appListModel];
        [appListModel release];
    }
    //保存应用到数据库
    bool success = [[APPPlatformDOA getDatabase] saveAPPListInfo:appsArray];
//    [appsArray release];
}

- (NSArray *)getGOMEAppMsgList
{
    NSMutableArray *msgList = [NSMutableArray array];
//    分组找到有消息的应用id
    NSString *sql = [NSString stringWithFormat:@"select sender_id from %@ where broadcast_type = %d group by sender_id ",table_broadcast,appNotice_broadcast];
    
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count) {
        for (NSDictionary *dic in result) {
            
            NSString *appId = dic[@"sender_id"];
            
            Conversation *conv = [self getLastAppMsg:appId];
            if (conv) {
                [msgList addObject:conv];
            }
        }
    }
    
    return msgList;
}

- (NSInteger)getUnreadAppMsgCount:(NSString *)appId
{
    //            查询广播表，找到应用的未读消息数
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where sender_id = '%@' and read_flag = 1",table_broadcast,appId];
    
    NSMutableArray *tempResult = [self querySql:sql];
    
    return  [[tempResult[0] valueForKey:@"_count"]integerValue];
}

- (Conversation *)getLastAppMsg:(NSString *)appId
{
    NSString *sql = nil;
    NSMutableArray *tempResult = nil;
    NSDictionary *tempDic = nil;
    
    //            查询应用表，找到应用名称
    APPListModel *appModel = [self getAPPModelByAppid:appId.integerValue];
    if (!appModel.appid) {
//        如果没有查到某个应用，那么设置一个默认值
        [LogUtil debug:[NSString stringWithFormat:@"%s 本地没有此应用 appid is %@",__FUNCTION__,appId]];

        appModel.appid = appId.intValue;
        appModel.appname = [NSString stringWithFormat:@"%@",appId];
    }
    
    if (appModel.appid) {
        Conversation *conv = [[[Conversation alloc]init]autorelease];
        conv.conv_type = appNoticeBroadcastConvType;
        conv.conv_id = appId;
        conv.conv_title = appModel.appname;
        
        conv.appModel = appModel;
        
        //            查询广播表，找到应用的未读消息数
        
        conv.unread = [self getUnreadAppMsgCount:appId];
        
        //            查询广播表，找到最近一条消息的标题和时间
        
        sql = [NSString stringWithFormat:@"select sendtime,asz_titile from %@ where sender_id = '%@' order by sendtime desc limit(1)",table_broadcast,appId];
        tempResult = [self querySql:sql];
        if (tempResult.count > 0) {
            tempDic = tempResult[0];
            
            ConvRecord *convRecord = [[[ConvRecord alloc]init]autorelease];
            
            convRecord.send_flag = send_success;
            
            conv.last_record = convRecord;
            
            convRecord.msg_type = type_text;
            convRecord.msg_time = tempDic[@"sendtime"];
            convRecord.msg_body = tempDic[@"asz_titile"];
            
        }
        return conv;
    }
    return nil;

}

- (void)deleteAllMsgOfApp:(NSString *)appId{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where sender_id = '%@'",table_broadcast,appId];
    [self operateSql:sql Database:_handle toResult:nil];
    
//    更新最后一条消息
    [[eCloudDAO getDatabase]updateLastConvRecordOfBroadcastConvType:appNoticeBroadcastConvType];
    
//    NSString *convId = [[eCloudDAO getDatabase]getConvIdOfBroadcastConvType:appNoticeBroadcastConvType];
//    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil];
//    [[eCloudDAO getDatabase] sendNewConvNotification:dic andCmdType:delete_one_msg];

}

//从广播表里删除一条应用通知
-(void)removeOneAppMsgByMsgId:(NSString *)msg_id
{
    NSString *sql = [NSString stringWithFormat:@"select sender_id from %@ where msg_id = '%@'",table_broadcast,msg_id];
    NSMutableArray *result = [self querySql:sql];
    if (result.count) {
        NSString *appId = [result[0] valueForKey:@"sender_id"];
        
        sql = [NSString stringWithFormat:@"delete from %@ where msg_id = %@ ",table_broadcast,msg_id];
        [self operateSql:sql Database:_handle toResult:nil];
        
//        修改相应会话的最后一条消息
        [[eCloudDAO getDatabase]updateLastConvRecordOfBroadcastConvType:appNoticeBroadcastConvType];

//        通知消息一级界面刷新
        [[eCloudDAO getDatabase] sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:appId,@"app_id", nil] andCmdType:remove_app_msg];
    }
}

/*
 功能描述
 设置某一个应用的所有消息为已读
 
 参数：应用id
 */
- (void)setAppMsgReadOfApp:(NSString *)appId{
    NSString *sql = [NSString stringWithFormat:@"update %@ set read_flag = 0  where sender_id = '%@'",table_broadcast,appId];
    [self operateSql:sql Database:_handle toResult:nil];
    
    NSString *convId = [[eCloudDAO getDatabase]getConvIdOfBroadcastConvType:appNoticeBroadcastConvType];

    if (convId) {
//        通知会话列表刷新
        [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id", nil] andCmdType:add_new_conversation];
    }
    //        通知一级1级界面刷新
    [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:appId,@"app_id", nil] andCmdType:read_app_msg];
}

- (void)updateApp:(APPListModel *)appModel withShowFlag:(int)appShowFlag{
    NSString *sql = [NSString stringWithFormat:@"update %@ set appShowFlag = %d where appid = %d",table_apps_list,appShowFlag,appModel.appid];
    
    if (appShowFlag == app_show_flag_show){
        sql = [NSString stringWithFormat:@"update %@ set appShowFlag = %d ,update_time = %d where appid = %d",table_apps_list,appShowFlag,[[conn getConn]getCurrentTime],appModel.appid];
    }
    
    [self operateSql:sql Database:_handle toResult:nil];
    
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = refresh_app_list;
    [[NotificationUtil getUtil]sendNotificationWithName:APPLIST_UPDATE_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
}

- (void)removeAllApp{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",table_apps_list];
    [self operateSql:sql Database:_handle toResult:nil];
}

/** 根据搜索条件搜索国美应用 */
- (NSArray *)searchGomeAppBy:(NSString *)searchStr
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where appname like '%%%@%%'",table_apps_list,searchStr];
    NSMutableArray *result = [self querySql:sql];
    
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (NSDictionary *dic in result) {
        APPListModel *appModel = [[[APPListModel alloc]init]autorelease];
        [self saveResult:dic toAPPModel:appModel];
        /** 只搜索存在的应用 */
        UIViewController *ctl = [[[NSClassFromString(appModel.apppage1) alloc] init]autorelease];
        if (ctl) {
            [mArray addObject:appModel];
        }
    }
    return mArray;
}
@end
