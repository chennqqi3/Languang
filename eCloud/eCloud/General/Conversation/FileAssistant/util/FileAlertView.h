//
//  FileAlertView.h
//  eCloud
//  文件助手里用到的 弹出提示 工具栏
//  Created by 风影 on 15/2/9.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileAlertView : UIView{
    
}
/*
 功能描述
 获取实例
 
 参数
 frame: 提示框的frame
 _title:要提示的内容
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)_title;


/*
 功能描述
 显示提示框
 
 参数
 showView:显示提示框的父view
 */
- (void)showFileAlertViewInView:(UIView *)showView;
@end
