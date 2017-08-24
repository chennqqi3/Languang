//
//  CollectionDAO.h
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "eCloud.h"

@interface CollectionDAO : eCloud

+ (CollectionDAO *)shareDatabase;

//创建收藏表
- (void)createTable;

//添加收藏内容
- (void)addCollection:(NSDictionary *)dic;

//删除收藏内容
- (void)deleteCollection:(NSArray *)arr;

//获取收藏内容
- (NSArray *)getCollectionData:(NSInteger)count;

//通过类型获取收藏内容
- (NSMutableArray *)getCollectionByType:(NSInteger)type;

//通过关键字搜索
- (NSMutableArray *)searchByType:(NSInteger)type withWord:(NSString *)word withCount:(NSInteger)count;

//收到服务器的删除通知后 删除本地数据
- (void)deleteLocalCollection:(NSArray *)arr;

//增加一个方法，查询已经保存的收藏，找到最新的时间戳，找不到则使用当前最新时间
- (int)getLastCollectTime;

- (BOOL)isXiaoWanMsg:(NSString *)msgBody;
-(void)deleteAllData;


@end
