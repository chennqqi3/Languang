//
//  FileAssistantDOA.m
//  eCloud
//
//  Created by Pain on 14-11-20.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "FileAssistantDOA.h"
#import "FileAssistantSql.h"
#import "UploadFileModel.h"
#import "DownloadFileModel.h"

static FileAssistantDOA *fileAssistantDOA;

@implementation FileAssistantDOA


+(id)getDatabase
{
    if(fileAssistantDOA == nil)
    {
        fileAssistantDOA = [[FileAssistantDOA alloc]init];
    }
    return fileAssistantDOA;
}

#pragma mark - 添加一条文件上传纪录
-(void)addOneFileUploadRecord:(NSDictionary *)dic{
    NSArray *keys =   [NSArray arrayWithObjects:@"upload_id",@"userid",@"filemd5",@"filename",@"filesize",@"type",@"token",@"upload_start_index",@"upload_state",nil];
    NSString *sql =  nil;
    
    sql =   [self insertTable:table_file_upload newInfo:dic keys:keys];
    
    BOOL seccess = [self operateSql:sql Database:_handle toResult:nil];
    
}

#pragma mark - 根据id获取指定文件上传
-(UploadFileModel*)getUploadFileWithUploadid:(NSString *)uploadid{
    UploadFileModel *uploadFileModel = [[UploadFileModel alloc] init];
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_id = '%@'",table_file_upload,uploadid];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:_handle toResult:result];
        if(result.count == 1)
        {
            [self saveResult:[result objectAtIndex:0] toUploadFileModel:uploadFileModel];
        }
    }
    
    return [uploadFileModel autorelease];
}

-(void)saveResult:(NSDictionary*)dic toUploadFileModel:(UploadFileModel *)uploadFileModel
{
//    #define create_table_file_upload @"create table if not exists file_upload(upload_id TEXT PRIMARY KEY ,userid TEXT,filemd5 TEXT,filename TEXT,filepath TEXT,filesize INTEGER,type INTEGER,rc TEXT,token TEXT,upload_start_index TEXT,upload_state INTEGER)"
    
    uploadFileModel.upload_id = [dic valueForKey:@"upload_id"];
    uploadFileModel.userid = [dic valueForKey:@"userid"];
    uploadFileModel.filemd5 = [dic valueForKey:@"filemd5"];
    uploadFileModel.filename = [dic valueForKey:@"filename"];
    uploadFileModel.filesize = [[dic valueForKey:@"filesize"] intValue];
    uploadFileModel.type = [[dic valueForKey:@"type"] intValue];
    uploadFileModel.token = [dic valueForKey:@"token"];
    uploadFileModel.upload_start_index = [[dic valueForKey:@"upload_start_index"] intValue];
    uploadFileModel.upload_state = [[dic valueForKey:@"upload_state"] intValue];
}

#pragma mark - 更新上传token和上传起始位置
-(void)updateUploadFileModelWithUploadid:(NSString *)uploadid withToken:(NSString *)token withStartIndex:(NSInteger)start_index{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"update %@ set token = '%@',upload_start_index = '%d'  where upload_id = '%@'",table_file_upload,token,start_index,uploadid];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark - 更新上传状态
-(void)updateUploadStateWithUploadid:(NSString *)uploadid withState:(NSInteger)state{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"update %@ set upload_state = '%d' where upload_id = '%@'",table_file_upload,state,uploadid];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark - 删除某一条上传记录
-(void)deleteOneUpload:(NSString *)uploadid{
    @autoreleasepool {
        NSString *deletesql = [NSString stringWithFormat:@"delete from %@ where upload_id = '%@' ",table_file_upload,uploadid];
        [self operateSql:deletesql Database:_handle toResult:nil];
    }
}

#pragma mark - 添加一条下载记录
-(void)addOneFileDownloadRecord:(NSDictionary *)dic{
    NSArray *keys =   [NSArray arrayWithObjects:@"download_id",@"download_state",nil];
    NSString *sql =  nil;
    
    sql =   [self insertTable:table_file_download newInfo:dic keys:keys];
    BOOL seccess = [self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark - 根据id获取指定文件下载
- (DownloadFileModel *)getDownloadFileWithUploadid:(NSString *)downloadid{
    DownloadFileModel *downloadFileModel = [[DownloadFileModel alloc] init];
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where download_id = '%@'",table_file_download,downloadid];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:_handle toResult:result];
        if(result.count == 1)
        {
            [self saveResult:[result objectAtIndex:0] toDownloadFileModel:downloadFileModel];
        }
    }
    
    return [downloadFileModel autorelease];
}

- (void)saveResult:(NSDictionary*)dic toDownloadFileModel:(DownloadFileModel *)downloadFileModel{
    downloadFileModel.download_id = [dic valueForKey:@"download_id"];
    downloadFileModel.download_state = [[dic valueForKey:@"download_state"] intValue];
}

#pragma mark - 更新下载状态
-(void)updateDownloadStateWithDownloadid:(NSString *)downloadid withState:(NSInteger)state{
    @autoreleasepool {
        NSString *sql = [NSString stringWithFormat:@"update %@ set download_state = '%d' where download_id = '%@'",table_file_download,state,downloadid];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark - 删除某一条下载记录
-(void)deleteOneDownloadRecord:(NSString *)downloadid{
    @autoreleasepool {
        NSString *deletesql = [NSString stringWithFormat:@"delete from %@ where download_id = '%@' ",table_file_download,downloadid];
        [self operateSql:deletesql Database:_handle toResult:nil];
    }
}

@end
