//
//  OpenNotificationDefine.h
//  NewOpenCtxTest

//  以SDK方式集成到其它App中；IM发出通知，其它APP接收通知的相关定义

//  Created by shisuping on 16/7/25.
//  Copyright © 2016年 shisuping. All rights reserved.
//

#ifndef OpenNotificationDefine_h
#define OpenNotificationDefine_h

/*
 处理新提醒通知示例代码
 
 - (void)processNewRemind:(NSNotification *)_notification
 {
    NSDictionary *userInfo =  _notification.userInfo;
    if (userInfo) {
        RemindModel *newRemind = userInfo[NEW_REMIND_KEY];
 //        显示
        NSLog(@"%@",newRemind.remindMsgId);
 
        [[OpenCtxManager getManager]setRemindToReadWithMsgId:newRemind.remindMsgId];
    }
 }
 */

//收到新提醒通知
#define NEW_REMIND_NOTIFICATION @"new_remind_notification"

//新提醒
#define NEW_REMIND_KEY @"NEW_REMIND_KEY"

//从普通的单聊进入到密聊时，发出的通知
#define BACK_TO_CONTACTVIEW_TO_MILIAO @"BACK_TO_CONTACTVIEW_TO_MILIAO"

//从会话的选择联系人界面打开的会话界面 返回时发出的通知
#define BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE @"BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE"

//未读消息数通知 通知的object是一个NSNumber类型的对象，就是最新消息数
#define IM_UNREAD_NOTIFICATION @"IM_UNREAD_NOTIFICATION"

//用户被禁用的通知
#define USER_DISABLE_NOTIFICATION @"USER_DISABLE_NOTIFICATION"

//用户在其它端登录的通知
#define USER_NOTICE_OFFLINE @"USER_NOTICE_OFFLINE"

//获取当前用户头像完成后发出通知
#define GET_CURUSERICON_NOTIFICATION @"GET_CURUSERICON_NOTIFICATION"


#endif /* OpenNotificationDefine_h */
