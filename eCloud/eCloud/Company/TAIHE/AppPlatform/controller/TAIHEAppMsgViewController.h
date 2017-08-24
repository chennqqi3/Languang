//
//  TAIHEAppMsgViewController.h
//  eCloud
//
//  Created by yanlei on 2017/2/22.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Conversation;

typedef enum
{
    app_email_flag = 1,
    app_oa_flag = 2,
    app_oa_attendance_flag = 3,
    app_conf_flag = 4 //新增会议类型消息
}app_type_flag;

@interface TAIHEAppMsgViewController : UIViewController

/** 会话  */
@property (nonatomic, strong) Conversation *conv;

@end
