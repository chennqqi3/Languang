//
//  FileAssistantViewController.h
//  eCloud
//
//  Created by Pain on 15-1-5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

//普通的文件助手的显示方式
//按照日期分组的文件的显示方式
typedef enum
{
    file_display_type_assistant = 0,
    file_display_type_group_by_time
}fileDisplayTypeDef;

@interface FileAssistantViewController:UIViewController
//对应的会话id
@property (nonatomic,retain) NSString *convId;
//文件的显示类型
@property (nonatomic,assign) int fileDisplayType;

@end
