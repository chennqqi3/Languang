//
//  RobotFileUtil.m
//  eCloud
//
//  Created by shisuping on 16/12/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "RobotFileUtil.h"
#import "talkSessionUtil.h"
#import "DownloadFileModel.h"
#import "ApplicationManager.h"

#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#endif

#import "ASIHTTPRequest.h"

#import "ConvRecord.h"

#import "RobotResponseModel.h"

#import "LogUtil.h"

#import "RobotUtil.h"
#import "StringUtil.h"

#import "NotificationUtil.h"
#import "eCloudNotification.h"
#import "NotificationDefine.h"

#import "talkSessionViewController.h"

#define download_robot_file_tag (100)
#define download_robot_file_msg_id_tag (101)

@interface RobotFileUtil () <ASIHTTPRequestDelegate,UIAlertViewDelegate>

@end
static RobotFileUtil *robotFileUtil;

@implementation RobotFileUtil{
    
    NSMutableArray *downloadRecordList;
    NSMutableArray *upLoadRecordList;

}

+ (RobotFileUtil *)getUtil{
    if (!robotFileUtil) {
        robotFileUtil = [[super alloc]init];
    }
    return robotFileUtil;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        downloadRecordList = [[NSMutableArray alloc]init];
        upLoadRecordList = [[NSMutableArray alloc]init];
    }
    return self;
}


#pragma mark 如果在下载列表中，则获取下载的属性，并进行设置
-(void)setDownloadPropertyOfRecord:(ConvRecord*)_convRecord
{
    for(int i = downloadRecordList.count - 1; i >= 0; i--)
    {
        ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
        if(convRecord.msgId == _convRecord.msgId)
        {
            _convRecord.isDownLoading = convRecord.isDownLoading;
            _convRecord.download_flag = convRecord.download_flag;
            _convRecord.downloadRequest = convRecord.downloadRequest;
            
            NSLog(@"%s,",__FUNCTION__);
            break;
        }
    }
}

-(void)removeRecordFromDownloadList:(ConvRecord *)_convRecord
{
    for(int i = downloadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
        if(convRecord.msgId == _convRecord.msgId)
        {
            convRecord.downloadRequest.downloadProgressDelegate = nil;
            [convRecord.downloadRequest clearDelegatesAndCancel];
            convRecord.isDownLoading = NO;
            convRecord.downloadRequest = nil;
            [downloadRecordList removeObject:convRecord];
            //            NSLog(@"%s,",__FUNCTION__);
            break;
        }
    }
}


#pragma mark 如果不存在下载列表中，则增加
-(void)addRecordToDownloadList:(ConvRecord*)_convRecord
{
    if(![self isRecordInDownloadList:_convRecord])
    {
        [downloadRecordList addObject:_convRecord];
        //        NSLog(@"%s,",__FUNCTION__);
    }
}
#pragma mark 是否存在下载列表中
-(BOOL)isRecordInDownloadList:(ConvRecord*)_convRecord
{
    for(int i = downloadRecordList.count-1;i>=0;i--)
    {
        ConvRecord *convRecord = [downloadRecordList objectAtIndex:i];
        if(convRecord.msgId == _convRecord.msgId)
        {
            return YES;
        }
    }
    return NO;
}

//如果是gprs网络那么需要提示用户是否下载，用户同意后才下载

- (void)downloadRobotFile1:(ConvRecord *)_convRecord
{
    int netType = [ApplicationManager getManager].netType;
    if(netType != type_gprs && _convRecord.isRobotFileMsg)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:@"%@【%@】?", [StringUtil  getLocalizableString:@"confirm_to_download_file"],_convRecord.fileNameAndSize] delegate:self cancelButtonTitle:[StringUtil  getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil  getLocalizableString:@"confirm"], nil];
        alert.tag = download_robot_file_tag;
        UILabel *msgIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        msgIdLabel.text = [NSString stringWithFormat:@"%d",_convRecord.msgId];
        msgIdLabel.tag = download_robot_file_msg_id_tag;
        [alert addSubview:msgIdLabel];
        
        [msgIdLabel release];
        
        [alert show];
        [alert release];
    }else{
        [self downloadRobotFile2:_convRecord];
    }
}




