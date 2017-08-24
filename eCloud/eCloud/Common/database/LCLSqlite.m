//
//  LCLSqlite.m
//  syncClient4
//
//  Created by Richard(wangrichao) on 12-3-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//;
#import "LCLSqlite.h"
#import "sqlite3.h"
#import "crypt.h"
#include <string.h>
#import "StringUtil.h"
#import "eCloudConfig.h"
#import "LogUtil.h"
#import "eCloudDAO.h"
#import "conn.h"
@implementation LCLSqlite

- (id)init
{
    self = [super init];
    if (self) 
    {
        _handle         =   nil;
        pthread_mutex_init(&add_mutex, NULL);
        pthread_mutex_init(&add_mutex_userInfo, NULL);
    }
    
    return self;
}

- (void)dealloc
{
    [self closeSqliteDatabase];
    pthread_mutex_destroy(&add_mutex);
    pthread_mutex_destroy(&add_mutex_userInfo);
    [super dealloc];
}

#pragma mark----------private-----------------
- (NSString *)insertTable:(NSString *)table newInfo:(NSDictionary *)newDic keys:(NSArray *)keys
{
    NSMutableString *sql        =   [NSMutableString string];
    [sql appendFormat:@"insert into %@(",table];
    for (int i = 0; i < (int)[keys count]; i++)
    {
        if(i != ((int)[keys count] - 1))
        {
            [sql appendFormat:@"%@,",[keys objectAtIndex:i]];
        }
        else
        {
            [sql appendFormat:@"%@) values(",[keys objectAtIndex:i]];
        }
    }
    NSString *luid  =   [newDic objectForKey:[keys objectAtIndex:0]];
	if(nil == luid)
	{
		[sql appendString:@"NULL"];
	}
    else
	{
		[sql appendFormat:@"'%@'",luid];
	}
    for (int i = 1; i < (int)[keys count]; i++)
    {
        NSString *key   =   [keys objectAtIndex:i];
        [self appendSql:sql content:[newDic objectForKey:key]];
    }
    [sql appendString:@")"];
    
    return sql;
}

- (NSString *)replaceIntoTable:(NSString *)table newInfo:(NSDictionary *)newDic keys:(NSArray *)keys
{
    NSMutableString *sql        =   [NSMutableString string];
    [sql appendFormat:@"Replace into %@(",table];
    for (int i = 0; i < (int)[keys count]; i++)
    {
        if(i != ((int)[keys count] - 1))
        {
            [sql appendFormat:@"%@,",[keys objectAtIndex:i]];
        }
        else
        {
            [sql appendFormat:@"%@) values(",[keys objectAtIndex:i]];
        }
    }
    NSString *luid  =   [newDic objectForKey:[keys objectAtIndex:0]];
	if(nil == luid)
	{
		[sql appendString:@"NULL"];
	}
    else
	{
		[sql appendFormat:@"'%@'",luid];
	}
    for (int i = 1; i < (int)[keys count]; i++)
    {
        NSString *key   =   [keys objectAtIndex:i];
        [self appendSql:sql content:[newDic objectForKey:key]];
    }
    [sql appendString:@")"];
    
    return sql;
}
- (NSString *)updateTable:(NSString *)table oldInfo:(NSDictionary *)oldDic newInfo:(NSDictionary *)newDic keys:(NSArray *)keys
{
    NSMutableString *sql        =   [NSMutableString string];
    BOOL    hasFieldNeedUpdate  =   NO;
    [sql appendFormat:@"UPDATE %@ SET ",table];
    for (int i = 1; i < (int)[keys count]; i++)
    {
        NSString *key       =   [keys objectAtIndex:i];
        NSString *newValue  =   [newDic objectForKey:key];
		
//		NSLog(@"oldvalue type is %@", [[oldDic objectForKey:key] class]);

		NSString *oldValue = @"";
		id oldValue_id = [oldDic objectForKey:key];
		if([oldValue_id isKindOfClass:[NSNumber class]])
		{
			oldValue = [((NSNumber *)oldValue_id) stringValue];
		}
		else
		{
			oldValue  =   [oldDic objectForKey:key];
		}
		

        BOOL    needUpdate  =   NO;
        //当字段内容为空或者内容不匹配时设置需要更新
        if(nil == oldValue
           || NSOrderedSame != [oldValue compare:newValue])
        {
            needUpdate  =   YES;
        }
        if(needUpdate && newValue)
        {
            hasFieldNeedUpdate  =   YES;
            [sql appendFormat:@"%@ = '%@',",key,newValue];
        } 
    }
    if(hasFieldNeedUpdate)
    {
        //删除多余的间隔','
        NSRange range   =   [sql rangeOfString:@"," options:NSBackwardsSearch];
        if(NSNotFound != range.location)
        {
            [sql deleteCharactersInRange:range];
        }
        
        NSString *luidKey  =   [keys objectAtIndex:0];
        [sql appendFormat:@" where %@ = '%@'",luidKey,[oldDic objectForKey:luidKey]];
    }
    else
    {
        sql =   nil;
    }
    return sql;
}

