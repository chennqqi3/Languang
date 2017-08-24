//
//  TalkSessionDefine.h
//  eCloud
//  和消息相关的宏定义 比如将要增加的定向回复消息 密聊消息
//  Created by shisuping on 17/5/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#ifndef TalkSessionDefine_h
#define TalkSessionDefine_h

#import "IOSSystemDefine.h"

//头像和气泡之间的间距默认为0 国美是5
//每条消息直接的间隔如果是国美增加10
#ifdef _GOME_FLAG_
#define HEAD_TO_BUBBLE (5.0)
#define MSG_TO_MSG (10.0)
#else

#ifdef _LANGUANG_FLAG_

#define HEAD_TO_BUBBLE (8.0)
#define MSG_TO_MSG (10.0)

#else

#define HEAD_TO_BUBBLE (0)
#define MSG_TO_MSG (0)

#endif

#endif

#pragma mark===========消息时间==========

//时间背景颜色
#define msg_time_bg_color [UIColor colorWithRed:0x00/255.0 green:0x00/255.0 blue:0x00/255.0 alpha:0.08]

//时间背景弧度
#define msg_time_bg_arc (3)

//时间字体大小
#define msg_time_font_size (13.0)

//时间颜色
#define msg_time_font_color [UIColor whiteColor]

//时间上下留空
#define msg_time_vertical_space (3.0)

//时间左右留空
#define msg_time_horizontal_space (6.0)

//时间与消息直接间隔
#define msg_time_to_msg_body_space (12.0)

//同一时间段内的消息间隔
#define msg_to_msg_space_of_same_time (12)

//不同时间段内的消息间隔
#define msg_to_msg_space_of_diff_time (28)

//聊天界面多选时 复选框大小 复选框左右留空
//#define check_box_size
#define check_box_horizontal_sapce (8)

#pragma mark===========人员头像名字==========

/** 名字颜色 */
#define sender_name_color [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]

//名字字体
#define sender_name_font_size (12.0)

//名字高度
#define sender_name_height (16.5)

/** 头像的高度 */
#define logo_height (36.0)

/** 头像左右两侧space */
#define logo_horizontal_space (6.0)

#pragma mark ===========消息体========

//消息体的y值和头像的y值差
#define send_msg_body_to_header_top (0)
#define rcv_msg_body_to_header_top (20)
//消息体的view的弧度
#define msg_body_bg_arc (3)

//消息体的最新高度
#define msg_body_min_height (text_msg_min_height + 2 * msg_vertical_space)


#pragma mark 消息内容显示的最大宽度 屏幕宽度 - (头像 + 状态)
//状态的宽度
#define msg_status_width (70)
//状态的左右间隔
#define msg_status_horizontal_space (6)
//如果msg显示高度大于最小高度，那么状态view靠下面显示，定义状态view和msg底部的间距 如果是最小高度，则垂直居中显示
#define msg_status_to_msg_vertical_space (6)

#define msg_content_max_width (SCREEN_WIDTH - (logo_horizontal_space * 3 + logo_height + msg_status_width + 2 * msg_status_horizontal_space))

#pragma mark 文件消息

//附件显示的高度是固定的，就是附件图片对应的高度
#define file_record_row_height (60)

#define min_height (45.0)

#pragma mark video展示宽高
// video展示宽高
#define video_display_width (120)
#define video_display_height (140)
// video展示中为进度条预留的高度
//#define video_progress_height (20)

// video展示中秒数的宽和高
#define video_sec_width (60)
#define video_sec_height (20)

#define VIDEO_MSG_PIC_ANGLE_WIDTH (8.0)

//钉消息图片的size
#define DINGXIAOXI_IMAGE_Y (2.0)
#define DINGXIAOXI_IMAGE_SIZE (20.0)

//失败按钮的size
#define FAIL_BTN_SIZE (20.0)

#define FAIL_BTN_SPACE (6.0)


//图片消息最大宽度
#define pic_msg_max_width (247)

//图片消息最小宽度
#define pic_msg_min_width (20)

//图片消息最大高度
#define pic_msg_max_height (247)

//图片消息最小高度
#define pic_msg_min_height (20)

//语音消息最大宽度

//语音消息最小宽度





/** 字体大小 */




