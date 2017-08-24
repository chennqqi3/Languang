//
//  WXOrgUtil.h
//  eCloud
//  和通讯录有关的util
//  Created by shisuping on 17/5/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXOrgDefine.h"

@class Emp;

@interface WXOrgUtil : NSObject

/** 把华夏的字典转为一个Emp对象 */
+ (Emp *)getEmpByHXEmpDic:(NSDictionary *)dic;


@end
