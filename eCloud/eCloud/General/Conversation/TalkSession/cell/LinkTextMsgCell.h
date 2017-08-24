//带超链接的文本

#import "ParentMsgCell.h"

@interface LinkTextMsgCell : ParentMsgCell

//显示文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//文本消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;


@end
