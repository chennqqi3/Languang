//
//  NSDate+Different.h
//  eCloud
//
//  Created by Dave William on 2017/8/14.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Different)

/**
 
 *  是否为今天
 
 */

- (BOOL)isToday;

/**
 
 *  是否为昨天
 
 */

- (BOOL)isYesterday;

/**
 
 *  是否为今年
 
 */

- (BOOL)isThisYear;


/**
 
 *  返回一个只有年月日的时间
 
 */

- (NSDate *)dateWithYMD;


/**
 
 *  获得与当前时间的差距
 
 */

- (NSDateComponents *)deltaWithNow;




@end