/** 支持表情和超链接的第三方库 MLEmojiLabel 的定义 */
#define EMOJI_LABEL_CUSTOM_EMOJI_REGEX @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#define EMOJI_LABEL_CUSTOM_EMOJI_PLISTNAME @"expressionImage_custom.plist"

//时间
#define time_tag 100
#define time_text_tag 101

//头像
#define head_tag 200
#define head_empName_tag 202

//消息记录编辑按钮 把选择按钮作为headview的子view
//按钮tag
#define head_edit_button_tag 2001
//按钮大小
#define edit_button_size (20.0)


//消息内容
#define body_tag 203
#define bubble_send_tag 204
#define bubble_rcv_tag 205

//状态
#define status_tag 300
#define status_failBtn_tag 301
#define status_spinner_tag 302
#define status_audio_tag 303

/** 密聊消息能够显示的秒数 */
#define status_miliaomsg_lefttime 304

/** 钉消息标志 */
#define status_dingxiaoxi_flag_tag 305


//文件类型消息
#define file_tag 310
#define file_pic_tag 311
#define file_name_tag 312
#define file_progress_tag 313
#define file_size_tag 314
#define file_download_tag 315
#define file_download_state_tag 316
#define file_progressview_tag 317
#define file_download_cancel_tag 318

#define file_sub_view_tag 320

//文件cell的空白部分的尺寸
#ifdef _GOME_FLAG_
#define file_cell_space (10.0)
#else
#define file_cell_space (0.0)
#endif


//图片消息
#define pic_tag 400
#define pic_progress_tag 401
#define pic_progress_Label_tag 402

// 视频消息
#define video_tag 450
#define video_play_tag 451
#define video_progress_tag 317
#define video_progress_Label_tag 453
#define video_sec_tag 454

//录音消息
#define audio_tag 500
#define audio_playImageView_tag 501
#define audio_second_tag 502

//普通文本消息，包括长消息
#define normal_text_tag 600

//不带超链接图文混合消息
#define nolink_text_pic_tag 601

//带超链接文本消息
#define link_text_tag 700

//群组通知消息
#define groupinfo_tag 900
#define groupinfo_text_tag 901

//一呼百应消息
#define receipt_tag 910
#define receipt_text_tag 911

//图文消息
#define imgtxt_table_tag 1000
#define imgtxt_title_tag 1001
#define imgtxt_pic_tag 1002
#define imgtxt_des_tag 1003

//位置类型消息
#define location_pic_view_tag 1100
#define location_address_tag 1101
#define location_load_indicator_view_tag 1102
#define location_mapview_tag (1103)
#define location_parent_view_tag 1104


#define location_pic_width (SCREEN_WIDTH * 0.6)
#define location_pic_height (location_pic_width * 0.8)
#define location_address_height (30.0)

//新闻类型消息
#define news_title_tag 1500
#define news_url_tag 1501

#define news_view_width (245)
#define news_view_height (76)
/** 红包类型消息 */
#define red_pecket_view_tag 1400
/*
 新的图文类型消息相关定义
 */
#define new_imgtxt_parent_view_tag (1200)
#define new_imgtxt_title_label_tag (1201)
#define new_imgtxt_img_view_tag (1202)
#define new_imgtxt_description_lable_tag (1203)

#define new_imgtxt_title_height (25)
#define new_imgtxt_img_size (60)
#define new_imgtxt_total_hegiht (new_imgtxt_title_height + new_imgtxt_img_size)


#define imgtxt_title_font_size (17)
#define imgtxt_description_font_size (15)

#define imgtxt_description_font_color [UIColor grayColor]

//宽度
#define imgtxt

/** 定向回复类型消息 相关定义 */

/** 定向回复消息的父view */
#define reply_one_msg_parent_view_tag (1300)
/** 原始消息的父view */
#define reply_one_msg_send_parent_view_tag (1301)
/** 发送人、发送时间 label */
#define reply_one_msg_sender_name_and_time_label_tag (1302)
/** 发送内容 label 支持表情 但是不支持超链接 */
#define reply_one_msg_sender_msg_label_tag (1303)
/** 中间的分割线 */
#define reply_one_msg_seperate_line_tag (1304)
/** 消息正文 要求能支持表情和超链接 */
#define reply_one_msg_reply_msg_label_tag (1305)
/** 双引号图标 */
#define reply_one_msg_quote_view_tag (1306)

