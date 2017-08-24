//
//  NSArray+Sort.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/3.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GSAArrayType) {
    GSAascendingArray = 0, //升序
    GSDescendingArray
};

@interface NSArray (Sort)

/**
 数组从大到小排序

 @return 排序后数组
 */
- (NSArray *)sortByArray;

/**
 排序
 
 @return 根据要求返回数组
 */
- (NSArray *)sortWithType:(GSAArrayType)type;

@end
