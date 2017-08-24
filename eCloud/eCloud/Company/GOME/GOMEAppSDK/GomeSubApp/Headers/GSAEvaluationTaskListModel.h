//
//  GSAEvaluationTaskListModel.h
//  GomeSubApplication
//
//  Created by 房潇 on 2017/1/7.
//  Copyright © 2017年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSAEvaluationTaskListModel : NSObject

/**
 返回的评价名称 用以拆分时间和内容
 */
@property (nonatomic, copy) NSString  *evaluateName;

/**
 返回的评价时间
 */
@property (nonatomic, copy) NSString  *evalTime;

/**
 拆分后使用的发起评价时间
 */
@property (nonatomic, copy) NSString  *evaluationTime;

/**
 拆分后使用的发起评价内容
 */
@property (nonatomic, copy) NSString  *evaluationName;

/**
 //此条评价ID
 */
@property (nonatomic, copy) NSString    *evaluateId;

/**
 完成人数
 */
@property (nonatomic, copy) NSString    *doneEvalCount;

/**
 总人数
 */
@property (nonatomic, copy) NSString    *totalEvalCount;

/**
 不知道干啥的ID
 */
@property (nonatomic, copy) NSString    *makequeId;


@end