//下载机器人的文件
- (void)downloadRobotFile2:(ConvRecord *)_convRecord
{
    NSString *urlString = nil;
    NSString *downloadFilePath = nil;
    if (_convRecord.isRobotImgTxtMsg) {
        NSDictionary *dic = _convRecord.robotModel.imgtxtArray[0];
        urlString = dic[@"PicUrl"];
        downloadFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    }else if (_convRecord.isRobotFileMsg){
        urlString = _convRecord.robotModel.msgFileDownloadUrl;
        downloadFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    }else if (_convRecord.isRobotPicMsg){
        urlString = _convRecord.robotModel.msgFileDownloadUrl;
        downloadFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    }
#ifdef _XINHUA_FLAG_
    else if (_convRecord.systemMsgModel){

        urlString = _convRecord.systemMsgModel.msgBody;
        downloadFilePath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
    }
#endif
    if (urlString.length && downloadFilePath.length) {
        
        dispatch_queue_t queue = dispatch_queue_create("download file ...", NULL);
        dispatch_async(queue, ^{
            
            NSURL *downloadUrl = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:downloadUrl];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s url is %@ downloadPath is %@",__FUNCTION__,urlString,downloadFilePath]];
            
            [request setDelegate:self];
            
            [request setDownloadDestinationPath:downloadFilePath];
            
//            NSString *fileName = [downloadFilePath lastPathComponent];
//            NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",fileName]];
            
            //设置文件缓存路径
//            [request setTemporaryFileDownloadPath:tempPath];
            
            [request setDidFinishSelector:@selector(downloadFileComplete:)];
            [request setDidFailSelector:@selector(downloadFileFail:)];
            [request setAllowResumeForFileDownloads:YES];
            
            //传参数，文件传输完成后，根据参数进行不同的处理
            [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:_convRecord,@"ConvRecord", nil]];
            
            [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
            [request setNumberOfTimesToRetryOnTimeout:3];
            request.shouldContinueWhenAppEntersBackground = YES;
            
            [request startAsynchronous];
            
            [request release];
            
            [self addRecordToDownloadList:_convRecord];
            _convRecord.isDownLoading = true;
            
            _convRecord.download_flag = state_downloading;
            
            _convRecord.downloadRequest = request;
            
            if (_convRecord.isRobotFileMsg || _convRecord.isRobotPicMsg) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:_convRecord.msgId];
                    if (_index >= 0) {
                        NSIndexPath *indexPath = [[talkSessionViewController getTalkSession]getIndexPathByIndex:_index];
                        
                        UITableViewCell *cell = [[talkSessionViewController getTalkSession].chatTableView cellForRowAtIndexPath:indexPath];

                        if (cell) {
                            
                            if (_convRecord.isRobotFileMsg) {
                                [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
                            }
                            
                            UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
                            failButton.hidden = YES;
                            
                            UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
                            [spinner startAnimating];
                        }
                    }
                });
                

            }
        });
        
        dispatch_release(queue);
    }
}


#pragma mark ==============
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == download_robot_file_tag && buttonIndex == 1) {
        UILabel *msgIdLabel = (UILabel*)[alertView viewWithTag:download_robot_file_msg_id_tag];
        int msgId = msgIdLabel.text.intValue;
        
        int _index = [[talkSessionViewController getTalkSession] getArrayIndexByMsgId:msgId];
        
        if(_index < 0) return;
        
        ConvRecord *_convRecord = [[talkSessionViewController getTalkSession].convRecordArray objectAtIndex:_index];
        
        [self downloadRobotFile2:_convRecord];
    }
}



#pragma mark -- 下载成功
- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    ConvRecord *_convRecord = [request.userInfo objectForKey:@"ConvRecord"];

    if (statuscode == 200) {
//        检测文件是否存在
        NSString *filePath = request.downloadDestinationPath;
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            //            下载成功
            [self removeRecordFromDownloadList:_convRecord];
            
//            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
            
            eCloudNotification *_notification = [[eCloudNotification alloc]init];
            _notification.cmdId = download_robot_file_complete;
            _notification.info = [NSDictionary dictionaryWithObject:_convRecord forKey:@"ConvRecord"];
            
            [[NotificationUtil getUtil]sendNotificationWithName:DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION andObject:_notification andUserInfo:nil];
        }else{
            [self downloadFileFail:request];
        }
        
    }else{
        [self downloadFileFail:request];
    }
}
#pragma mark -- 下载失败
-(void)downloadFileFail:(ASIHTTPRequest*)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    ConvRecord *_convRecord = [request.userInfo objectForKey:@"ConvRecord"];

    [self removeRecordFromDownloadList:_convRecord];

    eCloudNotification *_notification = [[eCloudNotification alloc]init];
    _notification.cmdId = download_robot_file_fail;
    _notification.info = [NSDictionary dictionaryWithObject:_convRecord forKey:@"ConvRecord"];
    
    [[NotificationUtil getUtil]sendNotificationWithName:DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION andObject:_notification andUserInfo:nil];
}
@end
