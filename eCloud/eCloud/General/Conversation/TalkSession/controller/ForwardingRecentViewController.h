//
//  contactViewController.h
//  eCloud
//  这个是最近联系人搜索、选择界面，转发消息时，打开此界面，选择或者创建新的会话，把消息转发出去
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForwardingProtocol.h"

/** 转发类型定义 */
typedef enum {
    /** 从聊天界面转发消息 */
    transfer_from_talksession = 100,
    /** 从图片预览消息转发 */
    transfer_from_image_preview = 101,
    /** 从收藏界面转发消息 */
    transfer_from_collection = 102,
    /** 蓝光新闻分享界面转发消息 */
    transfer_from_news = 102
}transfer_from_type;

@class ConvRecord;
@class Conversation;

@interface ForwardingRecentViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate>
{

}
@property(nonatomic,assign) id<ForwardingDelegate> forwardingDelegate;
/** 显示最近会话的tableview */
@property(nonatomic,retain)UITableView *personTable;
/** 最近会话对应的数据 */
@property (nonatomic,retain) NSMutableArray * itemArray;

/** 要转发的消息数组 */
@property (nonatomic,retain) NSMutableArray * forwardRecordsArray;

/** 用户输入的搜索条件 */
@property(nonatomic,retain) NSString *searchText;

/** 要转发的记录 单条记录 如果只转发一条，可以在forwardRecordsArray数组里只加一条 deprecated*/
@property (nonatomic,retain)ConvRecord *forwardRecord;

/** 用户选择的会话 */
@property (nonatomic,retain) Conversation *forwardConv;

/** 是不是从查询聊天记录界面发起的消息转发 */
@property (nonatomic,assign)bool isComeFromChatHistory;

/** 是不是从文件助手发起的转发 */
@property (nonatomic,assign)BOOL isComeFromFileAssistant;

/** 发自哪个controller */
@property (nonatomic,retain) UIViewController *fromVC;
/** 转发类型 */
@property (nonatomic,assign) int fromType;

/** 转发自哪里 目前只有转发位置信息用到，建议如果有新的转发需求，可以增加fromType定义 */
@property (nonatomic,retain) NSString *fromWhere;


/**
 创建一个新实例

 @param convRecord 要转发的消息
 @return ForwardingRecentViewController实例
 */
- (id)initWithConvRecord:(ConvRecord *)convRecord;


/**
 获取转发消息里文件类型消息的大小

 @param forwardRecordsArray 转发的消息记录列表
 @return 转发消息里文件类型消息的合计大小，如果大小为0，那么就返回nil
 */
+ (NSString *)getForwardFilesTotalSize:(NSArray *)forwardRecordsArray;

@end
