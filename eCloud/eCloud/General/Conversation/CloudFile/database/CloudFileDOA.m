//
//  CloudFileDOA.m
//  eCloud
//
//  Created by Ji on 16/11/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "CloudFileDOA.h"
#import "CloudFileSql.h"

static CloudFileDOA *cloudFileDOA;

@implementation CloudFileDOA

+(id)getDatabase
{
    if(cloudFileDOA == nil)
    {
        cloudFileDOA = [[CloudFileDOA alloc]init];
    }
    return cloudFileDOA;
}

//创建云文件表
- (void)createTable
{
    [self operateSql:create_table_cloud_file Database:_handle toResult:nil];
    
}

-(void)addOneCloudFileUploadRecord:(NSDictionary *)dic{
    
    NSArray *keys =   [NSArray arrayWithObjects:@"file_token",@"file_id",nil];
    NSString *sql =  nil;
    
    sql =   [self insertTable:table_cloud_file newInfo:dic keys:keys];
    
    BOOL seccess = [self operateSql:sql Database:_handle toResult:nil];
    
}

#pragma mark - 云文件是否存在 如果存在就返回文件id 不存在返回NO
- (NSString *)isCloudFile:(NSString *)file
{
    NSString *sql = [NSString stringWithFormat:@"select file_id from %@ where file_token = '%@'",table_cloud_file,file];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        
        for (NSDictionary *dict in result) {
            
            NSString *file_id = dict[@"file_id"];
            return file_id;
            
        }
        
    }else{
        
        NSString *file_id = @"NO";
        return file_id;
    }
    return @"NO";
}
@end
