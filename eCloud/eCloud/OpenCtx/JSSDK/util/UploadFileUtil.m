//
//  UploadFileUtil.m
//  eCloud
//
//  Created by shisuping on 16/6/16.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "UploadFileUtil.h"

#import "JSONKit.h"
#import "UploadFileObject.h"

#import "ASIFormDataRequest.h"
#import "eCloudUser.h"
#import "FileAssistantConn.h"
#import "conn.h"
#import "LogUtil.h"
#import "UserDefaults.h"
#import <AVFoundation/AVFoundation.h>
#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "UploadFileModel.h"

@interface UploadFileUtil ()
//已经上传操作的文件
@property (nonatomic ,retain) NSMutableArray *uploadFinishArray;
//上传文件数组
@property (nonatomic,retain) NSMutableArray *uploadFileArray;

@end

@implementation UploadFileUtil

@synthesize delegate;
@synthesize uploadFileArray;
@synthesize uploadFinishArray;

- (void)dealloc
{
    self.uploadFileArray = nil;
    self.uploadFinishArray = nil;
    [super dealloc];
}

- (void)upload:(NSArray *)fileArray
{
    if (![conn getConn].userId) {
        [LogUtil debug:[NSString stringWithFormat: @"%s 用户未登录",__FUNCTION__]];
//        [UserTipsUtil showAlert:@"用户未登录"];
        return;
    }
    self.uploadFileArray = fileArray;
    self.uploadFinishArray = [NSMutableArray array];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil showLoadingView:@"上传中..."];
    });
    
    for (UploadFileObject *uploadFileObject in self.uploadFileArray) {
        [self uploadOneFile:uploadFileObject];
    }
}

- (void)uploadOneFile:(UploadFileObject *)uploadFileObject
{
    dispatch_queue_t queue = dispatch_queue_create("get token and upload ...", NULL);
    dispatch_async(queue, ^{
        
        NSString *filePath = uploadFileObject.uploadFilePath;
        
        NSString *userid = [conn getConn].userId;
        NSString *filemd5 = [StringUtil getFileMD5WithPath:filePath];
        
        NSData *data=[NSData dataWithContentsOfFile:filePath];
        int filesize = [data length];
        
        NSString *fileName = [filePath lastPathComponent];
        
        int upload_start_index = 0;
        
        UploadFileModel *fileMode = [[[UploadFileModel alloc] init]autorelease];
        fileMode.userid = userid;
        fileMode.filemd5 = filemd5;
        fileMode.filename = fileName;
        fileMode.filesize = filesize;
        fileMode.type = uploadFileObject.uploadFileType;
        
        NSDictionary *dic = [FileAssistantConn getUploadFileToken:fileMode];
        
        if ([[dic objectForKey:@"result"] isEqualToString:@"success"]) {
            
            NSString *token = [NSString stringWithFormat:@"%@",[dic objectForKey:@"token"]];
            upload_start_index = [[dic objectForKey:@"uploadsize"] intValue];
            
            if (upload_start_index == filesize) {
                
                uploadFileObject.uploadResponse = [dic JSONString];
                
                [self performSelectorOnMainThread:@selector(showUploadResult:) withObject:uploadFileObject waitUntilDone:YES];
            }else{
                
                NSData *data=[NSData dataWithContentsOfFile:filePath];
                int totaLength = data.length;
                
                NSLog(@"原始文件长度%d",totaLength);
                
                if (upload_start_index <= 0) {
                    upload_start_index = 0;
                }
                else{
                    data =[data subdataWithRange:NSMakeRange(upload_start_index,totaLength - upload_start_index)];
                }
                
                NSString *data_len=[NSString stringWithFormat:@"%d",data.length];
                
                NSLog(@"开始上传位置==== %d",upload_start_index);
                
                //    NSString *urlStr  = [NSString stringWithFormat:@"%@?userid=%@&token=%@&rc=%@",[[[eCloudUser getDatabase] getServerConfig] getFileUploadUrl],userid,token,rc];
                //    URL:http://host:port/FilesService/upload/?userid=2&token=01c63e432bc70a4a028536f0f54ba6e367.zip&t=1433232233&guid=12312312312312323&mdkey=1234567890abcdef1234567890abcdef
                
                NSString *urlStr  = [NSString stringWithFormat:@"%@?token=%@%@&type=%d",[[[eCloudUser getDatabase] getServerConfig] getFileUploadUrl],token,[StringUtil getResumeUploadAddStr],fileMode.type];
                
                NSURL *dataurl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                ASIFormDataRequest *datarequest = [[ASIFormDataRequest alloc] initWithURL:dataurl];
                [datarequest setDelegate:self];
                [datarequest addRequestHeader:@"Content-Length" value:data_len];
                [datarequest addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
                [datarequest addRequestHeader:@"Content-Offset" value:[NSString stringWithFormat:@"%d",upload_start_index]];
                [datarequest setRequestMethod:@"POST"];
                [datarequest setPostBody:data];
                [datarequest setTimeOutSeconds:[StringUtil getRequestTimeout]];
                [datarequest setNumberOfTimesToRetryOnTimeout:1];
                datarequest.shouldContinueWhenAppEntersBackground = YES;
                
                [datarequest setDidFinishSelector:@selector(uploadResumeFileComplete:)];
                [datarequest setDidFailSelector:@selector(uploadResumeFileFail:)];
                [datarequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:uploadFileObject,@"upload_file_object", nil]];
                [datarequest startAsynchronous];
                [datarequest release];
            }
        }else{
            [LogUtil debug:[NSString stringWithFormat: @"%s 获取token失败",__FUNCTION__]];

            [self performSelectorOnMainThread:@selector(showUploadResult:) withObject:uploadFileObject waitUntilDone:YES];
        }
    });
    dispatch_release(queue);
}


