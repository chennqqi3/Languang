//
//  VirtualGroupConn.h
//  eCloud
//
//  Created by yanlei on 15/12/3.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"

@interface VirtualGroupConn : NSObject
// 单例
+ (VirtualGroupConn *)getVirtualGroupConn;

// 发起同步虚拟组请求
- (BOOL)syncVirtalGroupInfo:(CONNCB *)_conncb;

// 解析同步虚拟组请求的应答
- (void)processVirtualGroupInfoAck:(VIRTUAL_GROUP_INFO_ACK*)info;

// 解析虚拟组通知内容
-(void)processVirtualGroupInfoNotice:(VIRTUAL_GROUP_INFO_NOTICE *)info;
@end
