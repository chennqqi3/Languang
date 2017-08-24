//普通的文本消息对应的cell
//和长消息是共用的

#pragma mark===========文本消息 相关宏定义==========

//收到的消息的背景颜色
#define rcv_msg_bg_color [UIColor whiteColor]

//收到的消息长按颜色
#define rcv_msg_active_bg_color [UIColor colorWithRed:0xD6/255.0 green:0xE7/255.0 blue:0xFE/255.0 alpha:1]

//收到的消息有边框 边框颜色 边框是0.5x
#define rcv_msg_bg_border_color [UIColor colorWithRed:0xE4/255.0 green:0xE4/255.0 blue:0xE4/255.0 alpha:1]

//收到的消息有边框 边框颜色 边框是0.5x
#define rcv_msg_active_bg_border_color [UIColor colorWithRed:0xB4/255.0 green:0xD4/255.0 blue:0xFE/255.0 alpha:1]

//发出去的消息的背景颜色
#define send_msg_bg_color [UIColor colorWithRed:0x58/255.0 green:0x9F/255.0 blue:0xFD/255.0 alpha:1]

//发出去的消息长按的背景颜色
#define send_msg_active_bg_color [UIColor colorWithRed:0x1C/255.0 green:0x6A/255.0 blue:0xDD/255.0 alpha:1]

//收到的消息的字体颜色
#define rcv_msg_text_color [UIColor blackColor]

//发出的消息的字体颜色
#define send_msg_text_color [UIColor whiteColor]

//收到的连接的颜色
#define rcv_link_text_color [UIColor blueColor]

//发出的连接的颜色
#define send_link_text_color [UIColor blueColor]

//消息和背景直接的留空
#define msg_vertical_space (8)
#define msg_horizontal_space (8)

//文本消息最大宽度
#define text_msg_max_width (msg_content_max_width - 2 * msg_horizontal_space)

//文本消息最小宽度
#define text_msg_min_width (21)

//文本消息最小高度
#define text_msg_min_height (15)



#import "ParentMsgCell.h"

@interface NormalTextMsgCell : ParentMsgCell

//显示普通文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通文本消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;


//根据内容计算文本消息cell的总高度
+ (float)calculateTotalTextMsgHeight:(ConvRecord *)_convRecord;

//长消息使用了相同的cell，获取长消息cell的高度
+ (float)getLongMsgHeight:(ConvRecord *)_convRecord;

//显示长消息
+ (void)configureLongMsg:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

@end
