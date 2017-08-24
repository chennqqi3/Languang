//
//  FileAssistantConn.m
//  eCloud
//
//  Created by Pain on 14-11-21.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "FileAssistantConn.h"
#import "JSONKit.h"
#import "UploadFileModel.h"
#import "StringUtil.h"
#import "ASIHTTPRequest.h"
#import "CRCUtil.h"
#import "eCloudUser.h"
#import "eCloudDefine.h"

#define fileServer  @"http://124.238.219.85:80//FilesService"

@implementation FileAssistantConn

+(NSDictionary*)getUploadFileToken:(UploadFileModel *)uploadFile{
    //请求token
    
//    NSURL *url = [NSURL URLWithString:@"http://124.238.219.85:80//FilesService/token/?userid=2&filemd5=c63e432bc70a4a028536f0f54ba6e367&filename=test.zip&filesize=16169826&type=2&rc=ac"];
    
//   http://124.238.219.85:80/FilesService/token/?filemd5=bbe936ff9c2a474fee8a650f0bdb94b0&filename=%E6%9C%AA%E5%91%BD%E5%90%8D%E6%96%87%E4%BB%B6%E5%A4%B9_112.zip&filesize=11285655&type=2&userid=164411&t=1422872819&guid=1422872819942&mdkey=5224ce8754d14b3b66f42d89e033b441
    
    NSString *filemd5 = uploadFile.filemd5;
    NSString *fileName = uploadFile.filename;
    int filesize = uploadFile.filesize;
    int type = uploadFile.type;
    
    NSString *urlStr  = [NSString stringWithFormat:@"%@token/?filemd5=%@&filename=%@&filesize=%i&type=%i%@",[[[eCloudUser getDatabase] getServerConfig] getFileUploadTokenUrl],filemd5,fileName,filesize,type,[StringUtil getResumeUploadAddStr]];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,获取token的URL:%@",__FUNCTION__,url]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:[StringUtil getRequestTimeout]];
    [urlRequest setHTTPMethod:@"GET"];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString *result = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSDictionary *dic = [result objectFromJSONString];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,获取到的token:%@",__FUNCTION__,result]];
    
    return dic;
}