- (BOOL)isSqliteDatabasePath:(NSString *)path
{
    if(path && [path length] > 0)
    {
        NSRange range   =   [path rangeOfString:@".db" options:NSBackwardsSearch];
        if(NSNotFound == range.location)
        {
            range   =   [path rangeOfString:@".sqlite" options:NSBackwardsSearch];
            if(NSNotFound != range.location)
            {
                return YES;
            }
            return NO;
        }
        return YES;
    }
    return NO;
}
- (BOOL)createFolderForPath:(NSString *)path
{
    NSFileManager   *_file		=   [NSFileManager defaultManager];
    NSError         *errors 		=   nil;
    //如果不存在创建对应的文件夹
    if(NO == [_file fileExistsAtPath:path])
    {
        [_file createDirectoryAtPath:path
         withIntermediateDirectories:YES
                          attributes:nil
                               error:&errors];
        
        //如果创建发生了错误，则返回NO
        if(errors)
        {
            return NO;
        }
    }
    //创建成功或者指定路经的文件夹已经存在，则返回YES
    return YES;
}
/**sqlite数据库备份*///---------begin---////////
//void Help()
//{
//	_tprintf(
//             _T("xDb.exe is a decrypt SQLite3 database tool.\n")
//             _T("Usage: xDb.exe <encrypted.db> [decrypt.db] [psw]\n\n")
//             _T("  encrypted.db    Encrypted database name\n")
//             _T("  decrypt.db      Decrypted database name\n")
//             _T("  psw             Password to decrypt the database\n\n")
//             _T("Example:\n")
//             _T("  xDb.exe ecloud.db"));
//}


int bindParameterIndex(sqlite3_stmt* pVM, const char* szParam)
{
	int nParam = sqlite3_bind_parameter_index(pVM, szParam);
    
	int nn = sqlite3_bind_parameter_count(pVM);
	const char* sz1 = sqlite3_bind_parameter_name(pVM, 1);
	const char* sz2 = sqlite3_bind_parameter_name(pVM, 2);
    
	if (!nParam)
	{
		char buf[128];
		sprintf(buf, "Parameter '%s' is not valid for this statement", szParam);
	}
    
	return nParam;
}

