//
//  WXReplyOneMsgUtil.m
//  eCloud
//
//  Created by shisuping on 17/5/8.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXReplyOneMsgUtil.h"
#import "ConvRecord.h"
#import "TextMsgExtDefine.h"
#import "LogUtil.h"
#import "RobotUtil.h"
#import "JSONKit.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"
#import "CloudFileModel.h"
#import "talkSessionViewController.h"
#import "talkSessionUtil.h"
#import "ReplyOneMsgModelArc.h"
#import "eCloudDAO.h"
#import "talkSessionUtil2.h"
#import "ChatHistoryView.h"

static WXReplyOneMsgUtil *replyOneMsgUtil;

@implementation WXReplyOneMsgUtil

+ (WXReplyOneMsgUtil *)getUtil{
    if (!replyOneMsgUtil) {
        replyOneMsgUtil = [[super alloc]init];
    }
    return replyOneMsgUtil;
}

/** 格式化定向回复消息 */
- (NSString *)formatReplyMsg:(NSString *)inputText
{
    if ([StringUtil trimString:inputText].length == 0) {
        return @"";
    }
    if (self.sendConvRecord) {
        NSDictionary *dic = @{KEY_MSG_TYPE:KEY_REPLY_MSG_TYPE,
                              KEY_REPLY_MSG_SENDER_ID:@(self.sendConvRecord.emp_id),
                              KEY_REPLY_MSG_MSG_ID:[NSString stringWithFormat:@"%llu",self.sendConvRecord.origin_msg_id],
                              KEY_REPLY_MSG_REPLY_MSG:[NSString stringWithFormat:@"@%@ %@",self.sendConvRecord.emp_name,inputText]};
        NSString *message = [dic JSONString];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 定向回复消息：%@",__FUNCTION__,message]];

        return message;
    }
    return inputText;
}

- (NSString *)getMsgBodyWithConvRecord:(ConvRecord *)convRecord
{
    NSString *msgBody = @"";
    
    int msgType = convRecord.msg_type;
    
    msgType =  [RobotUtil getIMMsgTypeOfRobotRecord:convRecord];
    
    switch (msgType) {
        case type_text:
        {
            msgBody =  convRecord.msg_body;
            
            if (convRecord.locationModel) {
                msgBody = [StringUtil getLocalizableString:@"msg_type_location"];
                break;
            }else if (convRecord.cloudFileModel){
                
                msgBody = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],convRecord.cloudFileModel.fileName];
                break;
            }
            else if (convRecord.replyOneMsgModel){
                
                msgBody = convRecord.msg_body;
                break;
            }
#ifdef _TAIHE_FLAG_
            else if(conv.last_record.appMsgModel){
                
                msgBody = conv.last_record.appMsgModel.title;
                
                break;
            }
#endif
        }
        case type_group_info:
            msgBody = convRecord.msg_body;
            break;
            //                update by shisp
        case type_file:
            msgBody = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"msg_type_file"],convRecord.file_name];
            break;
        case type_pic:
            msgBody = [StringUtil getLocalizableString:@"msg_type_pic"];
            break;
        case type_record:
            msgBody = [StringUtil getLocalizableString:@"msg_type_record"];
            break;
        case type_video:
            msgBody = [StringUtil getLocalizableString:@"msg_type_video"];
            break;
        case type_imgtxt:
            msgBody = [StringUtil getLocalizableString:@"msg_type_imgtxt"];
            break;
        case type_wiki:
            msgBody = [StringUtil getLocalizableString:@"msg_type_wiki"];
            break;
        case type_long_msg:
            msgBody = [StringUtil getLocalizableString:@"msg_type_long_msg"];
        default:
            break;
    }
    
    return msgBody;
}

//图文消息点击可以打开连接
- (void)addJumpToViewGesture:(UITableViewCell *)cell
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(JumpToReplayMsg:)];
    UIView *view = [cell viewWithTag:reply_one_msg_send_parent_view_tag];
    [view addGestureRecognizer:tap];
    [tap release];
}

//search界面专用
- (void)addSearchJumpToViewGesture:(UITableViewCell *)cell
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchJumpToReplayMsg:)];
    UIView *view = [cell viewWithTag:reply_one_msg_send_parent_view_tag];
    [view addGestureRecognizer:tap];
    [tap release];
}

