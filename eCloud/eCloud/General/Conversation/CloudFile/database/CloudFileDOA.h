//
//  CloudFileDOA.h
//  eCloud
//
//  Created by Ji on 16/11/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "eCloud.h"

@interface CloudFileDOA : eCloud

+(id)getDatabase;


//创建云文件表
- (void)createTable;

-(void)addOneCloudFileUploadRecord:(NSDictionary *)dic; //添加一条云文件上传记录

- (NSString *)isCloudFile:(NSString *)file;
@end