int DumpTable(const char* pszTblName, const char* pszCreateTableSQL, sqlite3* pdbIn, sqlite3* pdbOut)
{
	int		nRet;
	int		i32Row;
	int		i32Col;
	char	pszBindField[100] = { 0 };
	char	szSQL[2000] = { 0 };
	char*	pszError = NULL;
	char**	paszResults=0;
	int		nRows = 0;
	int		nCols = 0;
	const char* pszTail=0;
	sqlite3_stmt* pVM;
    
	printf("Dump table: %s ...\n", pszTblName);
	nRet = sqlite3_exec(pdbOut, pszCreateTableSQL, 0, 0, &pszError);
	if (nRet != SQLITE_OK)
	{
		printf("exec [%s] failed, abort!\n",  pszCreateTableSQL);
		return nRet;
	}
	
	sqlite3_changes(pdbOut);
    
	sprintf(szSQL, "SELECT * FROM %s;", pszTblName);
	nRet = sqlite3_get_table(pdbIn, szSQL, &paszResults, &nRows, &nCols, &pszError);
	if (nRet != SQLITE_OK)
	{
		printf("exec [%s] failed, abort!\n",  pszCreateTableSQL);
		return nRet;
	}
	
	if(nRows == 0 || nCols == 0)
	{
		printf("Table [%s] is empty!\n", pszTblName);
		return 0;
	}
    
	sprintf(szSQL, "INSERT INTO %s(", pszTblName);
	// construct column name
	for(i32Col = 0; i32Col < nCols; i32Col++)
	{
		char* pszFieldValue = paszResults[ i32Col ];
		sprintf( &szSQL[strlen(szSQL)], "%s,", pszFieldValue );
	}
    
	// construct
	szSQL[strlen(szSQL) - 1] = '\0';	// remove '\,'
	strcat(szSQL, ") values (");
    
	// construct column value name
	for(i32Col = 0; i32Col < nCols; i32Col++)
	{
		char* pszFieldValue = paszResults[ i32Col ];
		sprintf( &szSQL[strlen(szSQL)], "@%s,", pszFieldValue );
	}
    
	// end
	szSQL[strlen(szSQL) - 1] = '\0';	// remove '\,'
	strcat(szSQL, ");");
    
	nRet = sqlite3_exec(pdbOut, "begin transaction;", 0, 0, &pszError);
	if( nRet != SQLITE_OK )
	{
		printf("begin transaction; failed!\n", szSQL);
		return nRet;
	}
    
	nRet = sqlite3_prepare_v2(pdbOut, szSQL, -1, &pVM, &pszTail);
	if( nRet != SQLITE_OK )
	{
		printf("exec DML [%s] is failed!\n", szSQL);
		return nRet;
	}
    
	for(i32Row = 0; i32Row < nRows; i32Row++)
	{
		for(i32Col = 0; i32Col < nCols; i32Col++)
		{
			char  szBindField[120] = { 0 };
			char* pszFieldValue = paszResults[ (i32Row * nCols) + nCols + i32Col ];
            
			sprintf( szBindField, "@%s", paszResults[ i32Col ] );
			nRet = sqlite3_bind_text(pVM, bindParameterIndex(pVM, szBindField), pszFieldValue, -1, SQLITE_TRANSIENT);
			if( nRet != SQLITE_OK )
			{
				printf("Bind [%d]=%s failed, abort!\n", nCols, pszFieldValue);
				return nRet;
			}
		}
        
		if ( SQLITE_DONE == sqlite3_step(pVM) )
		{
			int nRowsChanged = sqlite3_changes( pdbOut );
			nRet = sqlite3_reset(pVM);
		}
	}
	sqlite3_finalize(pVM);
	sqlite3_free_table( paszResults );
	return sqlite3_exec(pdbOut, "commit transaction;", 0, 0, &pszError);
}

