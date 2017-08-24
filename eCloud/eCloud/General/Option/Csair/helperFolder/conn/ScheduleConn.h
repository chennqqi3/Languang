//
//  ScheduleConn.h
//  eCloud
//
//  Created by  lyong on 14-10-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"
@class eCloudDAO;
@class helperObject;
@interface ScheduleConn : NSObject
{
    eCloudDAO *db;
}
+ (ScheduleConn *)getScheduleConn;

#pragma mark  日程助手  创建
-(int)createHelperSchedule:(helperObject *)helperObj;

#pragma mark  日程助手  日程修改
-(int)modifyHelperSchedule:(helperObject *)helperObj;

#pragma mark  日程助手  删除日程
-(int)deleteHelperSchedule:(NSString *)schedule_id GroupID:(NSString *)group_id CreateID:(int)create_id;
#pragma mark  日程助手  删除日程  通知处理
-(void)processDeleteHelperSchedule:(DELETESCHEDULE *)info;
#pragma mark  日程助手  新日程或修改日程 通知处理
-(void)processGetHelperSchedule:(CREATESCHEDULENOTICE *)info;

@end

