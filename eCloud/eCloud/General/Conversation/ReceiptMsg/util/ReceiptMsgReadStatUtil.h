//
//  ReceiptMsgReadStatUtil.h
//  eCloud
//  查看回执消息 已读统计 界面 的 cell 显示程序
//  Created by Richard on 13-12-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define row_height (55)

@class Emp;

@interface ReceiptMsgReadStatUtil : NSObject

+(UITableViewCell*)cellWithReuseIdentifier:(NSString*)indentifier;
+(void)configCell:(UITableViewCell*)cell andEmp:(Emp*)emp andReadFlag:(BOOL)isRead;
@end
