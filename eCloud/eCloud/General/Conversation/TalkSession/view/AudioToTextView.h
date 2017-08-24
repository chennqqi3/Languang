//
//  AudioToTextView.h
//  eCloud
//
//  Created by yanlei on 15/11/13.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioToTextView : UIView
// 加载菊花
@property (nonatomic,retain) UILabel *txtLoadingLabel;

// 加载过程中的文字
@property (nonatomic,retain) UIActivityIndicatorView *txtLoadingTxt;

// 取消按钮
@property (nonatomic,retain) UIButton *txtCancelBtn;

// 显示语音文本的控件
@property (nonatomic,retain) UILabel *txtLabel;

@end
