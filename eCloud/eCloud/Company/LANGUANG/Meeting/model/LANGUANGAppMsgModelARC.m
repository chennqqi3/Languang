//
//  LANGUANGAppMsgModel.m
//  eCloud
//
//  Created by Ji on 17/6/9.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGAppMsgModelARC.h"

@implementation LANGUANGAppMsgModelARC

+ (instancetype)appMsgModelWithDic:(NSDictionary *)dic{
    
    LANGUANGAppMsgModelARC *appMsgModel = [[self alloc]init];
    
    [appMsgModel setValuesForKeysWithDictionary:dic];
    
    return appMsgModel;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    
    //判断是否为NSNumber类型
    if ([value isKindOfClass:[NSNumber class]]) {
        
        [self setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
        
    }else {
        
        //调用父类的方法
        [super setValue:value forKey:key];
        
    }
    
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    if ([key isEqualToString:@"confid"]) {
        
        [self setValue:value forKey:@"idNum"];
    }
    if ([key isEqualToString:@"type"]) {
        if ([value isEqualToString:@"backlog"]) {
            self.isDaiBanMsg = YES;
        }
    }
    
}

@end
