//录音消息

#import "ParentMsgCell.h"

// 发送的按钮的颜色
#define msg_btn_send_color_nomal     @"#589FFD"
#define msg_btn_send_color_highlight @"#1C6ADD"

// 接收的按钮的颜色
#define msg_btn_rcv_color_nomal      @"#FFFFFF"
#define msg_btn_rcv_color_highlight  @"#D6E7FE"

//收到的消息的背景颜色
#define rcv_msg_bg_color [UIColor whiteColor]

//发出去的消息的背景颜色
#define send_msg_bg_color [UIColor colorWithRed:0x58/255.0 green:0x9F/255.0 blue:0xFD/255.0 alpha:1]

//收到的消息的字体颜色
#define rcv_msg_text_color [UIColor blackColor]

//发出的消息的字体颜色
#define send_msg_text_color [UIColor whiteColor]

//消息和播放图片之间的留空
#define msg_playimage_vertical_space (9.5)
#define msg_playimage_horizontal_space (12.5)

//消息和秒数之间的留空
#define msg_seclabel_vertical_space (11.5)
#define msg_seclabel_horizontal_space (12)

#define msg_seclabel_fontcolor @"#A3A3A3"

//显示的秒数字体大小
#define msg_audio_sec_font_size (13.0)

@interface AudioMsgCell : ParentMsgCell

//显示录音文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通录音消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;


/** 激活录音消息 */
+ (void)activeCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord;

/** 录音消息回复正常状态 */
+ (void)deactiveCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord;

@end
