//
//  LGMettingUtilARC.h
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGMettingUtilARC : NSObject

/** （蓝光）
 获取oa地址url
 
 @return oa地址url字符串
 */
+ (NSString *)getInterfaceUrl;

+ (NSString *)get9013Url;

+ (NSString *)get9012Url;

+ (NSString *)getTestUrl;
@end
