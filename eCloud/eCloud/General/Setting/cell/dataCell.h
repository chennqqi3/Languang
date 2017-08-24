//
//  dataCell.h
//  eCloud
//
//  Created by SH on 14-8-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dataCell : UITableViewCell


/** 数据类型 */
@property(nonatomic,retain) UILabel *typeLable;
/** 数据大小 */
@property(nonatomic,retain) UILabel *sizeLable;
/** 清除按钮 */
@property(nonatomic,retain) UIButton *clearButton;

@end
