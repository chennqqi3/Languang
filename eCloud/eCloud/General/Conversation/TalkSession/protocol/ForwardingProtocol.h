//
//  ForwardingProtocol.h
//  eCloud
//
//  Created by shisuping on 17/4/28.
//  Copyright © 2017年 网信. All rights reserved.
//

#ifndef ForwardingProtocol_h
#define ForwardingProtocol_h

/** 定义协议 转发完成后 提示已转发 */
@protocol ForwardingDelegate <NSObject>

- (void)showTransferTips;

@end


#endif /* ForwardingProtocol_h */
