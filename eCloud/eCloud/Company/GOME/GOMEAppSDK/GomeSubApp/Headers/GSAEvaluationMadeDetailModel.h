//
//  GSAEvaluationMadeDetailModel.h
//  GomeSubApplication
//
//  Created by 房潇 on 2017/1/6.
//  Copyright © 2017年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSAEvaluationMadeDetailModel : NSObject

@property (nonatomic, strong) NSArray  *bypingjiarens;
@property (nonatomic, strong) NSArray  *empImgs;
@property (nonatomic, strong) NSArray  *empNames;
@property (nonatomic, strong) NSArray  *empNumbers;
@property (nonatomic, strong) NSArray  *empPostNumbers;
@property (nonatomic, strong) NSArray  *evalContents;
@property (nonatomic, copy)   NSString  *evaluateID;

@end

@interface GSAEvaluationMadeDetailProcessModel : NSObject

/**
 被评价人分数
 */
@property (nonatomic, copy) NSString *byEvaluationScore;

/**
 被评价人头像
 */
@property (nonatomic, copy) NSString *byEvaluationAvatar;

/**
 被评价人姓名
 */
@property (nonatomic, copy) NSString *byEvaluationName;

/**
 被评价人工号
 */
@property (nonatomic, copy) NSString *byEvaluationJobNO;

/**
 被评价人职位
 */
@property (nonatomic, copy) NSString *byEvaluationPosition;

/**
 评价内容
 */
@property (nonatomic, copy) NSString *byEvaluationContent;


@end