#ifdef _LANGUANG_FLAG_
//	点击播放按钮
//	最小宽度
#define MIN_AUDIO_WIDTH 63
//	最大宽度
#define MAX_AUDIO_WIDTH 171
//	语音高度
#define AUDIO_HEIGHT 37
//	每一秒多的宽度
#define PER_SECOND_WIDTH (1.83)

#else
//	点击播放按钮
//	最小宽度
#define MIN_AUDIO_WIDTH 50
//	最大宽度
#define MAX_AUDIO_WIDTH 218
//	每一秒多的宽度
#define PER_SECOND_WIDTH 2.8

#endif




/** 定向回复消息标志 */
#define REPLY_TO_ONE_MSG_FLAG @"@replyTo("

/** 密聊消息标志 */
#define SECRET_MSG_FLAG @"SECRET"

/** 定向回复消息label Y值 */
#define REPLY_MSG_LABEL_Y (5)
/** 定向回复消息label高度 */
#define REPLY_MSG_LABEL_HEIGHT (30)


#pragma mark ======tag定义======
#define talksession_bgview_tag (100)

#define talksession_footerview_tag (101)

#define talksession_subfooterview_tag (102)

#define talksession_text_parent_view_tag (103)

#define talksession_reply_msg_view_tag (104)

#define talksession_input_text_view_tag (105)

#define talksession_press_button_tag (106)

#define talksession_long_audio_view_tag (107)

#define talksession_talk_icon_view_tag (108)

//聊天界面UI调整宏定义

/** 输入区域高度 */
#define input_area_height (45)

#define subfooter_view_height (260)

/** 录音按钮大小 */
#define talk_button_size (24)

//录音按钮左边空白
#define talk_button_left_space (7)
//录音按钮右边空白
#define talk_button_right_space (7)

/** 输入框高度 输入框y值可以计算 */
#define input_text_height (35)

/** 表情按钮大小 */
#define face_button_size (24)

//表情按钮左边空白
#define face_button_left_space (7)

//表情按钮右边空白
#define face_button_right_space (8)

/** 功能展开按钮大小 贴着表情按钮放置即可*/
#define function_btn_size (24)

/** 功能按钮右侧空白*/
#define function_btn_right_space (7)

// 回执消息  相关属性
#define MSG_RECEIPT_FONTSIZE (12)
#define MSG_RECEIPT_SPACE (6)
#define MSG_RECEIPT_ALLREAD_COLOR @"#589FFD"
#define MSG_RECEIPT_OTHER_COLOR @"#A3A3A3"

// 单行最小高度
#define MSG_MIN_SINGLE_ROW_HEIGHT (37)


//录音按钮的x值
#define talk_button_x talk_button_left_space
//录音按钮的y值
#define talk_button_y (input_area_height - talk_button_size) * 0.5

//输入框的x
#define input_text_x (talk_button_size + talk_button_left_space + talk_button_right_space)
//输入框的y
#define input_text_y (input_area_height - input_text_height) * 0.5

//表情选择按钮的x值
#define face_button_x (SCREEN_WIDTH - function_btn_right_space - function_btn_size - face_button_right_space - face_button_size)

//表情选择按钮的y值
#define face_button_y (input_area_height - face_button_size) * 0.5

//功能按钮的x
#define function_btn_x (SCREEN_WIDTH - function_btn_size - function_btn_right_space)
//功能按钮的y
#define function_btn_y (input_area_height - function_btn_size) * 0.5


#define input_text_width (face_button_x - input_text_x - face_button_left_space)


//输入区域背景颜色

//输入框线的颜色

//输入框线的弧度


//按住说话语音按钮的frame和文本框一样
#define press_btn_width (input_text_width)
#define press_btn_height (input_text_height)
#define press_btn_x (input_text_x)
#define press_btn_y (input_text_y)


//文件助手ID
#define File_ID @"2"

//蓝信小秘书id
#define SECRETARY_ID @"13774"

//会议提醒(测试环境)
#define MEETING_ID_TEST @"12848"

//会议提醒(正式环境)
#define MEETING_ID @"12551"

//待办
#define BACK_LOG_ID @"12552"

#endif /* TalkSessionDefine_h */
