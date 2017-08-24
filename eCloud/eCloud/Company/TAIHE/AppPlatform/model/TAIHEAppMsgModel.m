//
//  TAIHEAppMsgModel.m
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEAppMsgModel.h"

@implementation TAIHEAppMsgModel

+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic{
    TAIHEAppMsgModel *appMsgModel = [[self alloc]init];
    
    [appMsgModel setValuesForKeysWithDictionary:dic];
    
    return appMsgModel;
}

// 处理字典中不需要通过KVC转换model中的属性
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
//    if ([key isEqualToString:@"msgtype"]) {
//        return;
//    }
}
@end
