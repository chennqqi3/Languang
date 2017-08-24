//
//  NSMutableArray+Recombination.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/3.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Recombination)
/**
 仅用作奖罚数据整理
 
 @return 按月份时间从近到远分组数据的字典
 */
- (NSMutableDictionary *)recombination;

@end
