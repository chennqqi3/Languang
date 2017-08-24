//
//  LCLSqlite.h
//  syncClient4
//
//  Created by Richard(wangrichao) on 12-3-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "pthread.h"

//@class sqlite3;

@interface LCLSqlite : NSObject
{
    sqlite3     *_handle;
    BOOL        needCreateTable;
    
    BOOL        aleadyInit;
    
    pthread_mutex_t add_mutex;
    pthread_mutex_t add_mutex_userInfo;
}
/**********(private)****************/
- (NSString *)insertTable:(NSString *)table newInfo:(NSDictionary *)newDic keys:(NSArray *)keys;
- (NSString *)updateTable:(NSString *)table oldInfo:(NSDictionary *)oldDic newInfo:(NSDictionary *)newDic keys:(NSArray *)keys;
- (NSString *)replaceIntoTable:(NSString *)table newInfo:(NSDictionary *)newDic keys:(NSArray *)keys;
//判断是否是合法的本地路经格式
- (BOOL)isSqliteDatabasePath:(NSString *)path;
//创建指定路经的文件夹，创建成功或者文件夹存在则返回true
- (BOOL)createFolderForPath:(NSString *)path;
//打开指定路经的数据库,返回该路经的数据库实例
- (sqlite3 *)openSqliteDatabaseAtPath:(NSString *)path;
- (void)closeSqliteDatabase;
- (void)appendSql:(NSMutableString *)sql content:(NSString *)content;
- (BOOL)operateSql:(NSString *)sql Database:(sqlite3 *)handle toResult:(NSMutableArray *)result;
- (void)packageStatement:(sqlite3_stmt *)statement toArray:(NSMutableArray *)items;

-(sqlite3*)getDbHandle;
-(void)setDbHandle:(sqlite3*)handle;

/** 新的关闭数据库 方法 如果关闭成功 返回0 否则返回其它*/
- (int)newCloseDatabase;

@end
