// add by shisp 查询会话对应的数据库操作 2014.5.21

#import "eCloud.h"

@class Conversation;

@interface QueryDAO : eCloud

+ (QueryDAO *)getDatabase;

/**
 根据用户输入的内容，查找会话的内容，返回匹配的结果，如果是单条匹配，那么直接显示匹配记录，如果是多条匹配，那么返回匹配条数，并且可以进行二次查询

 @param searchStr 查询条件
 @return 聊天记录里包含搜索条件的会话的列表
 */
-(NSArray *)getConversationBySearchConvRecord:(NSString *)searchStr;

/**
 如果匹配的聊天记录大于1条，则可以查询所有匹配的 查询某一个会话的聊天记录

 @param conv 匹配了多条聊天记录的会话模型
 @param searchStr 搜索条件
 @return 每一条匹配的聊天记录
 */
- (NSArray *)getSearchResultsByConversation:(Conversation *)conv andSearchStr:(NSString *)searchStr;

/**
 匹配的记录按照时间倒序排列，最近的排在最上面，用户点击后，匹配的记录定位在界面上，方便用户看到

 @param conv 用户点击的会话
 @return 是一个字典，包含要在界面上加载的记录，总记录数
 */
- (NSDictionary *)getConvRecordListByConversation:(Conversation *)conv;

/**
 根据用户输入的内容，查询会话的标题和会话参与人，找到符合条件的会话记录，显示在会话section

 @param searchStr 搜索条件
 @return 符合条件的会话列表
 */
-(NSArray *)getConversationBy:(NSString *)searchStr;

/**
 在一个会话内，搜索和查询条件匹配的聊天记录 参数 包括 会话id 搜索内容

 @param convId 会话id
 @param searchStr 查询条件
 @param convType 会话类型
 @return 符合条件的聊天记录的列表
 */
- (NSArray *)searchConvRecordsInConv:(NSString *)convId withSearchStr:(NSString *)searchStr withConvType:(int)convType;

/**
 搜索一个会话内，某个人的发言，搜索条件不需要和聊天记录相配，而是和成员的账号或姓名相匹配

 @param convId 会话id
 @param searchStr 查询条件
 @return 符合条件的会话列表
 */
- (NSArray *)searchSomeoneRecordsInConv:(NSString *)convId withSearchStr:(NSString *)searchStr;

/**
 根据查询条件找到匹配的人员id
 
 @param searchStr 搜索条件
 @return 人员ID
 */
- (NSString *)getMatchEmpIdBySearchStr:(NSString *)searchStr;


@end
