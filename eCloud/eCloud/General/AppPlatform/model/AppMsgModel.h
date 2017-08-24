//
//  AppMsgModel.h
//  eCloud
//  应用消息模型
//  Created by shisuping on 17/2/21.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef _GOME_FLAG_
@class GOMEAppMsgModel;
#endif

@interface AppMsgModel : NSObject

@property (retain,nonatomic) NSString *msgID;

//标题
@property (retain,nonatomic) NSString *appMsgTitle;

//内容
@property (retain,nonatomic) NSString *appMsgContent;

//时间
@property (assign,nonatomic) int appMsgTime;

#ifdef _GOME_FLAG_
@property (retain,nonatomic) GOMEAppMsgModel *gomeAppMsgModel;
#endif

@end
