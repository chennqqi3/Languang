//
//  NSMutableArray+EvaluationList.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/4.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (EvaluationList)
/**
 评价任务根据评价时间排序

 @return 排序后的数组
 */
- (NSMutableArray *)sortByTime;

@end
