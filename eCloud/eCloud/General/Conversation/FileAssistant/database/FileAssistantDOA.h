//
//  FileAssistantDOA.h
//  eCloud
//
//  Created by Pain on 14-11-20.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "eCloud.h"

@class UploadFileModel;
@class DownloadFileModel;

@interface FileAssistantDOA : eCloud{
    
}
+(id)getDatabase;

-(void)addOneFileUploadRecord:(NSDictionary *)dic; //添加一条上传记录
-(UploadFileModel*)getUploadFileWithUploadid:(NSString *)uploadid; //根据id获取指定文件上传
-(void)updateUploadFileModelWithUploadid:(NSString *)uploadid withToken:(NSString *)token withStartIndex:(NSInteger)start_index; //更新上传token和上传起始位置
-(void)updateUploadStateWithUploadid:(NSString *)uploadid withState:(NSInteger)state; //更新上传状态
-(void)deleteOneUpload:(NSString *)uploadid; //删除某一条上传记录

-(void)addOneFileDownloadRecord:(NSDictionary *)dic; //添加一条下载记录
-(DownloadFileModel *)getDownloadFileWithUploadid:(NSString *)downloadid; //根据id获取指定文件下载
-(void)updateDownloadStateWithDownloadid:(NSString *)downloadid withState:(NSInteger)state; //更新下载状态
-(void)deleteOneDownloadRecord:(NSString *)downloadid; //删除某一条下载记录


@end