#pragma mark - 上传成功
-(void)uploadResumeFileComplete:(ASIHTTPRequest *)request{
    
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    //获取文件上传结果
    NSDictionary *userInfo = request.userInfo;
    UploadFileObject *uploadFileObject = userInfo[@"upload_file_object"];
    uploadFileObject.uploadResponse = response;
    
    [self performSelectorOnMainThread:@selector(showUploadResult:) withObject:uploadFileObject waitUntilDone:YES];
}

#pragma mark - 上传失败
-(void)uploadResumeFileFail:(ASIHTTPRequest *)request{
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];
    
    //获取文件上传结果
    NSDictionary *userInfo = request.userInfo;
    UploadFileObject *uploadFileObject = userInfo[@"upload_file_object"];
    uploadFileObject.uploadResponse = response;

    [self performSelectorOnMainThread:@selector(showUploadResult:) withObject:uploadFileObject waitUntilDone:YES];
}

#pragma mark 显示搜索结果
- (void)showUploadResult:(UploadFileObject *)uploadFileObject
{
    
    [self.uploadFinishArray addObject:uploadFileObject];
    
    if (self.uploadFinishArray.count == self.uploadFileArray.count) {
        [UserTipsUtil hideLoadingView];
        
        NSMutableString *mStr = [NSMutableString string];
        
        int _success = 0;
        for (UploadFileObject *uploadFileObject in uploadFinishArray) {
            NSString *fileToken = [uploadFileObject getFileToken];
            if (fileToken) {
                _success++;
                if (mStr.length) {
                    [mStr appendFormat:@",%@",fileToken];
                }else{
                    [mStr appendString:fileToken];
                }
            }
        }

//        [UserTipsUtil showAlert:[NSString stringWithFormat:@"上传%d个 成功%d个 token是%@ ",self.uploadFileArray.count,_success,mStr]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(uploadFinish:andResult:)]) {
            [self.delegate uploadFinish:self andResult:self.uploadFinishArray];
        }
    }
}
@end
