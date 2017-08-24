//
//  GOMEAppMsgModel.h
//  eCloud
//
//  Created by shisuping on 17/2/21.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOMEAppMsgModel : NSObject

//消息内容
@property (retain,nonatomic) NSString *msgContent;

//额外的消息内容
@property (retain,nonatomic) NSString *extendMsg;

@end
