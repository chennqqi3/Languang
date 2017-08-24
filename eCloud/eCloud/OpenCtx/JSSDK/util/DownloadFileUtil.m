//
//  DownloadFileUtil.m
//  eCloud
//
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "DownloadFileUtil.h"

#import "DownloadFileObject.h"

#import "UserTipsUtil.h"
#import "eCloudUser.h"
#import "ASIFormDataRequest.h"
#import "eCloudDefine.h"

@interface DownloadFileUtil ()

@property (nonatomic,retain) NSMutableArray *downloadFinishArray;
@property (nonatomic,retain) NSArray *downloadFileArray;

@end

@implementation DownloadFileUtil

@synthesize delegate;
@synthesize downloadFileArray;
@synthesize downloadFinishArray;

- (void)dealloc
{
    self.downloadFileArray = nil;
    self.downloadFinishArray = nil;
    [super dealloc];
}

- (void)downloadFile:(NSArray *)fileArray
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserTipsUtil showLoadingView:@"下载中..."];
    });

    self.downloadFinishArray = [NSMutableArray array];
    self.downloadFileArray = fileArray;
    
    for (DownloadFileObject *downloadFileObject in fileArray) {
        [self downloadOneFile:downloadFileObject];
    }
    
}

- (void)downloadOneFile:(DownloadFileObject *)downloadFileObject
{
    dispatch_queue_t queue = dispatch_queue_create("download file ...", NULL);
    dispatch_async(queue, ^{

        ASIHTTPRequest *request = [[self class]getRequestWith:downloadFileObject];

        //传参数，文件传输完成后，根据参数进行不同的处理
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:downloadFileObject,@"download_file_object", nil]];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(downloadFileComplete:)];
        [request setDidFailSelector:@selector(downloadFileFail:)];
        
        [request startAsynchronous];
        
    });
    
    dispatch_release(queue);
}

/** 根据一个对象 生成一个request */
+ (ASIHTTPRequest *)getRequestWith:(DownloadFileObject *)downloadFileObject{
    NSURL *downloadUrl = [NSURL URLWithString:[downloadFileObject.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:downloadUrl];
    
    // 添加请求头
    [request addRequestHeader:DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_NAME value:DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_VALUE];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@",__FUNCTION__,downloadUrl]];
    
    if (downloadFileObject.progressView) {
        [request setDownloadProgressDelegate:downloadFileObject.progressView];
    }
    [request setDownloadDestinationPath:downloadFileObject.downloadFilePath];
    
    NSString *fileName = [downloadFileObject.downloadFilePath lastPathComponent];
    NSString *tempPath = [[StringUtil newRcvFileTemPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",fileName]];
    
    //设置文件缓存路径
    [request setTemporaryFileDownloadPath:tempPath];
    
    [request setAllowResumeForFileDownloads:YES];
    
    [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [request setNumberOfTimesToRetryOnTimeout:3];
    request.shouldContinueWhenAppEntersBackground = YES;
    
    return [request autorelease];
}


#pragma mark --显示下载结果--
- (void)showDownloadResult:(DownloadFileObject *)downloadFileObject
{
    [self.downloadFinishArray addObject:downloadFileObject];
    if (self.downloadFileArray.count == self.downloadFinishArray.count) {
        [UserTipsUtil hideLoadingView];
        NSMutableString *mStr = [NSMutableString string];
        int _success = 0;
        for (DownloadFileObject *_downloadFileObject in self.downloadFinishArray) {
            if (_downloadFileObject.downloadResult == download_success) {
                _success++;
                if (mStr.length) {
                    [mStr appendFormat:@",%@",_downloadFileObject.downloadFilePath];
                }else{
                    [mStr appendString:_downloadFileObject.downloadFilePath];
                }
            }
        }
        [UserTipsUtil showAlert:[NSString stringWithFormat:@"下载%d个,成功%d个,保存路径为%@",self.downloadFileArray.count,_success,mStr]];
    }
}

#pragma mark -- 下载成功
- (void)downloadFileComplete:(ASIHTTPRequest *)request{
    
    int statuscode=[request responseStatusCode];
    NSString* response = [request responseString];
    [LogUtil debug:[NSString stringWithFormat:@"%s status code is %d response is %@",__FUNCTION__,statuscode,response]];

    DownloadFileObject *downloadFileObject = [request.userInfo objectForKey:@"download_file_object"];
    if (statuscode == 200) {
        //            下载成功
        downloadFileObject.downloadResult = download_success;
    }else{
        //下载失败
        downloadFileObject.downloadResult = download_fail;
    }
    
    [self performSelectorOnMainThread:@selector(showDownloadResult:) withObject:downloadFileObject waitUntilDone:YES];
    
}
#pragma mark -- 下载失败
-(void)downloadFileFail:(ASIHTTPRequest*)request{
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[request.error.userInfo valueForKey:NSLocalizedDescriptionKey]]];
    
    DownloadFileObject *downloadFileObject = [request.userInfo objectForKey:@"download_file_object"];
    downloadFileObject.downloadResult = download_fail;
    
    [self performSelectorOnMainThread:@selector(showDownloadResult:) withObject:downloadFileObject waitUntilDone:YES];
}
@end
