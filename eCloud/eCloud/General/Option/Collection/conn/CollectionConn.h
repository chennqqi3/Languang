//
//  CollectionConn.h
//  eCloud
//
//  Created by Alex L on 16/2/18.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"

@protocol CollectionConnDelegate <NSObject>

- (void)deleteCollectionByArray:(NSArray *)array;
- (void)addCollection;

@end

@class ConvRecord;
@interface CollectionConn : NSObject
@property (nonatomic, assign) id<CollectionConnDelegate>delegate;


+ (CollectionConn *)getConn;

//收藏同步请求
- (void)sendCollectionSync:(NSDictionary *)dic;

//处理收藏同步应答
- (void)processCollectionSyncAck:(FAVORITE_SYNC_ACK *)syncAck;

//收藏修改请求
- (BOOL)sendModiRequestWithMsg:(NSDictionary *)dic;

//处理收藏修改应答
- (void)ModiRequestAck:(FAVORITE_MODIFY_ACK *)modifyAck;

//处理通知应答
- (void)collectNotice:(FAVORITE_NOTICE *)info;

//下载一个文件 参数是文件对应的url 和 保存的文件名字
- (void)downloadFile:(ConvRecord *)convRecord;

@end
