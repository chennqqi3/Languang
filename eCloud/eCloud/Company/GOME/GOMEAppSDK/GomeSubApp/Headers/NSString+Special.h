//
//  NSString+Special.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/17.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSASpecialModel.h"

typedef NS_ENUM(NSInteger, GSASPecialStatus) {
    GSASPecialActiving = 0,               //任务未完成，未提报，未超期
    GSASPecialActivingOverDue,       //任务未完成，未提报，已超期
    GSASPecialApprovaling,               //任务未完成，审批中，未超期
    GSASPecialApprovalingOverDue, //任务未完成，审批中，已超期
    GSASPecialComplete,                  //任务在规定日期内完成
    GSASPecialFinish                         //任务超过规定日期完成
};

@interface NSString (Special)

/**
 服务器的数字状态返回所需要的任务状态
 
 @return 数字状态对应的文字状态
 */
- (NSString *)getStatusName;

+ (GSASPecialStatus)getSpeailStatusWithModel:(GSASpecialModel *)model;

@end
