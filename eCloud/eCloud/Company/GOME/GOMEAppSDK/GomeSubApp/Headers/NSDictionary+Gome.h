//
//  NSDictionary+Gome.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/13.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Gome)
/**
 将原始请求数据加密后作为最终请求字典的Value
 
 @param dic 原始请求参数
 @param key 最终请求字典Key
 @return 最终请求字典
 */
+ (NSDictionary *)getParamDicByParams:(NSDictionary *)dic WithModuleKey:(NSString *)key;

/**
 返回结果解密解压 返回格式为 {result:加密加压串儿}

 @param responseObject 返回的结果
 @return 解密解压的数据
 */
+ (id)getResultByResponseObject:(id)responseObject;

/**
 返回结果解密解压 返回格式为 全加密加压串儿

 @param responseObject 返回的结果 
 @return 解密解压的数据
 */
+ (id)getResultByResponseFullSecretObject:(id)responseObject;

@end
