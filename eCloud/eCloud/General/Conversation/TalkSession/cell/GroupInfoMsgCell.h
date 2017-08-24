//群组通知
#import <UIKit/UIKit.h>
#import "talkSessionUtil.h"


//时间上下留空
#define group_info_vertical_space (3.0)

//时间左右留空
#define group_info_horizontal_space (6.0)

//群组消息最大宽度左右留空
#define group_info_bg_horizontal_space (20.0)

//群组消息最大宽度
#define max_group_info_width (SCREEN_WIDTH - 2 * group_info_bg_horizontal_space)

//密聊聊天界面群组消息显示宽度
#define miliao_group_info_width (140)

@interface GroupInfoMsgCell : UITableViewCell

+ (CGFloat)getGroupInfoSize:(ConvRecord*)_convRecord;

+ (void)configureGroupInfo:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord;

@end