- (void)searchJumpToReplayMsg:(UIGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:[ChatHistoryView getTalkSession].chatTableView];
    
    NSIndexPath *indexPath = [[ChatHistoryView getTalkSession].chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [[ChatHistoryView getTalkSession].convRecordArray objectAtIndex:[[ChatHistoryView getTalkSession] getIndexByIndexPath:indexPath]];
    
    
    NSArray * senderRecords= _convRecord.replyOneMsgModel.senderRecords;
    if (senderRecords.count > 0) {
        
        ChatHistoryView *talksession = [ChatHistoryView getTalkSession];
        
        ConvRecord *convRecord = senderRecords[0];
        int _index = [talksession getArrayIndexByMsgId:convRecord.msgId];
        
        if(_index < 0)
        {
            int count1 = [[eCloudDAO getDatabase] getMsgCountFromConvRecord:convRecord];
            int count2 = talksession.convRecordArray.count;
            int totalCount = [[eCloudDAO getDatabase] getConvRecordCountBy:convRecord.conv_id];
            NSArray *recordArr = [[eCloudDAO getDatabase] getConvRecordBy:convRecord.conv_id andLimit:count1-count2 andOffset:totalCount-count1];
            
            for (int i=recordArr.count-1; i>=0; i--)
            {
                //        ConvRecord *record =[recordList objectAtIndex:i];
                [talksession.convRecordArray insertObject:[recordArr objectAtIndex:i] atIndex:0];
            }
            for(int i = 0;i<recordArr.count;i++){
                id _convRecord = [recordArr objectAtIndex:i];
                if ([_convRecord isKindOfClass:[ConvRecord class]]) {
                    [talksession setTimeDisplay:_convRecord andIndex:i];
                    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                    [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
                    [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
                }
            }
            
            
            [talksession.chatTableView reloadData];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [talksession.chatTableView scrollToRowAtIndexPath:indexPath
                                             atScrollPosition: UITableViewScrollPositionMiddle
                                                     animated:NO];
            // 闪一下
            [self searchShining:indexPath];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到这条pinMsg ",__FUNCTION__]];
            
        }
        else
        {
            NSIndexPath *_indexPath = [talksession getIndexPathByIndex:_index];
            [talksession.chatTableView scrollToRowAtIndexPath:_indexPath
                                             atScrollPosition: UITableViewScrollPositionMiddle
                                                     animated:NO];
            // 闪一下
            [self searchShining:_indexPath];
            
            
            [LogUtil debug:[NSString stringWithFormat:@"%s  找到了对应的pinmsg  ，自动滑动到这条pinmsg",__FUNCTION__]];
        }
        
    }

    
}
- (void)JumpToReplayMsg:(UIGestureRecognizer *)sender
{
    CGPoint p = [sender locationInView:[talkSessionViewController getTalkSession].chatTableView];

    NSIndexPath *indexPath = [[talkSessionViewController getTalkSession].chatTableView indexPathForRowAtPoint:p];
    ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:[[talkSessionViewController getTalkSession] getIndexByIndexPath:indexPath]];
    
    
    NSArray * senderRecords= _convRecord.replyOneMsgModel.senderRecords;
    if (senderRecords.count > 0) {
        
         talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
        
        ConvRecord *convRecord = senderRecords[0];
        int _index = [talksession getArrayIndexByMsgId:convRecord.msgId];
        
        if(_index < 0)
        {
            int count1 = [[eCloudDAO getDatabase] getMsgCountFromConvRecord:convRecord];
            int count2 = talksession.convRecordArray.count;
            int totalCount = [[eCloudDAO getDatabase] getConvRecordCountBy:convRecord.conv_id];
            NSArray *recordArr = [[eCloudDAO getDatabase] getConvRecordBy:convRecord.conv_id andLimit:count1-count2 andOffset:totalCount-count1];
            
            for (int i=recordArr.count-1; i>=0; i--)
            {
                //        ConvRecord *record =[recordList objectAtIndex:i];
                [talksession.convRecordArray insertObject:[recordArr objectAtIndex:i] atIndex:0];
            }
            for(int i = 0;i<recordArr.count;i++){
                id _convRecord = [recordArr objectAtIndex:i];
                if ([_convRecord isKindOfClass:[ConvRecord class]]) {
                    [talksession setTimeDisplay:_convRecord andIndex:i];
                    [talkSessionUtil setPropertyOfConvRecord:_convRecord];
                    [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
                    [[talkSessionUtil2 getTalkSessionUtil] setUploadPropertyOfRecord:_convRecord];
                }
            }
            
            
            [talksession.chatTableView reloadData];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [talksession.chatTableView scrollToRowAtIndexPath:indexPath
                                             atScrollPosition: UITableViewScrollPositionMiddle
                                                     animated:NO];
            // 闪一下
            [self shining:indexPath];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到这条pinMsg ",__FUNCTION__]];
            
        }
        else
        {
            NSIndexPath *_indexPath = [talksession getIndexPathByIndex:_index];
            [talksession.chatTableView scrollToRowAtIndexPath:_indexPath
                                             atScrollPosition: UITableViewScrollPositionMiddle
                                                     animated:NO];
            // 闪一下
            [self shining:_indexPath];
            
            
            [LogUtil debug:[NSString stringWithFormat:@"%s  找到了对应的pinmsg  ，自动滑动到这条pinmsg",__FUNCTION__]];
        }
        
    }
    
}

- (void)shining:(NSIndexPath *)_indexPath
{
    talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
    UITableViewCell *cell = [talksession.chatTableView cellForRowAtIndexPath:_indexPath];
    UIView *view = cell;
    [UIView animateWithDuration:.25f animations:^{
        
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            
            view.backgroundColor = [UIColor clearColor];
        }];
    }];
}

- (void)searchShining:(NSIndexPath *)_indexPath
{
    ChatHistoryView *talksession = [ChatHistoryView getTalkSession];
    UITableViewCell *cell = [talksession.chatTableView cellForRowAtIndexPath:_indexPath];
    UIView *view = cell;
    [UIView animateWithDuration:.25f animations:^{
        
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            
            view.backgroundColor = [UIColor clearColor];
        }];
    }];
}

@end
