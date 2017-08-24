//
//  AudioTxtDAO.h
//  eCloud
//
//  Created by yanlei on 15/11/17.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eCloud.h"

@interface AudioTxtDAO : eCloud

+ (AudioTxtDAO *)getDatabase;

#pragma mark - 创建表
- (void)createTable;

#pragma mark - 表记录的基本操作
//  保存 记录
- (void)saveAudioTxtInfo:(NSDictionary *)info;
//  查询是否转换过的语音文本
- (BOOL)isExistAudioTxt:(NSString *)conv_id andMsgId:(NSInteger)msg_id;

// 从数据库中取出转换后的语音文本
- (NSString *)getMessage:(NSString *)conv_id andMsgId:(NSInteger)msg_id;

@end
