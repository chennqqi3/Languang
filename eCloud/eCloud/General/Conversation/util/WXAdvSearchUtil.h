//
//  WXAdvSearchUtil.h
//  eCloud
//  高级搜索工具栏
//  Created by shisuping on 17/6/12.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 高级搜索完毕通知界面刷新 */
#define ADV_SEARCH_FINISH_NOTIFICATION @"ADV_SEARCH_FINISH_NOTIFICATION"
/** 搜索结果放在字典里 */
#define SEARCH_RESULT_KEY @"SEARCH_RESULT_KEY"

/** 搜索网页的convid */
#define SEARCH_WEBPAGE_CONVID @"SearchWebConvId"

/** 最大显示条数 */
#define MAX_DSP_ITEM_COUNT (3)

//    查询结果类型定义
typedef enum {
    search_result_type_contact = 0,//搜索联系人
    search_result_type_group, //搜索群聊
    search_result_type_convrecord,//查询聊天记录
    search_result_type_app, //查询微应用
    search_result_type_filerecord, //查询文件
    search_result_type_webpage //查询网页
} adv_search_result_type_def;

@protocol AdvSearchProtocol <NSObject>

/** 加载搜索结果 */
- (void)loadSearchResults:(NSArray *)searchResults;

@end

@interface WXAdvSearchUtil : NSObject

@property (nonatomic,assign) id<AdvSearchProtocol> delegate;

+ (WXAdvSearchUtil *)getUtil;


/** 搜索联系人 */
- (void)queryContact:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults;

/** 搜索群聊 */
- (void)queryGroupConv:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults;

/** 搜索聊天记录 */
- (void)queryConvRecord:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults;

/** 搜索微应用 */
- (void)queryGomeApp:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults;

/** 搜索文件 */
- (void)queryFileRecord:(NSString *)searchStr andSearchResults:(NSMutableArray *)searchResults;

/** 根据搜索条件进行搜索，搜索结果只展示一部分，可以查看更多 */
- (NSArray *)advSearch:(NSString *)searchStr;


@end
