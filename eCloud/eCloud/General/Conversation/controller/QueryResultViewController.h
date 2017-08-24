// add by shisp 2014.5.21 二级查询结果界面
// 在会话列表里查询聊天记录，查到不止一处匹配，可以在此界面展示每一条匹配的聊天记录

#import <UIKit/UIKit.h>

@class Conversation;
@interface QueryResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

/** 对应的会话Model */
@property (nonatomic,retain) Conversation *conv;

/** 搜索的字符串，用来高亮显示匹配的情况 */
@property (nonatomic,retain) NSString *searchStr;


@end
