//
//  UserInterfaceUtil.h
//  eCloud
//
//  Created by shisuping on 17/1/10.
//  Copyright © 2017年  lyong. All rights reserved.
//

#ifndef UserInterfaceUtil_h
#define UserInterfaceUtil_h

#ifdef _GOME_FLAG_

//通讯录界面行高
#define emp_row_height (70)

//会话列表界面行高
#define conv_row_height (74)

//搜索框背景颜色
#define SEARCH_BAR_BGCOLOR [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1]

//头像和气泡之间的距离
#define HEAD_TO_BUBBLE (5.0)

//每条消息之间的距离
#define MSG_TO_MSG (10.0)

//发送消息的字体颜色
#define SEND_MSG_TEXT_COLOR [UIColor whiteColor]
//接收消息的字体颜色
#define RCV_MSG_TEXT_COLOR [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1]

//链接文本的字体颜色
#define SEND_LINK_MSG_TEXT_COLOR [UIColor yellowColor]
#define RCV_LINK_MSG_TEXT_COLOR [UIColor blueColor]

//会话列表置顶按钮背景颜色
#define CONTACTVIEW_SET_TOP_BTN_BGCOLOR [UIColor colorWithRed:0xcc/255.0 green:0xcc/255.0 blue:0xcc/255.0 alpha:1.0]
//会话列表删除按钮背景颜色
#define CONTACTVIEW_DELETE_CONV_BTN_BGCOLOR [UIColor colorWithRed:0xeb/255.0 green:0x46/255.0 blue:0x45/255.0 alpha:1.0]

//聊天界面发送人名字颜色
#define TALKSESSION_SENDER_NAME_COLOR [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1]

//文件助手界面 下载按钮 titlecolor
#define FILE_ASSISTANT_DOWNLOAD_BTN_TEXT_COLOR [UIColor whiteColor]

//文件助手界面 底部按钮 字体
#define FILE_ASSISTANT_BOTTOMBAR_BTN_FONT [UIFont systemFontOfSize:15.0]

#else

#define emp_row_height (60)

#define conv_row_height (62)

#define SEARCH_BAR_BGCOLOR [UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1]

#define HEAD_TO_BUBBLE (0)

#define MSG_TO_MSG (0)

//发送消息的字体颜色
#define SEND_MSG_TEXT_COLOR [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0]
//接收消息的字体颜色
#define RCV_MSG_TEXT_COLOR [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0]

//链接文本的字体颜色
#define SEND_LINK_MSG_TEXT_COLOR [UIColor blueColor]
#define RCV_LINK_MSG_TEXT_COLOR [UIColor blueColor]

//会话列表置顶按钮背景颜色
#define CONTACTVIEW_SET_TOP_BTN_BGCOLOR [UIColor lightGrayColor]
//会话列表删除按钮背景颜色
#define CONTACTVIEW_DELETE_CONV_BTN_BGCOLOR [UIColor colorWithRed:251./255. green:34./255. blue:38./255. alpha:1.]

//聊天界面发送人名字颜色
#define TALKSESSION_SENDER_NAME_COLOR [UIColor colorWithRed:115.0/255 green:115.0/255 blue:115.0/255 alpha:1.0]

//文件助手界面 下载按钮 titlecolor
#define FILE_ASSISTANT_DOWNLOAD_BTN_TEXT_COLOR [UIColor colorWithRed:19.0/255 green:111.0/255 blue:244.0/255 alpha:1.0]

#define FILE_ASSISTANT_BOTTOMBAR_BTN_FONT [UIFont boldSystemFontOfSize:15.0]

#endif



//============用户自定义头像 字典 key

//头像背景颜色
#define KEY_USER_DEFINE_LOGO_BG_COLOR @"USER_DEFINE_LOGO_BG_COLOR"
//头像大小
#define KEY_USER_DEFINE_LOGO_SIZE @"USER_DEFINE_LOGO_SIZE"
//头像显示文本
#define KEY_USER_DEFINE_LOGO_TEXT @"USER_DEFINE_LOGO_TEXT"
//头像文本大小
#define KEY_USER_DEFINE_LOGO_TEXT_SIZE @"USER_DEFINE_LOGO_TEXT_SIZE"
//头像文本颜色
#define KEY_USER_DEFINE_LOGO_TEXT_COLOR @"USER_DEFINE_LOGO_TEXT_COLOR"

//三人群组最高值
#define KEY_THREEUSER_HEIGHT_VALUE (47)



//==========生成随机颜色的宏
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define randomColor random(arc4random_uniform(250), arc4random_uniform(250), arc4random_uniform(250), 1)


//碧桂园默认头像背景颜色
#define user_name_logo_bg_color [UIColor colorWithRed:245/255.0 green:184/255.0 blue:91/255.0 alpha:1]

/** 蓝光主色 */
#define lg_main_color [UIColor colorWithRed:0x24/255.0 green:0x81/255.0 blue:0xfc/255.0 alpha:1.0]

/** 默认的头像 */
#define default_logo_image [UIImage imageNamed:@"default_user_logo"]
#endif /* UserInterfaceUtil_h */
