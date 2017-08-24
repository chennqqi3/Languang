//
//  GSAEvaluationTaskModel.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/1.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conductanswerss : NSObject

@property (nonatomic, copy) NSString *conductid;
@property (nonatomic, copy) NSString *couductsimple;
@property (nonatomic, copy) NSString *createdate;
@property (nonatomic, copy) NSString *createtime;
@property (nonatomic, copy) NSString *descconduct;
@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *questionbankid;

@end

@interface QuestionBankLists : NSObject

@property (nonatomic, copy)   NSString  *makeQueid;
@property (nonatomic, copy)   NSString  *questionBankDescription;
@property (nonatomic, copy)   NSString  *questionBankId;
@property (nonatomic, copy)   NSString  *questionBankName;
@property (nonatomic, strong) NSArray  *conductanswerss;

@end

@interface AppBacks : NSObject

@property (nonatomic, copy) NSString  *byEvaluateContent;
@property (nonatomic, copy) NSString  *makequeId;
@property (nonatomic, copy) NSString  *questionBankId;

@end

@interface ByEmpLists : NSObject

/**
 被评价人头像
 */
@property (nonatomic, copy) NSString  *byEmpImage;

/**
 被评价人职位
 */
@property (nonatomic, copy) NSString  *byEmpJob;

/**
 被评价人姓名
 */
@property (nonatomic, copy) NSString  *byEmpName;

/**
 被评价人工号
 */
@property (nonatomic, copy) NSString  *byEmpNo;

/**
 是否熟悉此人
 */
@property (nonatomic, copy) NSString  *isFamiliar;

@property (nonatomic, copy) NSString  *evaluateText;
/**
此人所有题目的提分数组
 */
@property (nonatomic, copy) NSString  *score;

@property (nonatomic, assign) BOOL  edited;

@end

@interface GSAEvaluationTaskDetailModel : NSObject

/**
 评价的问题数量
 */
@property (nonatomic, strong) NSArray  *questionBankLists;

/**
 此条评价保存过，存放保存的数据
 */
@property (nonatomic, strong) NSArray  *appBacks;

/**
 被评价人
 */
@property (nonatomic, strong) NSArray  *byEmpLists;

@end

//最终使用的数据Model
@interface GSAEvaluationTaskProcessModel : NSObject

/**
 评价题目
 */
@property (nonatomic, strong) QuestionBankLists  *questions;

/**
 被评价人
 */
@property (nonatomic, strong) NSArray  *byEmpLists;

@end
