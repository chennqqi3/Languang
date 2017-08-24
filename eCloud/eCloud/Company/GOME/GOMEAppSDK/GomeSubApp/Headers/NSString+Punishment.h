//
//  NSString+Punishment.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/4.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Punishment)
/**
 返回需要格式的月份 当前月显示本月 本年非当前月显示X月 其余显示XXXX年XX月
 */
- (NSString *)getPunishmentMonth;

/**
 根据tag返回对应title

 @param tag tag
 @return title
 */
+ (NSString *)getNaviTitleByTag:(NSInteger)tag;

@end
