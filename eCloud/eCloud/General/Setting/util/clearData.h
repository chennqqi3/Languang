//
//  clearData.h
//  eCloud
//
//  Created by SH on 14-8-5.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface clearData : NSObject


/**
 根据路径删除聊天数据

 @param pathArry 数据的路径
 */
-(void)clearData:(NSMutableArray *)pathArry;

@end