int QueryDbStatus(const char* pszDbFile)
{
	FILE* pfDb = fopen(pszDbFile, "rb");
	if( pfDb )
	{
		char szMark[] = "SQLite format 3";
		char szReadMark[20] = { '\0' };
        
		size_t ret = fread( szReadMark, 1, sizeof(szMark), pfDb );
		fclose( pfDb );
        
		if( !memcmp( szMark, szReadMark, sizeof(szMark)) )
			return -1;	// Not encrypted, and have data, need dump data
        
		return 1;	// Empty data base or encryped database, open it with key only
	}
	
	if(errno == ENOENT)
		return 1;
    
	return 0;	// Access deny, open it only
}
//
//int QueryDbStatus(sqlite3* pDb)
//{
//	char	szQueryMaster[]={ "SELECT name FROM sqlite_master" };
//	char*	szError=0;
//	char**	paszResults=0;
//	int		nRet = 0;
//	int		nRows = 0;
//	int		nCols = 0;
//    
//	nRet = sqlite3_get_table(pDb, szQueryMaster, &paszResults, &nRows, &nCols, &szError);
//	if (nRet == SQLITE_OK)
//	{
//		sqlite3_free_table( paszResults );
//		if( nRows > 0 )
//			return 1;	// Already have data
//        
//		return 0;		// Can access
//	}
//    
//	return -1;			// Access deny, need password
//}

int OpenDb(sqlite3** ppDb, char* pszPath)
{
	int iRet = 0;
//	char szPsw[] = "abcdefgh";		// Test Psw
    char szPsw[] = "1234";
	sqlite3_open(pszPath, ppDb);
	iRet = QueryDbStatus(pszPath);
    
    if (iRet==0) {
      	return sqlite3_open( pszPath, ppDb );
    }
    else if( iRet == 1 )
    {
    	sqlite3_close( *ppDb );
		sqlite3_open( pszPath, ppDb );	// Need reopen
		return sqlite3_key( *ppDb, szPsw, strlen(szPsw) );
    }else
    {
    	// Dump
		char szDbBkup[260];
//        把不加密的库固定一个名字保存下来
		sprintf(szDbBkup, "%s_decrypt.db", pszPath);
//		sprintf(szDbBkup, "%s_%d.db", pszPath, time(NULL));
		sqlite3_close( *ppDb );
		if( 0 == rename(pszPath, szDbBkup) )
		{
			sqlite3* pDbBkup = NULL;
			char	szQuery1[]={ "select tbl_name, sql from sqlite_master where type='table';" };
			char	szQuery2[] = "select tbl_name, sql from sqlite_master where type='index' and name not like 'sqlite_%';";
			char*	pszError=0;
			char**	paszResults=0;
			int		nRet = 0;
			int		nRows = 0;
			int		nCols = 0;
            
			sqlite3_open( pszPath, ppDb );		// Open the new empty db
			sqlite3_open( szDbBkup, &pDbBkup );
			sqlite3_key( *ppDb, szPsw, strlen(szPsw) );
            
			// dump table data
			nRet = sqlite3_get_table(pDbBkup, szQuery1, &paszResults, &nRows, &nCols, &pszError);
			if (nRet == SQLITE_OK)
			{
				for(int i32Row = 0; i32Row < nRows; i32Row++)
				{
					char* pszField0 = paszResults[ (i32Row * nCols) + nCols + 0 ];
					char* pszField1 = paszResults[ (i32Row * nCols) + nCols + 1 ];
                    
//                    NSLog(@"%s,%@,%@",__FUNCTION__,[StringUtil getStringByCString:pszField0],[StringUtil getStringByCString:pszField1]);

					DumpTable(pszField0, pszField1, pDbBkup, *ppDb);
				}
			}
            
            sqlite3_free_table( paszResults );
			// dump index
			nRet = sqlite3_get_table(pDbBkup, szQuery2, &paszResults, &nRows, &nCols, &pszError);
			if (nRet == SQLITE_OK)
			{
				for(int i32Row = 0; i32Row < nRows; i32Row++)
				{
					char* pszField1 = paszResults[ (i32Row * nCols) + 1 ];
					nRet = sqlite3_exec(*ppDb, pszField1, 0, 0, &pszError);// Create user defined index;
				}
			}
            
			sqlite3_free_table( paszResults );
			sqlite3_close( pDbBkup );
//			即使导入数据成功，也不删除备份的数据库
//            remove(szDbBkup);
			return SQLITE_OK;
		}
		else
		{	// rename failed, database file is locked, do not dump this time
			return sqlite3_open( pszPath, ppDb );
		}

    
    }
    
//	if( iRet < 0 )
//	{	// Access deny, need password
//		sqlite3_close( *ppDb );
//		sqlite3_open( pszPath, ppDb );	// Need reopen
//		return sqlite3_key( *ppDb, szPsw, strlen(szPsw) );
//	}
//	else
//	{	// Dump
//		char szDbBkup[260];
//        
//		sprintf(szDbBkup, "%s_%d.db", pszPath, time(NULL));
//		sqlite3_close( *ppDb );
//		if( 0 == rename(pszPath, szDbBkup) )
//		{
//			sqlite3* pDbBkup = NULL;
//			char	szQuery1[]={ "select tbl_name, sql from sqlite_master where type='table';" };
//			char	szQuery2[] = "select tbl_name, sql from sqlite_master where type='index' and name not like 'sqlite_%';";
//			char*	pszError=0;
//			char**	paszResults=0;
//			int		nRet = 0;
//			int		nRows = 0;
//			int		nCols = 0;
//            
//			sqlite3_open( pszPath, ppDb );		// Open the new empty db
//			sqlite3_open( szDbBkup, &pDbBkup );
//			sqlite3_key( *ppDb, szPsw, strlen(szPsw) );
//            
//			// dump table data
//			nRet = sqlite3_get_table(pDbBkup, szQuery1, &paszResults, &nRows, &nCols, &pszError);
//			if (nRet == SQLITE_OK)
//			{
//				for(int i32Row = 0; i32Row < nRows; i32Row++)
//				{
//					char* pszField0 = paszResults[ (i32Row * nCols) + nCols + 0 ];
//					char* pszField1 = paszResults[ (i32Row * nCols) + nCols + 1 ];
//                    
//					DumpTable(pszField0, pszField1, pDbBkup, *ppDb);
//				}
//			}
//            
//            sqlite3_free_table( paszResults );
//			// dump index
//			nRet = sqlite3_get_table(pDbBkup, szQuery2, &paszResults, &nRows, &nCols, &pszError);
//			if (nRet == SQLITE_OK)
//			{
//				for(int i32Row = 0; i32Row < nRows; i32Row++)
//				{
//					char* pszField1 = paszResults[ (i32Row * nCols) + 1 ];
//					nRet = sqlite3_exec(*ppDb, pszField1, 0, 0, &pszError);// Create user defined index;
//				}
//			}
//            
//			sqlite3_free_table( paszResults );
//			sqlite3_close( pDbBkup );
//            remove(szDbBkup);
//			return SQLITE_OK;
//		}
//		else
//		{	// rename failed, database file is locked, do not dump this time
//			return sqlite3_open( pszPath, ppDb );	
//		}
//	}
}
///**sqlite数据库备份*/-----end----------//////////////////


