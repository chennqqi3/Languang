//
//  ScheduleConn.m
//  eCloud
//
//  Created by  lyong on 14-10-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "ScheduleConn.h"
#import "eCloudDAO.h"
#import "helperObject.h"
#import "LogUtil.h"
#import "StringUtil.h"
#import "conn.h"
#import "Emp.h"

@implementation ScheduleConn

+ (ScheduleConn *)getScheduleConn
{
    static ScheduleConn * singleton;
    if (!singleton)
    {
        singleton = [[ScheduleConn alloc] init];
        
    }
    return singleton;
}

#pragma mark  日程助手  创建
-(int)createHelperSchedule:(helperObject *)helperObj
{
    conn *_conn = [conn getConn];
    eCloudDAO* db = [eCloudDAO getDatabase];
    CREATESCHEDULE pCreate;
    //	初始化
	memset(&pCreate,0,sizeof(pCreate));
    
    pCreate.cType=helperObj.ring_type;
    pCreate.dwBeginTime=helperObj.start_time.intValue;
    pCreate.dwEndTime=helperObj.end_time.intValue;
    pCreate.dwUserID=helperObj.create_emp_id;
    pCreate.wUserNum=0;
    
    const char *c_helper_detail = [helperObj.helper_detail cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_detail_num = strlen(c_helper_detail);
    
    const char *c_helper_id = [helperObj.helper_id cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_num = strlen(c_helper_id);
    
    const char *c_helper_name = [helperObj.helper_name cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_name_num = strlen(c_helper_name);
    
    memcpy(pCreate.aszScheduleDetail, c_helper_detail, c_helper_detail_num);
    memcpy(pCreate.aszScheduleID,c_helper_id, c_helper_num);
    memcpy(pCreate.aszGroupID, c_helper_id, c_helper_num);
    memcpy(pCreate.aszScheduleName,c_helper_name, c_helper_name_num);
    
    int lastid=0;
    for (int i=0; i<[helperObj.empArray count]; i++) {
        Emp *emp= [helperObj.empArray objectAtIndex:i];
        pCreate.aUserID[i]=emp.emp_id;
        lastid=i;
    }
    pCreate.wUserNum=[helperObj.empArray count];
    pCreate.cOperType=1;
    
    
    [LogUtil debug:[NSString stringWithFormat:@"----创建日程－－－%s  %s  %s  %d",pCreate.aszScheduleID,pCreate.aszScheduleName,pCreate.aszScheduleDetail,pCreate.aUserID[0]]];
    int state=  CLIENT_CreateSchedule([_conn getConnCB],&pCreate);
    
    if (state==0) { //成功
        
        
        NSString *ringtypestr=[NSString stringWithFormat:@"%d",helperObj.ring_type];
        NSString *create_emp_id=[NSString stringWithFormat:@"%d",helperObj.create_emp_id];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",helperObj.helper_id,@"group_id",helperObj.helper_name,@"helper_title",helperObj.helper_detail,@"helper_detail",create_emp_id,@"helper_create_emp_id",helperObj.create_time,@"create_time",helperObj.start_time,@"start_time",helperObj.end_time,@"end_time",helperObj.start_date,@"start_date",ringtypestr,@"warnning_type",helperObj.ring_str,@"warnning_str",@"0",@"is_read", nil];
        [LogUtil debug:[NSString stringWithFormat:@"---dic  here--  %@",dic]];
        [db addHelperSchedule:[NSArray arrayWithObject:dic]];
        
        //---日程 参与人员
        NSMutableArray *tempArray = [NSMutableArray array];
        
        NSDictionary *empdic;
        NSArray *emps=helperObj.empArray;
        for (int i=0; i<[emps count]; i++) {
            Emp *emp=[emps objectAtIndex:i];
            NSString *empid=[NSString stringWithFormat:@"%d",emp.emp_id];
            empdic=[NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",empid,@"emp_id", nil];
            [tempArray addObject:empdic];
        }
        
        if ([helperObj.empArray count]>1) {
            NSString *empid=[NSString stringWithFormat:@"%d",helperObj.create_emp_id];
            empdic=[NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",empid,@"emp_id", nil];
            [tempArray addObject:empdic];
        }
        
        [db addHelperEmp:tempArray];
        
        
        
        // Set up the fire time
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        NSDate *startdate=[NSDate dateWithTimeIntervalSince1970:[helperObj.start_time intValue]];
        NSString *startstr= [fmt stringFromDate:startdate];
        if (helperObj.ring_type>0) {
            
            NSDate *tempdate=nil;
            
            if (helperObj.ring_type==1) {//正点
                tempdate=startdate;
            }else if(helperObj.ring_type==2) {//10分钟
                tempdate= [startdate dateByAddingTimeInterval:-10*60];
            }
            else if(helperObj.ring_type==3) {//30分钟
                tempdate= [startdate dateByAddingTimeInterval:-30*60];
            }
            else if(helperObj.ring_type==4) {//1小时
                tempdate= [startdate dateByAddingTimeInterval:-60*60];
            }
            else if(helperObj.ring_type==5) {//1天前
                tempdate= [startdate dateByAddingTimeInterval:-24*60*60];
            }
            
            NSString *starttime= [fmt stringFromDate:tempdate];
            [LogUtil debug:[NSString stringWithFormat:@"--localNotif-starttime  --  %@  startstr %@  ringtype %d",starttime,startstr,helperObj.ring_type]];
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif != nil)
            {
                localNotif.fireDate = tempdate;
                localNotif.timeZone = [NSTimeZone defaultTimeZone];
                
                // Notification details
                localNotif.alertBody = [NSString stringWithFormat:@"%@:%@ \n%@",[StringUtil getLocalizableString:@"schedule_show"],startstr,helperObj.helper_name];
                // Set the action button
                localNotif.alertAction = @"打开";
                
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                //localNotif.applicationIconBadgeNumber = 1;
                
                // Specify custom data for the notification
                //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:helperObj.helper_id forKey:@"localNoticeId"];
                NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
                localNotif.userInfo = infoDict;
                
                // Schedule the notification
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                [localNotif release];
            }
            
        }
        
    }
    
    return state;
    // [LogUtil debug:[NSString stringWithFormat:@"---创建日程-state-- %d ",state]];
}

#pragma mark  日程助手  日程修改
-(int)modifyHelperSchedule:(helperObject *)helperObj
{
    
    conn *_conn = [conn getConn];
    eCloudDAO* db = [eCloudDAO getDatabase];
    CREATESCHEDULE pCreate;
    //	初始化
	memset(&pCreate,0,sizeof(pCreate));
    
    pCreate.cType=helperObj.ring_type;
    pCreate.dwBeginTime=helperObj.start_time.intValue;
    pCreate.dwEndTime=helperObj.end_time.intValue;
    pCreate.dwUserID=helperObj.create_emp_id;
    pCreate.wUserNum=0;
    
    const char *c_helper_detail = [helperObj.helper_detail cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_detail_num = strlen(c_helper_detail);
    
    const char *c_helper_id = [helperObj.helper_id cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_num = strlen(c_helper_id);
    
    const char *c_helper_name = [helperObj.helper_name cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_name_num = strlen(c_helper_name);
    
    memcpy(pCreate.aszScheduleDetail, c_helper_detail, c_helper_detail_num);
    memcpy(pCreate.aszScheduleID,c_helper_id, c_helper_num);
    memcpy(pCreate.aszGroupID, c_helper_id, c_helper_num);
    memcpy(pCreate.aszScheduleName,c_helper_name, c_helper_name_num);
    
    int lastid=0;
    for (int i=0; i<[helperObj.empArray count]; i++) {
        Emp *emp= [helperObj.empArray objectAtIndex:i];
        pCreate.aUserID[i]=emp.emp_id;
        lastid=i;
    }
    pCreate.wUserNum=[helperObj.empArray count];
    pCreate.cOperType=2;
    
    
    [LogUtil debug:[NSString stringWithFormat:@"----创建日程－－－%s  %s  %s  %d",pCreate.aszScheduleID,pCreate.aszScheduleName,pCreate.aszScheduleDetail,pCreate.aUserID[0]]];
    int state=  CLIENT_CreateSchedule([_conn getConnCB],&pCreate);
    
    if (state==0) { //成功
        
        
        NSString *ringtypestr=[NSString stringWithFormat:@"%d",helperObj.ring_type];
        NSString *create_emp_id=[NSString stringWithFormat:@"%d",helperObj.create_emp_id];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",helperObj.helper_id,@"group_id",helperObj.helper_name,@"helper_title",helperObj.helper_detail,@"helper_detail",create_emp_id,@"helper_create_emp_id",helperObj.create_time,@"create_time",helperObj.start_time,@"start_time",helperObj.end_time,@"end_time",helperObj.start_date,@"start_date",ringtypestr,@"warnning_type",helperObj.ring_str,@"warnning_str",@"0",@"is_read", nil];
        [LogUtil debug:[NSString stringWithFormat:@"---dic  here--  %@",dic]];
        [db addHelperSchedule:[NSArray arrayWithObject:dic]];
        [db deleteHelperScheduleMember:helperObj.helper_id];
        //---日程 参与人员
        NSMutableArray *tempArray = [NSMutableArray array];
        
        NSDictionary *empdic;
        NSArray *emps=helperObj.empArray;
        for (int i=0; i<[emps count]; i++) {
            Emp *emp=[emps objectAtIndex:i];
            NSString *empid=[NSString stringWithFormat:@"%d",emp.emp_id];
            empdic=[NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",empid,@"emp_id", nil];
            [tempArray addObject:empdic];
            //            [db addHelperEmp:[NSArray arrayWithObject:empdic]];
        }
        
        if ([helperObj.empArray count]>1) {
            NSString *empid=[NSString stringWithFormat:@"%d",helperObj.create_emp_id];
            empdic=[NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"helper_id",empid,@"emp_id", nil];
            [tempArray addObject:empdic];
            //            [db addHelperEmp:[NSArray arrayWithObject:empdic]];
        }
        [db addHelperEmp:tempArray];
        
        //修改 提醒
        UIApplication *app = [UIApplication sharedApplication];
        //获取本地推送数组
        NSArray *localArr = [app scheduledLocalNotifications];
        
        //声明本地通知对象
        UILocalNotification *localNoti=nil;
        
        if (localArr) {
            for (UILocalNotification *noti in localArr) {
                NSDictionary *dict = noti.userInfo;
                if (dict) {
                    NSString *inKey = [dict objectForKey:@"localNoticeId"];
                    if ([inKey isEqualToString:helperObj.helper_id]) {
                        if (localNoti){
                            [localNoti release];
                            localNoti = nil;
                        }
                        localNoti = [noti retain];
                        [app cancelLocalNotification:localNoti];
                        [localNoti release];
                        break;
                    }
                }
            }
            
        }
        
        
        // Set up the fire time
        NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
        fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        NSDate *startdate=[NSDate dateWithTimeIntervalSince1970:[helperObj.start_time intValue]];
        NSString *startstr= [fmt stringFromDate:startdate];
        if (helperObj.ring_type>0) {
            
            NSDate *tempdate=nil;
            
            if (helperObj.ring_type==1) {//正点
                tempdate=startdate;
            }else if(helperObj.ring_type==2) {//10分钟
                tempdate= [startdate dateByAddingTimeInterval:-10*60];
            }
            else if(helperObj.ring_type==3) {//30分钟
                tempdate= [startdate dateByAddingTimeInterval:-30*60];
            }
            else if(helperObj.ring_type==4) {//1小时
                tempdate= [startdate dateByAddingTimeInterval:-60*60];
            }
            else if(helperObj.ring_type==5) {//1天前
                tempdate= [startdate dateByAddingTimeInterval:-24*60*60];
            }
            
            NSString *starttime= [fmt stringFromDate:tempdate];
            [LogUtil debug:[NSString stringWithFormat:@"--localNotif-starttime  --  %@  startstr %@  ringtype %d",starttime,startstr,helperObj.ring_type]];
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif != nil)
            {
                localNotif.fireDate = tempdate;
                localNotif.timeZone = [NSTimeZone defaultTimeZone];
                
                // Notification details
                localNotif.alertBody = [NSString stringWithFormat:@"%@:%@ \n%@",[StringUtil getLocalizableString:@"schedule_show"],startstr,helperObj.helper_name];
                // Set the action button
                localNotif.alertAction = @"打开";
                
                localNotif.soundName = UILocalNotificationDefaultSoundName;
                //localNotif.applicationIconBadgeNumber = 1;
                
                // Specify custom data for the notification
                //NSDictionary *infoDict = [NSDictionary dictionaryWithObject:helperObj.helper_id forKey:@"localNoticeId"];
                NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:helperObj.helper_id,@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
                localNotif.userInfo = infoDict;
                
                // Schedule the notification
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                [localNotif release];
            }
            
        }
        
    }
    
    return state;
    // [LogUtil debug:[NSString stringWithFormat:@"---创建日程-state-- %d ",state]];
}
#pragma mark  日程助手  删除日程
-(int)deleteHelperSchedule:(NSString *)schedule_id GroupID:(NSString *)group_id CreateID:(int)create_id
{
    conn *_conn = [conn getConn];
    eCloudDAO* db = [eCloudDAO getDatabase];
    DELETESCHEDULE deleteObj;
    //	初始化
	memset(&deleteObj,0,sizeof(deleteObj));
    
    deleteObj.dwUserID=create_id;
    
    
    const char *c_helper_id = [schedule_id cStringUsingEncoding:NSUTF8StringEncoding];
	int c_helper_num = strlen(c_helper_id);
    
    const char *c_group_id = [group_id cStringUsingEncoding:NSUTF8StringEncoding];
	int c_group_num = strlen(c_group_id);
    
    memcpy(deleteObj.aszScheduleID,c_helper_id, c_helper_num);
    memcpy(deleteObj.aszGroupID, c_group_id, c_group_num);
    
    int state= CLIENT_DeleteSchedule([_conn getConnCB],&deleteObj);
    if (state==0) {
        [db deleteHelperScheduleMember:schedule_id];
        [db deleteHelperSchedule:schedule_id];
    }
    
    return state;
}
#pragma mark  日程助手  删除日程  通知处理
-(void)processDeleteHelperSchedule:(DELETESCHEDULE *)info
{
    conn *_conn = [conn getConn];
    eCloudDAO* db = [eCloudDAO getDatabase];
    NSString *schedule_id=[StringUtil getStringByCString:info->aszScheduleID];
    
    //修改 提醒
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArr = [app scheduledLocalNotifications];
    
    //声明本地通知对象
    UILocalNotification *localNoti=nil;
    
    if (localArr) {
        for (UILocalNotification *noti in localArr) {
            NSDictionary *dict = noti.userInfo;
            if (dict) {
                NSString *inKey = [dict objectForKey:@"localNoticeId"];
                if ([inKey isEqualToString:schedule_id]) {
                    if (localNoti){
                        [localNoti release];
                        localNoti = nil;
                    }
                    localNoti = [noti retain];
                    [app cancelLocalNotification:localNoti];
                    [localNoti release];
                    break;
                }
            }
        }
        
    }
    helperObject *hobject=[db getTheDateScheduleByID:schedule_id];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody  = [NSString stringWithFormat:@"标题为:%@ 的日程 已被删除",hobject.helper_name];
    
    // Set the action button
    localNotif.alertAction = @"打开";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    //localNotif.applicationIconBadgeNumber = 1;
    
    // Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:schedule_id,@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
    localNotif.userInfo = infoDict;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
    
    [db deleteHelperScheduleMember:schedule_id];
    [db deleteHelperSchedule:schedule_id];
    
}

#pragma mark  日程助手  新日程或修改日程 通知处理 
-(void)processGetHelperSchedule:(CREATESCHEDULENOTICE *)info
{
    
    [LogUtil debug:[NSString stringWithFormat:@"processGetHelperSchedule"]];
    conn *_conn = [conn getConn];
    eCloudDAO* db = [eCloudDAO getDatabase];
    NSString *nowTime =[_conn getSCurrentTime];
    [LogUtil debug:[NSString stringWithFormat:@"--info->aszScheduleDetail %s  info->aszScheduleName %s",info->aszScheduleDetail,info->aszScheduleName]];
    NSString *helper_id= [StringUtil getStringByCString:info->aszScheduleID];
    NSString *group_id=[StringUtil getStringByCString:info->aszGroupID];
    NSString *helper_title= [StringUtil getStringByCString:info->aszScheduleName];
    NSString *helper_detail= [StringUtil getStringByCString:info->aszScheduleDetail];
    NSString *helper_create_emp_id=[StringUtil getStringValue:info->dwUserID];
    NSString *create_time=nowTime;
    NSString *start_time=[StringUtil getStringValue:info->dwBeginTime];
    NSString *end_time=[StringUtil getStringValue:info->dwEndTime];
    NSString *warnning_type=[StringUtil getStringValue:info->cType];
    NSString *warnning_str=[StringUtil getLocalizableString:@"schedule_no_remind"];
    
    if (info->cOperType==2) {
        // NSString *name=[db getEmpNameByEmpId:helper_create_emp_id];
        NSString *title=[NSString stringWithFormat:@"标题为:%@ 的日程发生修改变动",helper_title];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [NSDate date];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        localNotif.alertBody  =title;
        
        // Set the action button
        localNotif.alertAction = @"打开";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        //localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"temp_id",@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [localNotif release];
        
    }else
    {   NSString *name=[db getEmpNameByEmpId:helper_create_emp_id];
        NSString *title=[NSString stringWithFormat:@"您收到来自%@的日程\n标题为:%@",name,helper_title];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [NSDate date];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        localNotif.alertBody  =title;
        
        // Set the action button
        localNotif.alertAction = @"打开";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        //localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"temp_id",@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [localNotif release];
    }
    if(info->cType==0)
    {
        warnning_str=[StringUtil getLocalizableString:@"schedule_no_remind"];
        
    }else if(info->cType==1)
    {  warnning_str=[StringUtil getLocalizableString:@"schedule_on_time"];
        
    }else if(info->cType==2)
    {  warnning_str=[StringUtil getLocalizableString:@"schedule_10_min"];
        
    }else if(info->cType==3)
    {  warnning_str=[StringUtil getLocalizableString:@"schedule_30_min"];
        
    }else if(info->cType==4)
    {  warnning_str=[StringUtil getLocalizableString:@"schedule_1_hour"];
        
    }else
    {
        warnning_str=[StringUtil getLocalizableString:@"schedule_1_day"];
    }
    
    NSDate *tempdate=[NSDate dateWithTimeIntervalSince1970:[start_time intValue]];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyyMMdd";
    NSString *startdate= [fmt stringFromDate:tempdate];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:helper_id,@"helper_id",group_id,@"group_id",helper_title,@"helper_title",helper_detail,@"helper_detail",helper_create_emp_id,@"helper_create_emp_id",create_time,@"create_time",start_time,@"start_time",end_time,@"end_time",startdate,@"start_date",warnning_type,@"warnning_type",warnning_str,@"warnning_str",@"2",@"is_read", nil];
    
    
    if ([_conn.userId isEqualToString:helper_create_emp_id]) {
        dic = [NSDictionary dictionaryWithObjectsAndKeys:helper_id,@"helper_id",group_id,@"group_id",helper_title,@"helper_title",helper_detail,@"helper_detail",helper_create_emp_id,@"helper_create_emp_id",create_time,@"create_time",start_time,@"start_time",end_time,@"end_time",startdate,@"start_date",warnning_type,@"warnning_type",warnning_str,@"warnning_str",@"0",@"is_read", nil];
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"helper_id- %@  helper_title- %@ helper_detail-%@ helper_create_emp_id- %@ start_time- %@ end_time-%@  warnning_type-%@ -startdate  %@",helper_id,helper_title,helper_detail,helper_create_emp_id,start_time,end_time,warnning_type,startdate]];
    [db addHelperSchedule:[NSArray arrayWithObject:dic]];
    [db deleteHelperScheduleMember:helper_id];//删除旧成员
    //---日程 参与人员
    NSDictionary *empdic;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<info->wUserNum; i++) {
        int emp_id=info->aUserID[i];
        NSString *empid=[NSString stringWithFormat:@"%d",emp_id];
        empdic=[NSDictionary dictionaryWithObjectsAndKeys:helper_id,@"helper_id",empid,@"emp_id", nil];
        [tempArray addObject:empdic];
        //        [db addHelperEmp:[NSArray arrayWithObject:empdic]];
    }
    [db addHelperEmp:tempArray];
    
    // Set up the fire time
    fmt.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate *locstartdate=[NSDate dateWithTimeIntervalSince1970:[start_time intValue]];
    NSString *locstartstr= [fmt stringFromDate:locstartdate];
    if (info->cType>0) {
        //修改 提醒
        UIApplication *app = [UIApplication sharedApplication];
        //获取本地推送数组
        NSArray *localArr = [app scheduledLocalNotifications];
        
        //声明本地通知对象
        UILocalNotification *localNoti=nil;
        
        if (localArr) {
            for (UILocalNotification *noti in localArr) {
                NSDictionary *dict = noti.userInfo;
                if (dict) {
                    NSString *inKey = [dict objectForKey:@"localNoticeId"];
                    if ([inKey isEqualToString:helper_id]) {
                        if (localNoti){
                            [localNoti release];
                            localNoti = nil;
                        }
                        localNoti = [noti retain];
                        [app cancelLocalNotification:localNoti];
                        [localNoti release];
                        break;
                    }
                }
            }
            
        }
        
        NSDate *tempdate=nil;
        
        if (info->cType==1) {//正点
            tempdate=locstartdate;
        }else if(info->cType==2) {//10分钟
            tempdate= [locstartdate dateByAddingTimeInterval:-10*60];
        }
        else if(info->cType==3) {//30分钟
            tempdate= [locstartdate dateByAddingTimeInterval:-30*60];
        }
        else if(info->cType==4) {//1小时
            tempdate= [locstartdate dateByAddingTimeInterval:-60*60];
        }
        else if(info->cType==5) {//1天前
            tempdate= [locstartdate dateByAddingTimeInterval:-24*60*60];
        }
        
        NSString *starttime= [fmt stringFromDate:tempdate];
        [LogUtil debug:[NSString stringWithFormat:@"--localNotif-starttime  --  %@  startstr %@  ringtype %d  helper_title-- %@  helper_detail -- %@",starttime,locstartstr,info->cType,helper_title,helper_detail]];
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = tempdate;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        localNotif.alertBody  = [NSString stringWithFormat:@"%@:%@ \n%@",[StringUtil getLocalizableString:@"schedule_show"],locstartstr,helper_title];
        
        // Set the action button
        localNotif.alertAction = @"打开";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        //localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:helper_id,@"localNoticeId",@"HelperSchedule",@"notificationType", nil];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [localNotif release];
        
    }
}


@end
