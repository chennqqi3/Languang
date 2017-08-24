//
//  DownloadZipAndUnzip.m
//  eCloud
//
//  Created by  lyong on 14-8-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "DownloadZipAndUnzip.h"
#import "ASIHTTPRequest.h"
#import "ZipArchive.h"
#import "client.h"
static DownloadZipAndUnzip *_downloadZipAndUnzip;
@implementation DownloadZipAndUnzip
//实例
+(id)getInitDownloadZipAndUnzip
{
	if(_downloadZipAndUnzip == nil)
	{
		_downloadZipAndUnzip = [[DownloadZipAndUnzip alloc]init];
	}
	return _downloadZipAndUnzip;
}
//释放
+(void)releaseDownloadZipAndUnzip
{
	if(_downloadZipAndUnzip)
	{
		[_downloadZipAndUnzip release];
		_downloadZipAndUnzip = nil;
	}
}
#pragma mark 下载zip
-(void)downloadZip:(NSString *)url_str
{

    ASIHTTPRequest *request;
    //设置下载的地址
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_str]];
    
    NSString *zip_file_path=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.zip"];
    //设置下载的文件的保持路径
    [request setDownloadDestinationPath:zip_file_path];
    [request setDelegate:self];
    
    [request setDidFailSelector:@selector(successsAction:)];
    [request setDidFinishSelector:@selector(failAction:)];
    [request startAsynchronous];
    //设置用于下载显示的进入的进度条
   // [request setDownloadProgressDelegate: imageProgressIndicator1];
   // [request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
    //添加这个下载
   

}
-(void)successsAction:(ASIHTTPRequest *)request
{

}

-(void)failAction:(ASIHTTPRequest *)request
{
    
}
#pragma mark 解压
- (NSString *) unZipClick {
    

      NSString* CoverfileFolderPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *zipFile = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.zip"];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    
    BOOL result;
    NSString *file_path=nil;
    if ([zip UnzipOpenFile:zipFile]) {
        NSString *filename=@"test";
        file_path = [CoverfileFolderPath stringByAppendingPathComponent:filename];
        NSLog(@"file_path--- %@",file_path);
        result = [zip UnzipFileTo:file_path overWrite:YES];
        if (!result) {
            NSLog(@"解压失败");
        }
        else
        {
            // readBtn.enabled = YES;
            NSLog(@"解压成功");
        }
        
        [zip UnzipCloseFile];
    }
    return file_path;
}
#pragma mark Aes解密
-(void)doAES_Action
{
 NSString* CoverfileFolderPath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test"];
 NSString *AesTotalFile=nil;
 AesTotalFile = [CoverfileFolderPath stringByAppendingPathComponent:@"AesTotalFile.txt"];
    
 NSString *TotalFile=nil;
 TotalFile = [CoverfileFolderPath stringByAppendingPathComponent:@"TotalFile.txt"];
// GetDesTotalFile((char*)[AesTotalFile cStringUsingEncoding:NSUTF8StringEncoding],(char*)[TotalFile cStringUsingEncoding:NSUTF8StringEncoding]);
    
}
@end
