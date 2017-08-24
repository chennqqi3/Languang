//
//  NSObject+ProcessData.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/29.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ProcessData)

+ (NSMutableArray *)ProcessDataForObtainedWithData:(id)data;
+ (NSMutableArray *)ProcessDataForObtainedDetailWithData:(id)data;
+ (NSMutableArray *)ProcessDataForMadeWithData:(id)data;//我得到的评价、我的评价任务共用
+ (NSMutableDictionary *)ProcessDataForEvaluationTaskStatusWithData:(id)data;//评价任务状态
+ (NSMutableArray *)ProcessDataForEvaluationTaskWithData:(id)data;//评价任务详情
+ (NSMutableDictionary *)ProcessDataForPunishmentWithData:(id)data;//奖罚
+ (NSMutableDictionary *)ProcessDataForAwardMainWithData:(id)data;//提奖当天/当月查询
+ (NSMutableArray *)ProcessDataForAwardSelectWithData:(id)data;//提奖按天/按月查询
+ (NSMutableDictionary *)ProcessDataForSpecailWithData:(id)data;//专项任务数列表
+ (NSMutableArray *)ProcessDataForSpecailDetailWithData:(id)data;//专项详情列表
+ (NSMutableArray *)ProcessDataForExamineWithData:(id)data;//考核用户首页
+ (NSMutableArray *)ProcessDataForExamineDetailWithData:(id)data;//考核用户首页详细
+ (NSMutableArray *)ProcessDataForEmolumentMainWithData:(id)data;//薪酬首页详情
+ (NSMutableArray *)ProcessDataForEmolumentSecretSetWithData:(id)data;//薪酬首页详情
+ (NSMutableArray *)ProcessDataForEmolumentDetailWithData:(id)data;//薪酬工资详情

@end
