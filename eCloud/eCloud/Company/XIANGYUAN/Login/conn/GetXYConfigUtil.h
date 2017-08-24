//
//  GetXYConfig.h
//  eCloud
//
//  Created by shisuping on 17/6/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetXYConfigUtil : NSObject

/** 获取token的URLConnection */

@property (nonatomic,retain) NSURLConnection *getOATokenConn;

/** 获取员工与部门关系配置的URLConnection */
@property (nonatomic,retain) NSURLConnection *getDeptShowConfigConn;

/** 获取单例 */
+ (GetXYConfigUtil *)getUtil;

/** 获取祥源oatoken */
- (void)getXYOAToken;

/** 获取祥源部门显示配置 */
- (void)getXYDeptShowConfig;




@end
