//
//  CollectionUtil.m
//  eCloud
//
//  Created by Alex L on 15/10/13.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "CollectionUtil.h"
#import "conn.h"
#import "StringUtil.h"

#import "talkSessionUtil.h"
#import "ConvRecord.h"
#import "LogUtil.h"

#define rcv_file_path @"receiveFile"
#define collect_file_path @"collectFile"

@implementation CollectionUtil

+ (NSString *)getTheFilePath:(NSString *)msg_body with:(NSString *)file_name
{
    ConvRecord *_convRecord = [[ConvRecord alloc]init];
    _convRecord.file_name = file_name;
    _convRecord.msg_body = msg_body;
    NSString *localFileName = [talkSessionUtil getFileName:_convRecord];
    
    NSString *filePath = [[self newCollectFilePath] stringByAppendingPathComponent:localFileName];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s file name is %@ filePath is %@",__FUNCTION__,localFileName,filePath]];
    
    return filePath;
}

+ (NSString *)getFileName:(NSString *)msg_body with:(NSString *)file_name
{
    NSString *fileName;
    
    NSString *msgBodyStr = msg_body;
    NSString *msgBody = @"";
    
    NSString *originFileName = file_name;
    
    //    如果是本地发送的文件，那么会在URL后面附加一个_,直接返回文件名称即可
    NSRange range = [msgBodyStr rangeOfString:@"_"];
    if(range.length > 0 ){
        //        NSLog(@"是本地发送的文件，直接返回文件名称即可");
        //        return originFileName;
        msgBody = [msgBodyStr substringToIndex:range.location];
    }
    else{
        msgBody = msgBodyStr;
    }
    NSRange _range = [originFileName rangeOfString:@"." options:NSBackwardsSearch];
    if(_range.length > 0)
    {
        NSString *file_Ext = [originFileName substringFromIndex:_range.location+1];
        NSString *file_name = [originFileName substringToIndex:_range.location];
        
        NSRange _bodyRange = [msgBody rangeOfString:@"." options:NSBackwardsSearch];
        if(_bodyRange.length > 0){
            fileName = [NSString stringWithFormat:@"%@_%@",file_name,msgBody];
        }
        else{
            fileName = [NSString stringWithFormat:@"%@_%@.%@",file_name,msgBody,file_Ext];
        }
    }
    else
    {
        fileName = [NSString stringWithFormat:@"%@_%@",originFileName,msgBody];
    }
    
    return fileName;
}

+ (NSString *)newRcvFilePath
{
    NSString *HomePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    
    conn *_conn = [conn getConn];
    NSString *appPath = [HomePath stringByAppendingPathComponent:_conn.userId];
    
    NSString *filePath = [appPath stringByAppendingPathComponent:rcv_file_path];
    
    return filePath;
}

+ (NSString *)newCollectFilePath
{
//    和普通消息 使用 同样的路径
    return [self newRcvFilePath];
    NSString *HomePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    
    conn *_conn = [conn getConn];
    NSString *appPath = [HomePath stringByAppendingPathComponent:_conn.userId];
    
    NSString *filePath = [appPath stringByAppendingPathComponent:collect_file_path];
    
    return filePath;
}

+ (void)deleteCollection:(NSDictionary *)dic
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //    if ([fileManager removeItemAtPath:delelteFilePath error:&error])
    {
        NSLog(@"已删除收藏文件");
    }
    //    else
    {
        NSLog(@"删除收藏文件失败: %@", [error localizedDescription]);
    }
}

@end
