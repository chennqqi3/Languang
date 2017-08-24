//
//  OANewsEntity.m
//  WanDaOAP3_IM
//
//  Created by SF on 16/4/13.
//  Copyright © 2016年 Wanda. All rights reserved.
//

#import "OANewsEntity.h"

@implementation OANewsEntity

// 处理字典中不需要通过KVC转换model中的属性
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    //    if ([key isEqualToString:@"msgtype"]) {
    //        return;
    //    }
    if ([key isEqualToString:@"description"]) {//如果你觉得后台的某个key不符合你的性格或者这个类的属性，你也可以自己搞
        self.newsdescription = value;
    }
}
@end
