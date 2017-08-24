//
//  KapokDAO.m
//  eCloud
//
//  Created by  lyong on 14-5-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "KapokDAO.h"
#import "KapokFlySql.h"
#import "kapokImageObject.h"
#import "kapokUploadEventObject.h"
#import "eCloudDefine.h"

static KapokDAO *kapokDAO;
@implementation KapokDAO

//获取数据库的实例
+(id)getDatabase
{
	if(kapokDAO == nil)
	{
		kapokDAO = [[KapokDAO alloc]init];
        
	}
	return kapokDAO;  //create table if not exists kapok_imagelist(upload_id TEXT,image_name TEXT,image_code TEXT,PRIMARY KEY(upload_id,image_code))

}
// 上传纪录
-(void)addUploadRecord:(NSDictionary *)dic
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"upload_id",@"selected_date",@"create_time",@"flight_num",@"start_airport",@"boarding_num",@"emp_code",@"upload_state",nil];
	NSString    *sql        =   nil;
    
    sql =   [self replaceIntoTable:table_kapok_upload newInfo:dic keys:keys];
    [self operateSql:sql Database:_handle toResult:nil];
    
}
//上传的照片
-(void)addUploadImage:(NSDictionary *)dic
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"upload_id",@"image_name",@"image_code",@"upload_state",@"image_token",@"upload_start_index",nil];
	NSString    *sql        =   nil;
    
    sql =   [self replaceIntoTable:table_kapok_imagelist newInfo:dic keys:keys];
    [self operateSql:sql Database:_handle toResult:nil];
    
}

