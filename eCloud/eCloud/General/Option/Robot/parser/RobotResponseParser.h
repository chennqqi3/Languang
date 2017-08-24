//
//  RobotResponseParser.h
//  eCloud
//  解析机器人回复 deprecated
//  Created by shisuping on 16/12/26.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotResponseParser : NSObject

+ (void)parse:(NSString *)message;

@end