- (sqlite3 *)openSqliteDatabaseAtPath:(NSString *)path
{
    sqlite3 *handle =   nil;
    if([self isSqliteDatabasePath:path])
    {
      
        //如果相应路经的数据库文件不存在，则需要在创建数据库的同时，创建相应的数据表
        NSFileManager   *file   =   [[NSFileManager alloc]init];
        needCreateTable         =   ![file fileExistsAtPath:path];
        [file release];
        //打开数据库，如果指定的路经的数据库不存在，会自动创建
        pthread_mutex_lock(&add_mutex);
        
        int value = SQLITE_ABORT;
        if ([eCloudConfig getConfig].needEncryptDB) {
            value  = OpenDb(&handle, [path UTF8String]);
        }
        else
        {
            value =sqlite3_open([path UTF8String], &handle);
        }

        pthread_mutex_unlock(&add_mutex);
		
		
        //打开数据库成功，且如果需要创建数据表
        if(SQLITE_OK != value)
        {
            pthread_mutex_lock(&add_mutex);
            sqlite3_close(handle);
            handle  =   nil;
			pthread_mutex_unlock(&add_mutex);
        }
        
    }
    return handle;
}


- (void)closeSqliteDatabase
{
    if(_handle)
    {
		pthread_mutex_lock(&add_mutex);
        int result = sqlite3_close_v2(_handle);
        if (result != SQLITE_OK)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s error code is %d",__FUNCTION__,result]];
        }
		pthread_mutex_unlock(&add_mutex);
        aleadyInit  =   NO;
    }
    _handle     =   nil;
}



