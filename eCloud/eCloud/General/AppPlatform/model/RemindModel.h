//
//  RemindModel.h
//  eCloud
//  轻应用提醒 模型
//  Created by shisuping on 16/8/24.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindModel : NSObject

/** 提醒消息ID */
@property (nonatomic,retain) NSString *remindMsgId;

/** 提醒来自哪个系统的系统编码 */
@property (nonatomic,retain) NSString *fromSystem;

/** 提醒时间 */
@property (nonatomic,assign) int remindTime;

/** 提醒标题 */
@property (nonatomic,retain) NSString *remindTitle;

/** 提醒具体内容 */
@property (nonatomic,retain) NSString *remindDetail;

/** 提醒URL */
@property (nonatomic,retain) NSString *remindURL;

/** 提醒类型 */
@property (nonatomic,assign) int remindType;

@end
