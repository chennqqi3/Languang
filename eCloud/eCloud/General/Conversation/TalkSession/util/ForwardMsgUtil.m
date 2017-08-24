//
//  ForwardMsgUtil.m
//  eCloud
//
//  Created by shisuping on 15/12/2.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "ForwardMsgUtil.h"
#import "conn.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "EncryptFileManege.h"
#import "talkSessionUtil.h"
#import "eCloudDAO.h"
#import "talkSessionViewController.h"

static ForwardMsgUtil *forwardMsgUtil;

@implementation ForwardMsgUtil

+ (ForwardMsgUtil *)getUtil
{
    if (!forwardMsgUtil) {
        forwardMsgUtil = [[ForwardMsgUtil alloc]init];
    }
    return forwardMsgUtil;
}


- (ConvRecord *)saveFromSingleForwardRecord:(ConvRecord *)forwardRecord
{
    talkSessionViewController *talksession = [talkSessionViewController getTalkSession];
    if (!talksession.convId) {
        talksession.convId = forwardRecord.conv_id;
        talksession.talkType = forwardRecord.conv_type;
        talksession.titleStr = forwardRecord.conv_title;
    }
    conn *_conn = [conn getConn];
    NSString *nowTime = [_conn getSCurrentTime];
    
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc]init];
    
    [mDic setValue:forwardRecord.conv_id forKey:@"conv_id"];
    
    [mDic setValue:_conn.userId forKey:@"emp_id"];
    
    [mDic setValue:[StringUtil getStringValue:forwardRecord.msg_type] forKey:@"msg_type"];
    
    [mDic setValue:nowTime forKey:@"msg_time"];
    
    [mDic setValue:@"0" forKey:@"read_flag"];
    
    [mDic setValue:[StringUtil getStringValue:send_msg] forKey:@"msg_flag"];
    
    if (forwardRecord.msg_type == type_text){
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:[StringUtil getStringValue:sending] forKey:@"send_flag"];
    }
    else if (forwardRecord.msg_type == type_file || forwardRecord.msg_type == type_video){
        [mDic setValue:[StringUtil getStringValue:send_upload_waiting] forKey:@"send_flag"];
    }
    else if (forwardRecord.msg_type == type_imgtxt){
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:[StringUtil getStringValue:sending] forKey:@"send_flag"];
    }
    else{
        [mDic setValue:[StringUtil getStringValue:send_uploading] forKey:@"send_flag"];
    }
    
    [mDic setValue:[StringUtil getStringValue:conv_status_normal] forKey:@"receipt_msg_flag"];
    
    if (forwardRecord.msg_type == type_pic){
        
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
        
        NSString *currenttimeStr= [NSString stringWithFormat:@"%.0lld",[StringUtil currentMillionSecond]];
        NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
        //存入本地
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
        
        NSData *data = [EncryptFileManege getDataWithPath:[talkSessionUtil getBigPicPath:forwardRecord]];
        BOOL success= [data writeToFile:picpath atomically:YES];
        if (!success)
        {
            //            复制文件失败
//            [pool release];
            return nil;
        }
        else
        {
            [mDic setValue:currenttimeStr forKey:@"msg_body"];
            [mDic setValue:pictempname forKey:@"file_name"];
            
            NSString *file_size = [NSString stringWithFormat:@"%i",[data length]];
            [mDic setValue:file_size forKey:@"file_size"];
        }
    }
    else if (forwardRecord.msg_type == type_long_msg)
    {
        NSString *currenttimeStr=[StringUtil currentTime];
        NSString *pictempname = [NSString stringWithFormat:@"%@.txt",currenttimeStr];
        //存入本地
        NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
        NSData *data = [EncryptFileManege getDataWithPath:[talkSessionUtil getLongMsgPath:forwardRecord]];
        BOOL success= [data writeToFile:picpath atomically:YES];
        if (!success)
        {
            return nil;
        }
        else
        {
            [mDic setValue:currenttimeStr forKey:@"msg_body"];
            
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *messageHead = [message substringToIndex:16];
            [mDic setValue:messageHead forKey:@"file_name"];
            
            NSString *file_size = [NSString stringWithFormat:@"%i",[data length]];
            [mDic setValue:file_size forKey:@"file_size"];
        }
    }
    else if (forwardRecord.msg_type == type_file || forwardRecord.msg_type == type_video)
    {
        [mDic setValue:forwardRecord.msg_body forKey:@"msg_body"];
        [mDic setValue:forwardRecord.file_name forKey:@"file_name"];
        [mDic setValue:forwardRecord.file_size forKey:@"file_size"];
    }
    
    NSDictionary *dic = [[eCloudDAO getDatabase] addConvRecord:[NSArray arrayWithObject:mDic]];
    if(!dic)
    {
        NSLog(@"保存失败");
        return nil;
    }
    
    NSString *msgId = [dic valueForKey:@"msg_id"];
    
    ConvRecord *_convRecord = [[eCloudDAO getDatabase] getConvRecordByMsgId:msgId];
    
    return _convRecord;
}

- (void)sendSingleForwardMsg:(ConvRecord *)forwardRecord
{
    conn *_conn = [conn getConn];
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    
    if ([talkSession.convId isEqualToString:forwardRecord.conv_id]) {
        [talkSession addOneRecord:forwardRecord andScrollToEnd:YES];
    }
    
    if (forwardRecord.msg_type == type_text || forwardRecord.msg_type == type_imgtxt)
    {
        [_conn sendMsg:forwardRecord.conv_id andConvType:forwardRecord.conv_type andMsgType:type_text andMsg:forwardRecord.msg_body andMsgId:forwardRecord.origin_msg_id andTime:forwardRecord.msg_time.intValue andReceiptMsgFlag:conv_status_normal];
    }
    else
    {
        if (forwardRecord.msg_type == type_file || forwardRecord.msg_type == type_video) {
            //            [self prepareUploadFileWithFileRecord:forwardRecord];
            [talkSession sendForwardFileMsg:forwardRecord];
        }
        else if (forwardRecord.msg_type == type_pic || forwardRecord.msg_type == type_record || forwardRecord.msg_type == type_long_msg){
                [talkSession prepareUploadFileWithFileRecord:forwardRecord];
        }
    }
}

- (void)saveAndSendForwardMsgArray:(NSArray *)records
{
    for (ConvRecord *_convRecord in records) {
        [self performSelector:@selector(saveAndSendSingleForwardMsg:) withObject:_convRecord afterDelay:0.05];
    }
}

- (void)saveAndSendSingleForwardMsg:(ConvRecord *)forwardRecord
{
    ConvRecord *newRecord = [self saveFromSingleForwardRecord:forwardRecord];
    if (newRecord) {
        [self sendSingleForwardMsg:newRecord];
    }
}
@end
