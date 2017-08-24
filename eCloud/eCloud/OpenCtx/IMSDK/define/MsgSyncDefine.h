//
//  MsgSyncDefine.h
//  OpenCtx2017
//
//  Created by shisuping on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#ifndef MsgSyncDefine_h
#define MsgSyncDefine_h

typedef enum
{
    /** 只有pc离开或离线时收消息 */
    rcv_msg_when_pc_leave_or_offline = 0,
    /**  一直收消息 */
    rcv_msg_all_the_time
}rcv_msg_flag;


/**
 设置消息同步结果block定义
 
 @param resultCode 0：表示成功 其它：失败
 @param resultMsg 设置失败时的提示信息
 */
typedef void(^SetMsgSyncFlagResultBlock)(int resultCode,NSString *resultMsg);



#endif /* MsgSyncDefine_h */
