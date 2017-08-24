//
//  ConnResult.h
//  eCloud
//
//  Created by robert on 12-10-12.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "protocol.h"
@interface ConnResult : NSObject
{
    /** 错误代码 */
	int _resultCode;
    
    /** 错误结果 */
	NSString *_resultMsg;
}
/** 错误代码 */
@property (nonatomic,assign) int resultCode;

/** 错误代码 */
@property (nonatomic,retain) NSString *serverRetMsg;

/**
 功能描述
 获取返回错误的字符串

 返回值 错误结果
 */
-(NSString *)getResultMsg;
@end