#pragma mark 上传事件
-(NSArray *)getAllKapokUploadEvent
{
	NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select * from %@ order by create_time desc",table_kapok_upload];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		kapokUploadEventObject *record = [[kapokUploadEventObject alloc]init];
		record.upload_id=[dic objectForKey:@"upload_id"];
        record.selected_date=[dic objectForKey:@"selected_date"];
        record.create_time=[dic objectForKey:@"create_time"];
        record.flight_num=[dic objectForKey:@"flight_num"];
        record.start_airport=[dic objectForKey:@"start_airport"];
        record.boarding_num=[dic objectForKey:@"boarding_num"];
        record.emp_code=[dic objectForKey:@"emp_code"];
        record.upload_state=[[dic objectForKey:@"upload_state"]intValue];
         NSString* selected_date = [record.selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        record.show_str=[NSString stringWithFormat:@"%@/%@/%@/%@",selected_date,record.flight_num,record.start_airport,record.boarding_num];
        [mArray addObject:record];
        [record release];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}
#pragma mark 准备上传事件
-(NSArray *)getReadyForUploadEvent
{
	NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select * from %@ where upload_state!=0 order by create_time asc",table_kapok_upload];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		kapokUploadEventObject *record = [[kapokUploadEventObject alloc]init];
		record.upload_id=[dic objectForKey:@"upload_id"];
        record.selected_date=[dic objectForKey:@"selected_date"];
        record.create_time=[dic objectForKey:@"create_time"];
        record.flight_num=[dic objectForKey:@"flight_num"];
        record.start_airport=[dic objectForKey:@"start_airport"];
        record.boarding_num=[dic objectForKey:@"boarding_num"];
        record.emp_code=[dic objectForKey:@"emp_code"];
        record.upload_state=[[dic objectForKey:@"upload_state"]intValue];
         NSString* selected_date = [record.selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        record.show_str=[NSString stringWithFormat:@"%@/%@/%@/%@",selected_date,record.flight_num,record.start_airport,record.boarding_num];
        [mArray addObject:record];
        [record release];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}
#pragma mark 删除某一条上传记录
-(void)deleteOneUpload:(NSString *)upload_id
{
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ where upload_id = '%@' ",table_kapok_upload,upload_id];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
     deletesql = [NSString stringWithFormat:@"delete from %@ where upload_id = '%@' ",table_kapok_imagelist,upload_id];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
    for (int i=0; i<5; i++) {
     NSString *filePath = [StringUtil newKapokPath];
       NSString * fileName = [NSString stringWithFormat:@"%@_%d.jpg",upload_id,i];
       NSString * small_fileName = [NSString stringWithFormat:@"%@_icon_%d.jpg",upload_id,i];
      [StringUtil deleteFile:[filePath stringByAppendingPathComponent:fileName]];
      [StringUtil deleteFile:[filePath stringByAppendingPathComponent:small_fileName]];
    }

}
-(NSArray *)getKapokUploadImageListPathBy:(NSString *)upload_id
{
    NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select image_name from %@ where upload_id=%@",table_kapok_imagelist,upload_id];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        NSString *pic_name=[dic objectForKey:@"image_name"];
        NSString *filePath = [StringUtil newKapokPath];
        NSString *pic_path= [filePath stringByAppendingPathComponent:pic_name];
        [mArray addObject:pic_path]; 
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}

#pragma mark 未读图片信息
-(NSArray *)getKapokNoUploadImageInfoBy:(NSString *)upload_id
{
    NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select * from %@ where upload_id=%@ and upload_state!=0",table_kapok_imagelist,upload_id];

	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        NSString *pic_name=[dic objectForKey:@"image_name"];
        NSString *filePath = [StringUtil newKapokPath];
        NSString *pic_path= [filePath stringByAppendingPathComponent:pic_name];
        NSString *pic_token=[dic objectForKey:@"image_token"];
      
        kapokImageObject *kapok_image=[[kapokImageObject alloc]init];
        kapok_image.image_path=pic_path;
        kapok_image.image_token=pic_token;
        kapok_image.image_name=pic_name;
        kapok_image.upload_start_index=[[dic objectForKey:@"upload_start_index"]intValue];
        [mArray addObject:kapok_image];
        [kapok_image release];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}
#pragma mark 未上传的图片
-(NSArray *)getKapokNoUploadImageListPathBy:(NSString *)upload_id
{
    NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select image_name from %@ where upload_id=%@ and upload_state!=0",table_kapok_imagelist,upload_id];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        NSString *pic_name=[dic objectForKey:@"image_name"];
        NSString *filePath = [StringUtil newKapokPath];
        NSString *pic_path= [filePath stringByAppendingPathComponent:pic_name];
        [mArray addObject:pic_path];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}
#pragma mark 上传事件 总的记录个数
-(int)getKapokUploadEventCount
{
	int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where upload_state=0",table_kapok_upload];
	// [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"]intValue];
	}
	[pool release];
	return _count;
}

#pragma mark  按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getKapokUploadEventByLimit:(int)_limit andOffset:(int)_offset
{
    NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_state=0 order by create_time desc limit(%d) offset(%d)",table_kapok_upload,_limit,_offset];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		kapokUploadEventObject *record = [[kapokUploadEventObject alloc]init];
		record.upload_id=[dic objectForKey:@"upload_id"];
        record.selected_date=[dic objectForKey:@"selected_date"];
        record.create_time=[dic objectForKey:@"create_time"];
        record.flight_num=[dic objectForKey:@"flight_num"];
        record.start_airport=[dic objectForKey:@"start_airport"];
        record.boarding_num=[dic objectForKey:@"boarding_num"];
        record.emp_code=[dic objectForKey:@"emp_code"];
        record.upload_state=[[dic objectForKey:@"upload_state"]intValue];
         NSString* selected_date = [record.selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        record.show_str=[NSString stringWithFormat:@"%@/%@/%@/%@",selected_date,record.flight_num,record.start_airport,record.boarding_num];
        [mArray addObject:record];
        [record release];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return mArray;
}

#pragma mark  最新保存的起飞机场
-(NSString *)getBoarding_NumLast
{
    NSString *boarding_num=@"";

//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_state=0 order by create_time desc limit(1) offset(0)",table_kapok_upload];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        boarding_num=[dic objectForKey:@"start_airport"];
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	//[pool release];
	return boarding_num;
}

#pragma mark  最新保存的起飞机场列表
-(NSArray *)getBoarding_NumLast_List
{
    NSMutableArray *mArray = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_state=0 order by create_time desc",table_kapok_upload];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        NSString *boarding_num=[dic objectForKey:@"boarding_num"];
        
        [mArray addObject:boarding_num];
	}
	[pool release];
	return mArray;
}

#pragma mark  获取正在上传的
-(kapokUploadEventObject *)getKapokUploadingEvent
{
    kapokUploadEventObject *record=nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_state=2 ",table_kapok_upload];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		record = [[kapokUploadEventObject alloc]init];
		record.upload_id=[dic objectForKey:@"upload_id"];
        record.selected_date=[dic objectForKey:@"selected_date"];
        record.create_time=[dic objectForKey:@"create_time"];
        record.flight_num=[dic objectForKey:@"flight_num"];
        record.start_airport=[dic objectForKey:@"start_airport"];
        record.boarding_num=[dic objectForKey:@"boarding_num"];
        record.emp_code=[dic objectForKey:@"emp_code"];
        record.upload_state=[[dic objectForKey:@"upload_state"]intValue];
         NSString* selected_date = [record.selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        record.show_str=[NSString stringWithFormat:@"%@/%@/%@/%@",selected_date,record.flight_num,record.start_airport,record.boarding_num];
       
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return record;
}

#pragma mark 按upload_id 获取上传
-(kapokUploadEventObject *)getKapokUploadEventById:(NSString *)upload_id
{
    kapokUploadEventObject *record=nil;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_id=%@ ",table_kapok_upload,upload_id];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		record = [[kapokUploadEventObject alloc]init];
		record.upload_id=[dic objectForKey:@"upload_id"];
        record.selected_date=[dic objectForKey:@"selected_date"];
        record.create_time=[dic objectForKey:@"create_time"];
        record.flight_num=[dic objectForKey:@"flight_num"];
        record.start_airport=[dic objectForKey:@"start_airport"];
        record.boarding_num=[dic objectForKey:@"boarding_num"];
        record.emp_code=[dic objectForKey:@"emp_code"];
        record.upload_state=[[dic objectForKey:@"upload_state"]intValue];
        NSString* selected_date = [record.selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        record.show_str=[NSString stringWithFormat:@"%@/%@/%@/%@",selected_date,record.flight_num,record.start_airport,record.boarding_num];
        
		//			[LogUtil debug:[NSString stringWithFormat:@"%@",[record toString]);
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return record;
}


#pragma mark  判断是否存在正在上传的
-(BOOL)getKapokUploadingEventState
{
    BOOL is_uploading=NO;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where upload_state=2 ",table_kapok_upload];
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
        is_uploading=YES;
		
	}
	//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
	return is_uploading;
}

#pragma mark  修改上传状态
-(void)updateKapodUploadState:(NSString*)upload_id andState:(int)upload_state
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set upload_state = %d where upload_id = %@ ",table_kapok_upload,upload_state,upload_id];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
}
#pragma mark  修改图片上传状态
-(void)updateKapodUploadState:(NSString*)upload_id andPicName:(NSString *)pic_name andState:(int)upload_state
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set upload_state = %d where upload_id = '%@' and image_name='%@'",table_kapok_imagelist,upload_state,upload_id,pic_name];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
}
#pragma mark  保存token
-(void)updateKapodUploadToken:(NSString*)upload_id andPicName:(NSString *)pic_name andToken:(NSString *)upload_token
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set image_token ='%@' where upload_id = '%@' and image_name='%@'",table_kapok_imagelist,upload_token,upload_id,pic_name];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
}

#pragma mark  保存 start_len
-(void)updateKapodUploadStartIndex:(NSString*)upload_id andPicName:(NSString *)pic_name andIndex:(int)upload_start_index
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set upload_start_index =%d where upload_id = '%@' and image_name='%@'",table_kapok_imagelist,upload_start_index,upload_id,pic_name];
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		[LogUtil debug:[NSString stringWithFormat:@"%s,error",__FUNCTION__]];
	}
}
#pragma mark  开启下个 上传事件
-(void)startNextUploading
{
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//order by a.msg_time desc
	NSString * sql = [NSString stringWithFormat:@"select * from %@ where upload_state=1 order by create_time asc",table_kapok_upload];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	
	[self operateSql:sql Database:_handle toResult:result];
    if ([result count]>0) {
        NSDictionary *dic=[result objectAtIndex:0];
        NSString* upload_id=[dic objectForKey:@"upload_id"];
        [self updateKapodUploadState:upload_id andState:2];//更新为正在上传
    }
		//		[LogUtil debug:[NSString stringWithFormat:@"%@",mArray);
	[pool release];
}
@end
