//add by shisp 定义和会话相关的一些通知，当修改和会话相关的一些数据库表时，发出这些通知，然后在会话列表界面接收这些通知，并进行处理

#define NEW_CONVERSATION_NOTIFICATION @"NEW_CONVERSATION_NOTIFICATION"

typedef enum
{
    //    修改新消息提醒 0
    update_rcv_msg_flag = 0,
    //    创建一个新的会话，暂时不用 1
    add_new_conversation,
    //    增加一条新的会话记录 2
    add_new_conv_record,
    //    获取完群组信息后，修改群组名称，创建人，创建时间等 3
    update_conversaion_info,
    //    删除所有会话 4
    delete_all_conversation,
    //    修改群组名称 5
    update_conv_title,
    //    删除某一个会话 6
    delete_conversation,
    //    删除某一条消息，如果删除的这条消息是最后一条记录，那么就要重新计算最后一条消息，如果已经没有消息，那么最后一条消息就是空 7
    delete_one_msg,
    //    保存草稿 8
    save_draft,
    //    保存草稿的时间 9
    save_last_msg_time,
    //    会话由关闭修改为打开状态，在会话列表显示，暂时不用 10
    display_conversation,
    //    复用群组，需要发出通知 11
    reuse_conversation,
    
    //    某一条消息设置为已读 12
    read_one_msg,
    
    //    设置某会话的所有消息为已读 13
    read_all_msg,
    
    //    修改消息的状态，是发送成功，还是发送中，还是发送失败 14
    update_send_flag,
    //    群组创建成功，修改last_msg_id为0 15
    update_last_msg_id_to_0,
    //    用户头像有变化 16
    user_logo_changed,
    
    //    
    update_isSet_top,
    
    //查看广播消息 更新未读计数
    update_broadcast_read_flag,
    
//    删除一条或者多条应用通知 会话列表界面 应用通知一级界面需要处理该通知 add by shisp
    remove_app_msg,
//    读一条或者多条应用的通知 会话列表界面 应用通知一级界面需要处理该通知 add by shisp
    read_app_msg,
    
    /** 其它用户读了发送出去的密聊消息 */
    other_user_read_encrypt_msg

    
}new_conversation_notification_cmd_type;
