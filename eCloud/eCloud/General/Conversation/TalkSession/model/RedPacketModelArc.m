//
//  RedPacketModelArc.m
//  eCloud
//
//  Created by Ji on 17/5/10.
//  Copyright © 2017年 网信. All rights reserved.
//


#import "RedPacketModelArc.h"

@implementation RedPacketModelArc

+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic{
    
    RedPacketModelArc *appMsgModel = [[self alloc]init];
    
    [appMsgModel setValuesForKeysWithDictionary:dic];
    
    return appMsgModel;
}

// 处理字典中不需要通过KVC转换model中的属性
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    if ([key isEqualToString:@"ID"]) {
        
        self.readPacketId = value;
    }
}

@end
