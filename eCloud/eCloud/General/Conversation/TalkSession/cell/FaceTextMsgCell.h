//带表情的文本消息 cell

#import "ParentMsgCell.h"

@interface FaceTextMsgCell : ParentMsgCell

+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

@end