#pragma mark - 文件是否有效
+ (int)getStatusCodeOfValidatingFileWithURLString:(NSString *)urlStr{
//    NSString *urlStr  = [NSString stringWithFormat:@"%@?token=%@&act=q&src=%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],@"0491da6570180be60c6c4d658fa79956d11111.zip",userid];
//    http://host:port/FilesService/download/?token=xxx&act=q&userid=userid&guid=guid&mdkey=dada&t=12121231231
    
//    NSString *qStr = [StringUtil getResumeDownloadAddStr];
//    NSString *urlStr  = [NSString stringWithFormat:@"%@?token=%@&act=q%@",[[[eCloudUser getDatabase] getServerConfig] getFileDownloadUrl],token,qStr];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:[StringUtil getRequestTimeout]];
    [urlRequest setHTTPMethod:@"GET"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
    
    int statusCode = [urlResponse statusCode];
    int errorCode = error.code;
    [LogUtil debug:[NSString stringWithFormat:@"%s 检查文件是否有效的url:%@ 检查结果:%d",__FUNCTION__,url,statusCode]];
    
    return statusCode;
}

/*
#pragma mark =================文件断点续传相关=========================
- (void)initASIQueue{
    ASIQueue = [[ASINetworkQueue alloc] init];
    [ASIQueue reset];
    [ASIQueue setMaxConcurrentOperationCount:10];
    [ASIQueue setShowAccurateProgress:YES];
    [ASIQueue go];
}

-(void)prepareUploadFileWithFileRecord:(ConvRecord*)_convRecord{
    //     NSURL *url = [NSURL URLWithString:@"http://124.238.219.85:80//FilesService/token/?userid=2&filemd5=c63e432bc70a4a028536f0f54ba6e367&filename=test.zip&filesize=16169826&type=2&rc=ac"];
    
    //准备上传
    NSString *upload_id = [NSString stringWithFormat:@"%i",_convRecord.msgId];
    UploadFileModel *fileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:upload_id];
    int uploadstate =  state_waiting;
    if (fileMode.upload_id) {
        NSDictionary *dic = [FileAssistantConn getUploadFileToken:fileMode];
        if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
            //获取token成功
            NSString *token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"token"]];
            int upload_start_index = [[dic objectForKey:@"uploadsize"] intValue];
            
            //更新数据库
            [[FileAssistantDOA getDatabase] updateUploadFileModelWithUploadid:upload_id withToken:token withStartIndex:upload_start_index];
            [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
        }
        else{
            uploadstate =  state_failure;
            [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
            [self setFileUploadFailured:_convRecord];
            return;
        }
    }
    else{
        NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
        NSString *md5Str=[StringUtil getFileMD5WithPath:filePath];
        
        NSString *userid = [NSString stringWithFormat:@"%i",_convRecord.emp_id];
        NSString *filemd5 = md5Str;
        NSString *filename = _convRecord.file_name;
        int filesize = [_convRecord.file_size intValue];
        int type = 2;
        int upload_start_index = 0;
        
        fileMode = [[UploadFileModel alloc] init];
        fileMode.userid = userid;
        fileMode.filemd5 = filemd5;
        fileMode.filename = filename;
        fileMode.filesize = filesize;
        fileMode.type = type;
        
        NSDictionary *dic = [FileAssistantConn getUploadFileToken:fileMode];
        [fileMode release];
        
 
         if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
         NSString *token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"token"]];
         int upload_start_index = [dic objectForKey:@"uploadsize"];
         
         往数据添加上传记录
         NSMutableDictionary *uploadEvent = [[NSMutableDictionary alloc] init];
         [uploadEvent setObject:upload_id forKey:@"upload_id"];
         [uploadEvent setObject:userid forKey:@"userid"];
         [uploadEvent setObject:filemd5 forKey:@"filemd5"];
         [uploadEvent setObject:filename forKey:@"filename"];
         [uploadEvent setObject:[NSNumber numberWithInt:filesize] forKey:@"filesize"];
         [uploadEvent setObject:[NSNumber numberWithInt:type] forKey:@"type"];
         [uploadEvent setObject:token forKey:@"token"];
         [uploadEvent setObject:[NSNumber numberWithInt:upload_start_index] forKey:@"upload_start_index"];
         [uploadEvent setObject:[NSNumber numberWithInt:uploadstate] forKey:@"upload_state"];
         
         NSLog(@"uploadEvent------------%@",uploadEvent);
         
         [[FileAssistantDOA getDatabase] addOneFileUploadRecord:uploadEvent];
         [uploadEvent release];
         }
         else{
         uploadstate =  state_failure;
         [[FileAssistantDOA getDatabase] updateUploadStateWithUploadid:upload_id withState:uploadstate];
         [self setFileUploadFailured:_convRecord];
         return;
         }
 
        NSString *token = @"04cac86948f79afaad5ad89f7f631b201f.ipa";
        
        //往数据添加上传记录
        NSMutableDictionary *uploadEvent = [[NSMutableDictionary alloc] init];
        [uploadEvent setObject:upload_id forKey:@"upload_id"];
        [uploadEvent setObject:userid forKey:@"userid"];
        [uploadEvent setObject:filemd5 forKey:@"filemd5"];
        [uploadEvent setObject:filename forKey:@"filename"];
        [uploadEvent setObject:[NSString stringWithFormat:@"%d",filesize] forKey:@"filesize"];
        [uploadEvent setObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
        [uploadEvent setObject:token forKey:@"token"];
        [uploadEvent setObject:[NSString stringWithFormat:@"%d",upload_start_index] forKey:@"upload_start_index"];
        [uploadEvent setObject:[NSString stringWithFormat:@"%d",uploadstate] forKey:@"upload_state"];
        
        NSLog(@"uploadEvent------------%@",uploadEvent);
        
        [[FileAssistantDOA getDatabase] addOneFileUploadRecord:uploadEvent];
        //        [uploadEvent release];
    }
    
    
    UploadFileModel *uploadFileMode = [[FileAssistantDOA getDatabase] getUploadFileWithUploadid:upload_id];
    [self uploadFileWithUploadFileModel:uploadFileMode];
}

-(void)uploadFileWithUploadFileModel:(UploadFileModel *)_fileMode{
    NSLog(@"satrt to  upload....");
    int uploadstate =  state_uploading;
    NSString *userid = _fileMode.userid;
    NSString *token = _fileMode.token;;
    NSString *rc = [CRCUtil getCrc8:[NSString stringWithFormat:@"%@%@",userid,token]];
    int start_upload_index = _fileMode.upload_start_index;
    
    NSString *filePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:_fileMode.filename];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    NSLog(@"原始文件长度%d",data.length);
    
    if (start_upload_index <= 0) {
        start_upload_index = 0;
    }else
    {
        data =[data subdataWithRange:NSMakeRange(start_upload_index, data.length-start_upload_index)];
    }
    
    NSString *data_len=[NSString stringWithFormat:@"%d",data.length];
    NSString *upload_start_index=[NSString stringWithFormat:@"%d",start_upload_index];
    
    NSString *urlStr  = [NSString stringWithFormat:@"http://127.0.0.1:9000/FilesService/upload/?userid=%@&token=%@&rc=%@",userid,token,rc];
    NSURL *dataurl = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *datarequest = [[ASIFormDataRequest alloc] initWithURL:dataurl];
    [datarequest setDelegate:self];
    [datarequest addRequestHeader:@"Content-Length" value:data_len];
    [datarequest addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
    [datarequest addRequestHeader:@"Content-Offset" value:upload_start_index];
    [datarequest setRequestMethod:@"POST"];
    
    NSDictionary *data_dic=[NSDictionary dictionaryWithObjectsAndKeys:userid,@"MSG_ID", nil];
    
    [datarequest setUserInfo:data_dic];
    [datarequest setPostBody:data];
    [datarequest setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [datarequest setNumberOfTimesToRetryOnTimeout:3];
    datarequest.shouldContinueWhenAppEntersBackground = YES;
    
    //发送文件，显示进度条
    int _index = [self getArrayIndexByMsgId:[_fileMode.upload_id intValue]];
    
    ConvRecord *_convRecord;
    if(_index < 0){
        _convRecord = [self  getConvRecordByMsgId:_fileMode.upload_id];
    }
    else{
        _convRecord =[self.convRecordArray objectAtIndex:_index];
    }
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
    [talkSessionUtil displayProgressView:_progressView];
    [datarequest setUploadProgressDelegate:_progressView];
    datarequest.showAccurateProgress = YES;
    [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    
    [datarequest setDidFinishSelector:@selector(uploadFileComplete:)];
    [datarequest setDidFailSelector:@selector(uploadFileFail:)];
    [datarequest startAsynchronous];
    [datarequest release];
}

- (void)setFileUploadFailured:(ConvRecord*)_convRecord{
    NSString *msgId= [NSString stringWithFormat:@"%d",_convRecord.msgId];
    int _index = [self getArrayIndexByMsgId:msgId.intValue];
    [self updateSendFlagByMsgId:msgId andSendFlag:send_upload_fail];
    _convRecord.send_flag = send_upload_fail;
    
    UITableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:[self getIndexPathByIndex:_index]];
    if (_convRecord.msg_type == type_file) {
        [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
    }
    UIActivityIndicatorView *spinner =  (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    [spinner stopAnimating];
    
    UIImageView *failBtn =(UIImageView *)[cell.contentView viewWithTag:status_failBtn_tag];
    failBtn.hidden=NO;
}


#pragma mark ========================================================
*/

@end
