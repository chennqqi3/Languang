//  中英文配置 工具类
//  LanUtill.h
//  eCloud
//
//  Created by SH on 14-7-18.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LanUtil : NSObject
/** 获取中英文资源文件 */
+(NSBundle *) bundle;
/** 让应用的言语和系统语言一致 */
+(void) initUserLanguage;
/** 应用设置的语言 */
+(NSString *) userLanguage;
/** 设置应用内的语言 */
+(void) setUserlanguage:(NSString *)language;
/** 是不是中文 */
+(BOOL)isChinese;
@end