- (void)appendSql:(NSMutableString *)sql content:(NSString *)content
{
    if(content)
    {
        [sql appendFormat:@",'%@'",content];
    }
    else
    {
        [sql appendString:@",NULL"];
    }
}



//result不为nil时表示该操作为查询
- (BOOL)operateSql:(NSString *)sql Database:(sqlite3 *)handle toResult:(NSMutableArray *)result
{
    @try {
        //    NSLog(@"sql:%@---",sql);
        if(nil == handle || nil == sql)
        {
            return NO;
        }
        
        sqlite3_stmt    *statement	=   nil;
        pthread_mutex_lock(&add_mutex);
        int state  =   sqlite3_prepare(handle,
                                       [sql UTF8String],
                                       -1,
                                       &statement,
                                       nil);
        pthread_mutex_unlock(&add_mutex);
        if(SQLITE_OK != state)
        {
            if (state != 1) {
                NSLog(@"prepare is error!!--:%d",state);                
            }
            pthread_mutex_lock(&add_mutex);
            sqlite3_finalize(statement);
            pthread_mutex_unlock(&add_mutex);
            return NO;
        }
        if(result)
        {
//            pthread_mutex_lock(&add_mutex);
            [self packageStatement:statement toArray:result];
//            pthread_mutex_unlock(&add_mutex);
        }
        else
        {
            pthread_mutex_lock(&add_mutex);
            state  =   sqlite3_step(statement);
            pthread_mutex_unlock(&add_mutex);
        }
        
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(statement);
        pthread_mutex_unlock(&add_mutex);
        if(SQLITE_DONE != state && SQLITE_OK != state)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s errorcode is %d",__FUNCTION__,state]];
            return NO;
        }
        
        return YES;
 
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        
    }
}



- (void)packageStatement:(sqlite3_stmt *)statement toArray:(NSMutableArray *)items
{
    NSString *col_name	=   nil;
    int      col_type			=   0;
    int      col_count			=   0;
    id       value				=   nil;
    NSMutableDictionary *info   =   nil;
    while (SQLITE_ROW == sqlite3_step(statement))
    {
        info        =   [[NSMutableDictionary alloc]init];
        col_count   =   sqlite3_column_count(statement);
        
        for (int i = 0; i < col_count; i++)
        {
            col_name    =   [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
            col_type    =   sqlite3_column_type(statement, i);
            if(SQLITE_INTEGER == col_type)
            {
                value   =   [NSNumber numberWithInteger:sqlite3_column_int(statement, i)];
            }
            else if(SQLITE_FLOAT == col_type)
            {
                value   =   [NSNumber numberWithFloat:sqlite3_column_double(statement, i)];
            }
            else if(SQLITE_TEXT == col_type)
            {
                value   =   [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
            }
            else if(SQLITE_NULL == col_type)
            {
                value   =   nil;
            }
            
            if(value)
            {
                [info setValue:value forKey:col_name];
            }
        }
        [items addObject:info];
        [info release];
        info    =   nil;
    }
}

-(sqlite3*)getDbHandle
{
	return _handle;
}
-(void)setDbHandle:(sqlite3*)handle
{
	_handle = handle;
}


- (int)newCloseDatabase{
    int ret = sqlite3_close(_handle);
    if (ret == SQLITE_OK) {
        [[eCloudDAO getDatabase] setDBHandleToNil];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 关闭数据库返回 %d",__FUNCTION__,ret]];
    return ret;
}


@end

