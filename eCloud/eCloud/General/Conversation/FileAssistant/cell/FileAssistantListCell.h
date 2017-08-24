//
//  FileAssistantListCell.h
//  eCloud
//
//  Created by 风影 on 15/1/11.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

//文件类型消息
#define file_icon_tag 110
#define file_name_tag 111
#define file_size_tag 112
#define file_validity_tag 113
#define file_time_tag 114
#define file_source_tag 115
#define file_download_button_tag 116
#define file_edit_button_tag 117
#define file_list_progressview_tag 118
#define file_download_button_lab_tag 119
#define file_download_flag_tag 120

#define file_parent_view_tag 121

//每行显示的高度
#ifdef _GOME_FLAG_
#define file_cell_height (74)
#else
#define file_cell_height (69)
#endif
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import <UIKit/UIKit.h>
@class ConvRecord;
@interface FileAssistantListCell : UITableViewCell{
    
}
- (void)configureCell:(UITableViewCell *)cell andConvRecord:(ConvRecord*)_convRecord; //配置cell
- (void)configureCell:(UITableViewCell *)cell editState:(BOOL)editing; //设置编辑状态
@end
