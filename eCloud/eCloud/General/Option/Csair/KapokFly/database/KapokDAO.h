//
//  KapokDAO.h
//  eCloud
//
//  Created by  lyong on 14-5-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "eCloud.h"
@class kapokUploadEventObject;
//黎宜群测试
//#define kapod_file_server @"10.10.2.179:8080/mmdf"
//南航测试
//#define kapod_file_server @"10.108.76.204/mmtf"
//.5测试
//#define kapod_file_server @"59.37.126.119:8889/mmtf"
//现网
//#define kapod_file_server @"qyfile.csair.com/mmtf"

//南航 木棉童飞 测试环境
//#define kapod_file_server @"fx.csair.com:9083/mmtf"
#define kapod_file_server @"https://fx.csair.com:8443/mmtf"
//#define kapod_file_server @"http://fx.csair.com/mmtf"

@interface KapokDAO : eCloud

//获取数据库的实例
+(id)getDatabase;
// 上传纪录
-(void)addUploadRecord:(NSDictionary *)dic;
//上传的照片
-(void)addUploadImage:(NSDictionary *)dic;
#pragma mark 上传事件
-(NSArray *)getAllKapokUploadEvent;
#pragma mark 删除某一条上传记录
-(void)deleteOneUpload:(NSString *)upload_id;
#pragma mark 上传事件 总的记录个数
-(int)getKapokUploadEventCount;
#pragma mark  按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getKapokUploadEventByLimit:(int)_limit andOffset:(int)_offset;
-(NSArray *)getKapokUploadImageListPathBy:(NSString *)upload_id;
#pragma mark 准备上传事件
-(NSArray *)getReadyForUploadEvent;
#pragma mark  修改上传状态
-(void)updateKapodUploadState:(NSString*)upload_id andState:(int)upload_state;
#pragma mark  修改图片上传状态
-(void)updateKapodUploadState:(NSString*)upload_id andPicName:(NSString *)pic_name andState:(int)upload_state;
#pragma mark  判断是否存在正在上传的
-(BOOL)getKapokUploadingEventState;
#pragma mark  获取正在上传的
-(kapokUploadEventObject *)getKapokUploadingEvent;
#pragma mark 未上传的图片
-(NSArray *)getKapokNoUploadImageListPathBy:(NSString *)upload_id;
#pragma mark  开启下个 上传事件
-(void)startNextUploading;
#pragma mark 按upload_id 获取上传
-(kapokUploadEventObject *)getKapokUploadEventById:(NSString *)upload_id;
#pragma mark 未读图片信息
-(NSArray *)getKapokNoUploadImageInfoBy:(NSString *)upload_id;
#pragma mark  保存token
-(void)updateKapodUploadToken:(NSString*)upload_id andPicName:(NSString *)pic_name andToken:(NSString *)upload_token;
#pragma mark  保存 start_len
-(void)updateKapodUploadStartIndex:(NSString*)upload_id andPicName:(NSString *)pic_name andIndex:(int)upload_start_index;
#pragma mark  最新保存的起飞机场
-(NSString *)getBoarding_NumLast;
#pragma mark  最新保存的起飞机场列表
-(NSArray *)getBoarding_NumLast_List;
@end
