//
//  LGNewsMdelARC.m
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGNewsMdelARC.h"

@implementation LGNewsMdelARC

+ (instancetype)newsModelWithDic:(NSDictionary *)dic{
    
    LGNewsMdelARC *model = [[self alloc]init];
    
    [model setValuesForKeysWithDictionary:dic];
    
    return model;
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
    

}

@end
